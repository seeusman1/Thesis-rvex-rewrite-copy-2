
#include "platform.h"
#include "rvex.h"

static void plat_time_init(void);

/******************************************************************************/
/* COMMON                                                                     */
/******************************************************************************/

void plat_init(void) {
  plat_time_init();
  
  // Enable interrupts.
  PLAT_IRQMP->mask[CR_CID] = 0;
  CR_CCR = CR_CCR_IEN | CR_CCR_RFT;
  
}


int putchar(int character)        { plat_serial_putc(0, character); return 0; }
int puts(const char *str)         { plat_serial_puts(0, str);       return 0; }
int rvex_succeed(const char *str) { plat_serial_puts(0, str);       return 0; }
int rvex_fail(const char *str)    { plat_serial_puts(0, str);       return 0; }


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

int memset(void *ptr, int value, unsigned int num) {
  unsigned char *cptr = (unsigned char*)ptr;
  while (num--) {
    *cptr = value;
  }
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
  int count;
  while (*str++) {
    count++;
  }
  return count;
}

int min(int a, int b) {
  return (a > b) ? b : a;
}

int max(int a, int b) {
  return (a > b) ? a : b;
}


/******************************************************************************/
/* INTERRUPTS                                                                 */
/******************************************************************************/

#define IRQ_COUNT 16
#define CTXT_COUNT 4

static void (*volatile irq_handlers[CTXT_COUNT * IRQ_COUNT])(void);

/**
 * Interrupt callback from startup.
 */
void interrupt(int irq) {
  int h = CR_CID * IRQ_COUNT + irq;
  void (*handler)(void) = irq_handlers[h];
  
  if (handler) {
    handler();
  }
}

/**
 * Registers the specified interrupt handler function for the specified IRQ.
 * Only one handler can be registered at a time.
 */
void plat_irq_register(int irq, void (*handler)(void)) {
  int h = CR_CID * IRQ_COUNT + irq;
  irq_handlers[h] = handler;
}

/**
 * Masks or unmasks an interrupt.
 */
void plat_irq_mask(int irq, int enable) {
  if (enable) {
    CR_CCR = CR_CCR_IEN_C;
    PLAT_IRQMP->mask[CR_CID] |= 1 << irq;
    CR_CCR = CR_CCR_IEN;
  } else {
    CR_CCR = CR_CCR_IEN_C;
    PLAT_IRQMP->mask[CR_CID] &= ~(1 << irq);
    CR_CCR = CR_CCR_IEN;
  }
}

/**
 * Returns whether the specified interrupt is pending.
 */
int plat_irq_ispending(int irq) {
  return (PLAT_IRQMP->pending & (1 << irq)) ? 1 : 0;
}

/**
 * Clears a pending interrupt.
 */
void plat_irq_clear(int irq) {
  PLAT_IRQMP->clear = 1 << irq;
}

/**
 * Forces the specified interrupt on the specified context.
 */
void plat_irq_force(int irq, int context) {
  PLAT_IRQMP->force[context] = 1 << irq;
}


/******************************************************************************/
/* SERIAL PORTS                                                               */
/******************************************************************************/

/**
 * Writes a character to the specified serial port. Blocking.
 */
void plat_serial_putc(int iface, char c) {
  
  if (iface == 0) {
    
#ifndef SIM
    // Wait for the TX data FIFO ready flag.
    while (!(PLAT_DEBUGUART_STAT & (1 << 1)));
#endif
    
    // Write to the UART.
    PLAT_DEBUGUART_DATA = c;
    
  }
}

/**
 * Writes a null-terminated string to the specified serial port. Blocking.
 */
void plat_serial_puts(int iface, const char *s) {
  while (*s) {
    plat_serial_putc(iface, (int)(*s++));
  }
}

/**
 * Writes a 32-bit hexadecimal value to the specified serial port. Blocking.
 */
