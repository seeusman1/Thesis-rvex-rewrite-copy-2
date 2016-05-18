
#include "nostdlib.h"
#include "platform.h"
#include "rvex.h"

/******************************************************************************/
/*                             MEMCPY AND FRIENDS                             */
/******************************************************************************/
// TODO: write the things below in assembly with proper optimizations.

void memcpy(void *dest, const void *src, unsigned int num) {
  char *cdest = (char*)dest;
  const char *csrc = (const char*)src;
  while (num--) {
    *cdest++ = *csrc++;
  }
}

void *memmove(void *dest, const void *src, unsigned int num) {
  char *cdest = (char*)dest;
  const char *csrc = (const char*)src;
  if (cdest <= csrc) {
    memcpy(dest, src, num);
  } else {
    cdest += num;
    csrc += num;
    while (num--) {
      *--cdest = *--csrc;
    }
  }
  return dest;
}

void _bcopy(const void *src, void *dest, unsigned int num) {
  memmove(dest, src, num);
}

int memcmp(const void *a, const void *b, unsigned int num) {
  const unsigned char *ca = (const unsigned char*)a;
  const unsigned char *cb = (const unsigned char*)b;
  while (num--) {
    if (*ca == *cb) {
      ca++;
      cb++;
    } else if (*ca > *cb) {
      return 1;
    } else {
      return -1;
    }
  }
  return 0;
}

void *memset(void *ptr, int value, unsigned int num) {
  unsigned char *cptr = (unsigned char*)ptr;
  while (num--) {
    *cptr = value;
  }
  return ptr;
}

void strcpy(char *dest, const char *src) {
  while (*src) {
    *dest++ = *src++;
  }
}

int strcmp(const char *a, const char *b) {
  while (*a || *b) {
    if (*a == *b) {
      a++;
      b++;
    } else if (*a > *b) {
      return 1;
    } else {
      return -1;
    }
  }
  return 0;
}

int strlen(const char *str) {
  int count = 0;
  while (*str++) {
    count++;
  }
  return count;
}


/******************************************************************************/
/*                          DYNAMIC MEMORY ALLOCATION                         */
/******************************************************************************/

#ifndef DYN_MEM_SPACE
#define DYN_MEM_SPACE (2*1024*1024)
#endif

// Number of blocks. This includes free blocks.
static unsigned int dyn_nblocks = 0;

// Dynamic memory data section.
static unsigned int dyn_data[DYN_MEM_SPACE/4];

// Block layout:
//   1 int:
//     bit 29..0: block size in words, EXCLUDING header int (n)
//     bit 31..30: 01 for free, 10 for allocated, others indicate corruption
//   n ints:
//     data

#define DYN_INIT \
  if (!dyn_nblocks) { \
    dyn_nblocks = 1; \
    dyn_data[0] = DYN_MEM_SPACE/4 | 0x40000000; \
  }

void *malloc(unsigned long size) {
  int remain;
  unsigned int *ptr;
  int irq_enabled = CR_CCR & CR_CCR_I_MASK;
  CR_CCR = CR_CCR_IEN_C;
  
  DYN_INIT;
  
  // All blocks are word aligned.
  size += 3;
  size >>= 2;
  
  // Find a free block that's large enough.
  remain = dyn_nblocks;
  ptr = dyn_data;
  while (remain) {
    if ((ptr >= dyn_data + DYN_MEM_SPACE/4) || (ptr < dyn_data)) {
      rvex_fail("Dynamic memory corrupted! Invalid block length.\n");
      CR_CCR = irq_enabled;
      return 0;
    } else {
      
      // Decode the block state.
      unsigned int len = *ptr;
      unsigned int state = len >> 30;
      len &= 0x3FFFFFFF;
      
      switch (state) {
        case 1:
          if ((len == size) || (len == size+1)) {
            
            // Current block is free and exactly the right size, or not large
            // enough to contain a second block. So claim all of it.
            *ptr = len | 0x80000000;
            CR_CCR = irq_enabled;
            //plat_serial_puts(0, "malloc'd ");
            //plat_serial_putd(0, size);
            //plat_serial_puts(0, " words at ");
            //plat_serial_putx(0, (unsigned long)(ptr+1));
            //plat_serial_puts(0, "; ");
            //plat_serial_putd(0, dyn_nblocks);
            //plat_serial_puts(0, " blocks\n");
            return ptr + 1;
            
          } else if (len > size) {
            
            // Current block is free and larger than we need. Split it up.
            *ptr = size | 0x80000000;
            *(ptr + size + 1) = (len - size - 1) | 0x40000000;
            dyn_nblocks++;
            CR_CCR = irq_enabled;
            //plat_serial_puts(0, "malloc'd ");
            //plat_serial_putd(0, size);
            //plat_serial_puts(0, " words at ");
            //plat_serial_putx(0, (unsigned long)(ptr+1));
            //plat_serial_puts(0, "; ");
            //plat_serial_putd(0, dyn_nblocks);
            //plat_serial_puts(0, " blocks\n");
            return ptr + 1;
            
          }
          break;
        
        case 2:
          // Block is occupied.
          break;
          
        default:
          rvex_fail("Dynamic memory corrupted! Invalid block state.\n");
          
      }
      
      // Go to the next block.
      ptr += len + 1;
      remain--;
    }
  }
  
  // If we get here, no block could be found.
  CR_CCR = irq_enabled;
  rvex_fail("Out of memory.\n");
  return 0;
  
}

