#include "rvex.h"

typedef unsigned char uint8_t;

int abs(int a)
{
	if (a < 0)
		return -a;
	else
		return a;
}

static int x264_pixel_sad_16x16( uint8_t *pix1, int i_stride_pix1,
		uint8_t *pix2, int i_stride_pix2 ) 
{                                                   
	int i_sum = 0;                                  
	int x, y;                                       
	for( y = 0; y < 16; y++ )                       
	{                                               
		for( x = 0; x < 16; x++ )                   
		{                                           
			i_sum += abs( pix1[x] - pix2[x] );      
		}                                           
		pix1 += i_stride_pix1;                      
		pix2 += i_stride_pix2;                      
	}                                               
	return i_sum;                                   
}

static void x264_pixel_sad_x4_16x16( uint8_t *fenc, uint8_t *pix0, uint8_t *pix1, 
		uint8_t *pix2, uint8_t *pix3, int i_stride, int scores[4] )
{
	scores[0] = x264_pixel_sad_16x16( fenc, 16, pix0, i_stride );
	scores[1] = x264_pixel_sad_16x16( fenc, 16, pix1, i_stride );
	scores[2] = x264_pixel_sad_16x16( fenc, 16, pix2, i_stride );
	scores[3] = x264_pixel_sad_16x16( fenc, 16, pix3, i_stride );
}

uint8_t fenc[16*16] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

uint8_t pix0[16*16];
uint8_t pix1[16*16];
uint8_t pix2[16*16];
uint8_t pix3[16*16];

int main(void)
{
	//uint8_t pix0[16*16];
	int scores[4];
	int i_stride = 16;
	int i;

    puts("x264 Test Started\n");

	x264_pixel_sad_x4_16x16(&fenc, &pix0, &pix1, &pix2, &pix3, i_stride, scores);
	for (i = 0; i < 4; i++)
	{
		if (scores[i] != 1920) {
            rvex_fail("x264 Test Failed\n");  
			return 1;
        }
	}
    rvex_succeed("x264 Test Passed\n");

	return 0;
}