void plat_serial_putx(int iface, int value) {
  unsigned int val = (unsigned int)value;
  int i;
  char c;
  
  plat_serial_putc(iface, '0');
  plat_serial_putc(iface, 'x');
  for (i = 0; i < 8; i++) {
    c = (char)(val >> 28);
    c = (c < 10) ? ('0' + c) : ('A' + c - 10);
    plat_serial_putc(iface, c);
    val <<= 4;
  }
  
}

/**
 * Writes a 32-bit signed decimal value to the specified serial port. Blocking.
 */
void plat_serial_putd(int iface, int value) {
  unsigned int val;
  int i;
  char c;
  static const int decades[10] = {
    1000000000,
    100000000,
    10000000,
    1000000,
    100000,
    10000,
    1000,
    100,
    10,
    1
  };
  
  // Handle negative numbers.
  if (value < 0) {
    plat_serial_putc(iface, '-');
    value = -value;
  }
  val = (unsigned int)value;
  
  // Divisions are really slow, so let's do without.
  c = '0';
  for (i = 0; i < 10; i++) {
    int dec = decades[i];
    if (val >= dec) {
      break;
    }
  }
  if (i == 10) {
    plat_serial_putc(iface, '0');
  } else {
    for (; i < 10; i++) {
      int dec = decades[i];
      c = '0';
      if (val >= (dec<<3)) { val -= (dec<<3); c += 8; }
      if (val >= (dec<<2)) { val -= (dec<<2); c += 4; }
      if (val >= (dec<<1)) { val -= (dec<<1); c += 2; }
      if (val >= (dec<<0)) { val -= (dec<<0); c += 1; }
      plat_serial_putc(iface, c);
    }
  }
  
}

/**
 * Writes a data buffer to the specified serial port. Non-blocking, same
 * interface as POSIX write.
 */
int plat_serial_write(int iface, const void *buf, int count) {
  const char *cbuf = (const char*)buf;
  int res = 0;
  if (iface == 0) {
    while (count) {
      
      // Stop if the TX data FIFO ready flag is not set.
      if (!(PLAT_DEBUGUART_STAT & (1 << 1))) {
        break;
      }
      
      // Write the next character.
      PLAT_DEBUGUART_DATA = *cbuf++;
      count -= 1;
      res += 1;
      
    }
  } else {
    res = -1;
  }
  return res;
}

/**
 * Reads from the specified serial port into the data buffer. Non-blocking, same
 * interface as POSIX read.
 */
int plat_serial_read(int iface, void *buf, int count) {
  char *cbuf = (char*)buf;
  int res = 0;
  if (iface == 0) {
    while (count) {
      
      // Stop if the RX data FIFO ready flag is not set.
      if (!(PLAT_DEBUGUART_STAT & (1 << 3))) {
        break;
      }
      
      // Read the next character.
      *cbuf++ = PLAT_DEBUGUART_DATA;
      count -= 1;
      res += 1;
      
    }
  } else {
    res = -1;
  }
  return res;
}


/******************************************************************************/
/* TIMING                                                                     */
/******************************************************************************/

static int frequency_khz;

/**
 * Initializes the timer.
 */
static void plat_time_init(void) {
  
  // Determine the frequency using the PS/2 clock prescaler register, which is
  // set such that the PS/2 clock is 10 kHz.
  frequency_khz = (PLAT_PS2(0)->timer + 1) * 10;
  
  // Set the prescaler such that it rolls over approximately every microsecond.
  PLAT_GPTIMER->scaler_reload = (frequency_khz - 500) / 1000;
  PLAT_GPTIMER->scaler_val = 0;
  
  // Configure the second counter.
  PLAT_GPTIMER->tim2_val    = 0xFFFFFFFF;
  PLAT_GPTIMER->tim2_reload = 0xFFFFFFFF;
  PLAT_GPTIMER->tim2_config = 0x23;
  
  // Configure the microsecond counter.
  PLAT_GPTIMER->tim1_val    = 999999;
  PLAT_GPTIMER->tim1_reload = 999999;
  PLAT_GPTIMER->tim1_config = 0x03;
  
  // Configure the audio samplerate timer.
  PLAT_GPTIMER->tim3_val    = 22;
  PLAT_GPTIMER->tim3_reload = 22;
  PLAT_GPTIMER->tim3_config = 0x03;
  
}

