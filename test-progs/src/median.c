
#include "platform.h"

//#define DEBUG

/* The following code is from Iodev.org, modified for integer */
#define filterWidth 3
#define filterHeight 3
#define HSIZE 640
#define VSIZE 480

static inline int max(int a, int b)
{
	if (a > b) return a;
	else return b;
}

static inline int min(int a, int b)
{
	if (a < b) return a;
	else return b;
}

static inline void swap(unsigned char *a, unsigned char *b)
{
	unsigned char tmp = *a;
	*a = *b;
	*b = tmp;
}

unsigned int inbuf[HSIZE*VSIZE]; //you probably want to change this to something useful
unsigned int fb_mem[(HSIZE*VSIZE)+1024];
char strbuf[12];
int main()
{
	register unsigned int window[filterWidth*filterHeight];
	register currChan;
	int i, j, x, y, filterX, filterY;
	unsigned int* fb;

	plat_init();
	fb = plat_video_init(HSIZE, VSIZE, 32, 0, fb_mem);

	/* write a test screen */
#define CEILING(x,y) (((x) + (y) - 1) / (y))
	for (i = 0; i < HSIZE*(VSIZE/3); i++)
	{
		inbuf[i] = 0x00FF0000 - ((((i%HSIZE)/CEILING(HSIZE,256))&0xff)<<16);
	}

	for (; i < HSIZE*2*(VSIZE/3); i++)
	{
		inbuf[i] = 0x0000FF00 - ((((i%HSIZE)/CEILING(HSIZE,256))&0xff)<<8);
	}

	for (; i < HSIZE*VSIZE; i++)
	{
		inbuf[i] = 0x000000FF - (((i%HSIZE)/CEILING(HSIZE,256))&0xff);
	}
	
	/* Clear framebuffer */
	for (i = 0; i < HSIZE*VSIZE; i++)
	{
		fb[i] = 0;
	}

#ifdef DEBUG
	int runs;
	for (runs = 0; runs < 2; runs++){
#endif
	//apply the filter
	for(y = filterHeight/2; y < VSIZE-(filterHeight/2); y++)
	for(x = filterWidth /2; x < HSIZE- (filterWidth /2); x++)
	{

			/* when using 3 windows: */
/*
		for(filterX = 0; filterX < filterWidth; filterX++)
//		#pragma unroll(4)
		for(filterY = 0; filterY < filterHeight; filterY++)
		{
			inbufX = (x - filterWidth / 2 + filterX);// % HSIZE;
			inbufY = (y - filterHeight / 2 + filterY);// % VSIZE;
			
			window[(filterX*filterWidth)+filterY] = inbuf[inbufX + (inbufY*HSIZE)];
			

			windowr[(filterX*filterWidth)+filterY] = (unsigned char)((inbuf[inbufX + (inbufY*HSIZE)]>>16)&0xff);
		   	windowg[(filterX*filterWidth)+filterY] = (unsigned char)((inbuf[inbufX + (inbufY*HSIZE)]>>8)&0xff);
			windowb[(filterX*filterWidth)+filterY] = (unsigned char)(inbuf[inbufX + (inbufY*HSIZE)]&0xff);
		}
*/
		/*
		 * Maybe because of the register keyword, the compiler doesn't see the possible reuse. 
		 * I'd have to explicitly write that out.
		 */
		window[0] = inbuf[(x-1) + ((y-1)*HSIZE)];
		window[1] = inbuf[x     + ((y-1)*HSIZE)];
		window[2] = inbuf[(x+1) + ((y-1)*HSIZE)];
		window[3] = inbuf[(x-1) + (y    *HSIZE)];
		window[4] = inbuf[x     + (y    *HSIZE)];
		window[5] = inbuf[(x+1) + (y    *HSIZE)];
		window[6] = inbuf[(x-1) + ((y+1)*HSIZE)];
		window[7] = inbuf[x     + ((y+1)*HSIZE)];
		window[8] = inbuf[(x+1) + ((y+1)*HSIZE)];
		
		//now for all 3 channels, sort the array and pick the median value

		/*
		 * We're using 1 window, sort it 3 times.
		 * After each run, move the median value into the output
		 * and remove the higher bits from the values.
		 * We really want to keep the window in registers, so we write this out fully.
		 * To improve ILP, we'll write the sorting algorithm a bit differently from pure bubblesort.
		 */
		 
		 currChan = 0x00ff0000; //start with red, the highest indexed bits
		 for (i = 0; i < 3; i++)
		 {
		 	
#ifdef DEBUG
puts("window:\n");
	tohex(strbuf, window[0]);
	puts(strbuf);
	tohex(strbuf, window[1]);
	puts(strbuf);
	tohex(strbuf, window[2]);
	puts(strbuf);
	tohex(strbuf, window[3]);
	puts(strbuf);
	tohex(strbuf, window[4]);
	puts(strbuf);
	tohex(strbuf, window[5]);
	puts(strbuf);
	tohex(strbuf, window[6]);
	puts(strbuf);
	tohex(strbuf, window[7]);
	puts(strbuf);
	tohex(strbuf, window[8]);
	puts(strbuf);
#endif //debug
		 	//sort
#ifdef __open64__
		 	#pragma unroll (4)
#endif
		 	for (j = 0; j < 4; j++)
		 	{
		 		unsigned int tmp;
		 		//even
		 		if (window[0] > window[1])
		 		{
		 			tmp = window[0];
		 			window[0] = window[1];
		 			window[1] = tmp;
		 		}
		 		if (window[2] > window[3])
		 		{
		 			tmp = window[2];
		 			window[2] = window[3];
		 			window[3] = tmp;
		 		}
		 		if (window[4] > window[5])
		 		{
		 			tmp = window[4];
		 			window[4] = window[5];
		 			window[5] = tmp;
		 		}
		 		if (window[6] > window[7])
		 		{
		 			tmp = window[6];
		 			window[6] = window[7];
		 			window[7] = tmp;
		 		}
		 		
		 		//odd
		 		if (window[1] > window[2])
		 		{
		 			tmp = window[1];
		 			window[1] = window[2];
		 			window[2] = tmp;
		 		}
		 		if (window[3] > window[4])
		 		{
		 			tmp = window[3];
		 			window[3] = window[4];
		 			window[4] = tmp;
		 		}
		 		if (window[5] > window[6])
		 		{
		 			tmp = window[5];
		 			window[5] = window[6];
		 			window[6] = tmp;
		 		}
		 		if (window[7] > window[8])
		 		{
		 			tmp = window[7];
		 			window[7] = window[8];
		 			window[8] = tmp;
		 		}
		 	
		 	}
		 	
#ifdef DEBUG
puts("window sorted:\n");
	tohex(strbuf, window[0]);
	puts(strbuf);
	tohex(strbuf, window[1]);
	puts(strbuf);
	tohex(strbuf, window[2]);
	puts(strbuf);
	tohex(strbuf, window[3]);
	puts(strbuf);
	tohex(strbuf, window[4]);
	puts(strbuf);
	tohex(strbuf, window[5]);
	puts(strbuf);
	tohex(strbuf, window[6]);
	puts(strbuf);
	tohex(strbuf, window[7]);
	puts(strbuf);
	tohex(strbuf, window[8]);
	puts(strbuf);

#endif //debug
		 	
		 	//write channel into output
		 	fb[(y*HSIZE)+x] |= window[4]; //this assumes the output array has been cleared
		 	
		 	//if (i ==2) break; //the rest is not necessary for the last channel, but this doesn't speed up the code. I guess the compiler sees it.
		 	
		 	//remove current channel from window
		 	window[0] &= ~currChan;
		 	window[1] &= ~currChan;
		 	window[2] &= ~currChan;
		 	window[3] &= ~currChan;
		 	window[4] &= ~currChan;
		 	window[5] &= ~currChan;
		 	window[6] &= ~currChan;
		 	window[7] &= ~currChan;
		 	window[8] &= ~currChan;
		 	
		 	//next channel
		 	currChan >>= 8;
		 }


/* When using 3 windows:

		for (j = 0; j < (filterHeight*filterWidth)-1; j++)
		for (i = 0; i < (filterHeight*filterWidth)-1; i++)
		{
#define USE_SWAP //Using swap is faster (don't know why)
#ifdef USE_SWAP
			if (windowr[i] > windowr[i+1])
				swap(&windowr[i], &windowr[i+1]);
			if (windowg[i] > windowg[i+1])
				swap(&windowr[i], &windowr[i+1]);
			if (windowb[i] > windowb[i+1])
				swap(&windowr[i], &windowr[i+1]);
#else
			unsigned char tr, tg, tb;
			if (windowr[i] > windowr[i+1])
			{
				tr = windowr[i];
				windowr[i] = windowr[i+1];
				windowr[i+1] = tr;
			}
			if (windowg[i] > windowg[i+1])
			{
				tg = windowg[i];
				windowg[i] = windowg[i+1];
				windowg[i+1] = tg;
			}
			if (windowb[i] > windowb[i+1])
			{
				tb = windowb[i];
				windowb[i] = windowb[i+1];
				windowb[i+1] = tb;
			}
#endif
		}
*/

		

		/* when using 3 windows
		fb[(y*HSIZE)+x] = windowr[(filterWidth*filterHeight)/2]<<16
		| windowg[(filterWidth*filterHeight)/2]<<8
		| windowb[(filterWidth*filterHeight)/2];
		*/
	}
#ifdef DEBUG
	} //runs
#endif

	return 0;
}