void free(void *p) {
  int remain;
  unsigned int *ptr, *prev;
  int prevlen = 0;
  int irq_enabled = CR_CCR & CR_CCR_I_MASK;
  CR_CCR = CR_CCR_IEN_C;
  
  DYN_INIT;
  
  // Iterate over all the blocks to find the free block, as well as the block in
  // front of it and the block after it.
  remain = dyn_nblocks;
  ptr = dyn_data;
  prev = 0;
  while (remain) {
    if ((ptr >= dyn_data + DYN_MEM_SPACE/4) || (ptr < dyn_data)) {
      rvex_fail("Dynamic memory corrupted! Invalid block length.\n");
      CR_CCR = irq_enabled;
      return;
    } else {
      
      // Decode the block state.
      unsigned int len = *ptr;
      unsigned int state = len >> 30;
      len &= 0x3FFFFFFF;
      
      // Is this the block that is to be freed?
      if (((void*)(ptr+1)) == p) {
        unsigned int *block;
        
        // If the next block is free, merge it with this block.
        block = ptr + len + 1;
        if ((*block >> 30) == 1) {
          len += *block & 0x3FFFFFFF;
          dyn_nblocks--;
        }
        
        // If the preceding block is free, merge it with this block.
        if (prev) {
          block = prev;
          len += prevlen + 1;
          dyn_nblocks--;
        } else {
          block = ptr;
        }
        
        // Write the new free block header.
        *block = len | 0x40000000;
        CR_CCR = irq_enabled;
        //plat_serial_puts(0, "freed ");
        //plat_serial_putx(0, (unsigned long)(p));
        //plat_serial_puts(0, "; ");
        //plat_serial_putd(0, dyn_nblocks);
        //plat_serial_puts(0, " blocks\n");
        return;
        
      }
      
      // If this block is free, save the pointer to it.
      if (state == 1) {
        prev = ptr;
        prevlen = len;
      } else {
        prev = 0;
      }
      
      // Go to the next block.
      ptr += (*ptr & 0x3FFFFFFF) + 1;
      remain--;
      
    }
  }
  
  // If we get here, the pointer specified by free is invalid.
  CR_CCR = irq_enabled;
  rvex_fail("Invalid free() pointer.");
  return;
  
}


// TODO: this realloc is very simplistic. It doesn't shrink the block if the new
// size is smaller, and if the block is too small, it always does
// allocate-move-free.
void *realloc(void *p, unsigned long size) {
  unsigned int *ptr = (unsigned int*)p;
  void *np;
  int len;
  int irq_enabled = CR_CCR & CR_CCR_I_MASK;
  CR_CCR = CR_CCR_IEN_C;
  
  DYN_INIT;
  
  // Check the pointer.
  if ((((unsigned long)ptr) & 3) || (ptr >= dyn_data + DYN_MEM_SPACE/4) || (ptr < dyn_data+1)) {
    rvex_fail("Invalid realloc() ptr.\n");
    CR_CCR = irq_enabled;
    return 0;
  }
  
  // Figure out the actual size of the block. If it's large enough, we don't
  // need to do anything.
  len = *(ptr-1) & 0x3FFFFFFF;
  if (len<<2 >= size) {
    CR_CCR = irq_enabled;
    return p;
  }
  
  // Leave critical section.
  CR_CCR = irq_enabled;
  
  // Block isn't large enough. Allocate a new one, perform a memmove and free
  // the old block.
  np = malloc(size);
  memmove(np, p, size);
  free(p);
  return np;
  
}

void *calloc(unsigned long nmemb, unsigned long size) {
  size *= nmemb;
  void *ptr = malloc(size);
  memset(ptr, 0, size);
  return ptr;
}


/******************************************************************************/
/*                                    MISC.                                   */
/******************************************************************************/

int min(int a, int b) {
  return (a > b) ? b : a;
}

int max(int a, int b) {
  return (a > b) ? a : b;
}

void abort(void) {
  rvex_fail("abort() called.\n");
  while (1);
}