/**
 * Like CSL gettimeofday(). Starts at 0, guaranteed monotone between calls to
 * plat_settimeofday. THIS IS MERELY APPROXIMATE if the platform clock frequency
 * in MHz is not an integer.
 */
void plat_gettimeofday(int *sec, int *usec) {
  int s1, s2, us;
  
  // Query the timer. The seconds are queried twice to check for microsecond
  // overflow.
  s1 = PLAT_GPTIMER->tim2_val;
  us = PLAT_GPTIMER->tim1_val;
  s2 = PLAT_GPTIMER->tim2_val;
  
  // If the microsecond timer overflowed while checking, assume 0 and use the
  // second query of the seconds. This will necessarily represent a time between
  // the two seconds queries.
  if (s1 != s2) {
    *usec = 0;
  } else {
    *usec = 999999 - us;
  }
  *sec = ~s2;
  
}

/**
 * Sets the current time.
 */
void plat_settimeofday(int sec, int usec) {
  
  // Stop the timers while we do this.
  PLAT_GPTIMER->tim1_config = 0x02;
  PLAT_GPTIMER->tim2_config = 0x22;
  
  // Set the timer values.
  PLAT_GPTIMER->tim1_val = 999999 - usec;
  PLAT_GPTIMER->tim2_val = ~sec;
  
  // Restart the timers.
  PLAT_GPTIMER->tim2_config = 0x23;
  PLAT_GPTIMER->tim1_config = 0x03;
  
}

/**
 * Returns the frequency at which the platform is running in kHz.
 */
int plat_frequency(void) {
  return frequency_khz;
}

/**
 * Registers an (OS) tick handler. interval is specified in microseconds.
 */
int plat_tick(int interval, void (*handler)(void)) {
  
  if (handler) {
    
    // Register the interrupt,
    plat_irq_register(IRQ_TICK, handler);
    plat_irq_clear(IRQ_TICK);
    plat_irq_mask(IRQ_TICK, 1);
    
    // Configure the timer.
    PLAT_GPTIMER->tim4_val    = 9999;
    PLAT_GPTIMER->tim4_reload = 9999;
    PLAT_GPTIMER->tim4_config = 0x0B;
    
  } else {
    
    // Disable the timer.
    PLAT_GPTIMER->tim4_config = 0x00;
    
    // Unregister the interrupt.
    plat_irq_mask(IRQ_TICK, 0);
    plat_irq_register(IRQ_TICK, 0);
    
  }
  
}


/******************************************************************************/
/* AUDIO                                                                      */
/******************************************************************************/

/**
 * Sets the audio samplerate. rate must be specified in Hz. The actual
 * samplerate will approximate the requested rate.
 */
int plat_audio_setsamplerate(int rate) {
  
  // 1 MHz / rate -> reload + 1
  int reload = (1000000 + (rate >> 1)) / rate - 1;
  
  // Configure the audio samplerate timer.
  PLAT_GPTIMER->tim3_reload = reload;
  PLAT_GPTIMER->tim3_val = reload;
  
}

/**
 * Writes to the audio buffer. Same interface as POSIX write. Fills the buffer
 * up as far as possible given the input, doesn't block. Unsigned 8-bit mono
 * samples are expected.
 */
int plat_audio_write(const void *buf, int count) {
  const unsigned char *cbuf = (const unsigned char*)buf;
  int remain;
  count = min(count, plat_audio_avail());
  remain = count;
  while (remain--) {
    PLAT_AUDIO_DATA = *cbuf++;
  }
  return count;
}

/**
 * Returns the number of samples that can currently be written to the buffer.
 */
int plat_audio_avail(void) {
  return PLAT_AUDIO_FIFOLEN - PLAT_AUDIO_REMAIN;
}

/**
 * Returns the number of samples currently in the buffer.
 */
int plat_audio_remain(void) {
  return PLAT_AUDIO_REMAIN;
}


/******************************************************************************/
/* VIDEO                                                                      */
/******************************************************************************/

/**
 * Initializes the VGA/DVI output.
 *  - w specifies the width in pixels.
 *  - h specifies the height in pixels.
 *  - bpp specifies the bits per pixel and must be 8, 16 or 32.
 *  - dvi should be nonzero to output a DVI signal or zero to output a VGA
 *    signal.
 *  - frame should point to the framebuffer, which must be w*h*bpp/8 bytes in
 *    size.
 * 640x480 uses standard timing. Anything else results in non-standard
 * sync/porch timing and may or may not work. Returns 0 on success or -1 if an
 * I2C error occurs.
 */
int plat_video_init(int w, int h, int bpp, int dvi, const void *frame) {
  
  // Reset the SVGA controller.
  PLAT_SVGA->status = 2;
  
  // TODO: configure the Chrontel DAC
  
  // Configure the SVGA controller.
  PLAT_SVGA->vidlen  = (h << 16) + w;
  PLAT_SVGA->fplen   = (10 << 16) + 16;
  PLAT_SVGA->synclen = (2 << 16) + 96;
  PLAT_SVGA->linelen = ((45+h) << 16) + (160+w);
  
  // Start the SVGA controller.
  PLAT_SVGA->status = 1 & (0 << 6);
  
}

/**
 * Returns nonzero during vsyncs.
 */
int plat_video_isvsyncing(void) {
  return (PLAT_SVGA->status & 8) ? 1 : 0;
}

/**
 * Reassigns the framebuffer pointer.
 */
void plat_video_swap(const void *frame) {
  PLAT_SVGA->framebuf = frame;
}

/**
 * Assigns the given RGB value to the given palette index. All values must be
 * in the 0-255 range.
 */
void plat_video_palette(int index, int r, int g, int b) {
  PLAT_SVGA->clut = (index << 24) | (r << 16) | (g << 8) | b;
}


/******************************************************************************/
/* PS/2                                                                       */
/******************************************************************************/

/**
 * Initializes PS/2 interface iface in keyboard mode. handler is called from
 * the trap handler when a key is pressed, typematic'd or released. key
 * represents one of the KEY_* definitions from input-event-codes.h.
 */
void plat_ps2_kb_init(int iface, void (*handler)(int key, int up)) {
  // TODO
}

/**
 * Sets the keyboard LEDs.
 */
void plat_ps2_kb_setleds(int iface, int leds) {
  // TODO
}

/**
 * Initializes PS/2 interface iface in mouse mode. handler is called from the
 * trap handler when an update is received from the mouse.
 */
void plat_ps2_mouse_init(int iface, void (*handler)(int dx, int dy, int btns)) {
  // TODO
}


/******************************************************************************/
/* I2C                                                                        */
/******************************************************************************/

/**
 * Writes to an I2C device (blocking).
 *  - p must be set to the I2C peripheral address.
 *  - addr is the 7-bit I2C address (in bit 6..0).
 *  - reg is the I2C device register offset (first byte that is sent).
 *  - data and count specify the values to be written (second and later bytes).
 * Returns 0 if successful or -1 if the slave did not acknowledge somthing.
 */
int plat_i2c_write(volatile i2cmst_t *p, int addr, int reg, const char *data, int count) {
  // TODO
}

/**
 * Reads from an I2C device (blocking).
 *  - p must be set to the I2C peripheral address.
 *  - addr is the 7-bit I2C address (in bit 6..0).
 *  - reg is the I2C device register offset.
 *  - data and count specify the values to be read.
 * Returns 0 if successful or -1 if the slave did not acknowledge somthing.
 */
int plat_i2c_read(volatile i2cmst_t *p, int addr, int reg, const char *data, int count) {
  // TODO
}
