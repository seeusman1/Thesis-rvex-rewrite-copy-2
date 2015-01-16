#include "common.h"
typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned long ulong;
static ulong des_skb[8][64] = {
  0x00000000, 0x00000010, 0x20000000, 0x20000010,
  0x00010000, 0x00010010, 0x20010000, 0x20010010,
  0x00000800, 0x00000810, 0x20000800, 0x20000810,
  0x00010800, 0x00010810, 0x20010800, 0x20010810,
  0x00000020, 0x00000030, 0x20000020, 0x20000030,
  0x00010020, 0x00010030, 0x20010020, 0x20010030,
  0x00000820, 0x00000830, 0x20000820, 0x20000830,
  0x00010820, 0x00010830, 0x20010820, 0x20010830,
  0x00080000, 0x00080010, 0x20080000, 0x20080010,
  0x00090000, 0x00090010, 0x20090000, 0x20090010,
  0x00080800, 0x00080810, 0x20080800, 0x20080810,
  0x00090800, 0x00090810, 0x20090800, 0x20090810,
  0x00080020, 0x00080030, 0x20080020, 0x20080030,
  0x00090020, 0x00090030, 0x20090020, 0x20090030,
  0x00080820, 0x00080830, 0x20080820, 0x20080830,
  0x00090820, 0x00090830, 0x20090820, 0x20090830,
  0x00000000, 0x02000000, 0x00002000, 0x02002000,
  0x00200000, 0x02200000, 0x00202000, 0x02202000,
  0x00000004, 0x02000004, 0x00002004, 0x02002004,
  0x00200004, 0x02200004, 0x00202004, 0x02202004,
  0x00000400, 0x02000400, 0x00002400, 0x02002400,
  0x00200400, 0x02200400, 0x00202400, 0x02202400,
  0x00000404, 0x02000404, 0x00002404, 0x02002404,
  0x00200404, 0x02200404, 0x00202404, 0x02202404,
  0x10000000, 0x12000000, 0x10002000, 0x12002000,
  0x10200000, 0x12200000, 0x10202000, 0x12202000,
  0x10000004, 0x12000004, 0x10002004, 0x12002004,
  0x10200004, 0x12200004, 0x10202004, 0x12202004,
  0x10000400, 0x12000400, 0x10002400, 0x12002400,
  0x10200400, 0x12200400, 0x10202400, 0x12202400,
  0x10000404, 0x12000404, 0x10002404, 0x12002404,
  0x10200404, 0x12200404, 0x10202404, 0x12202404,
  0x00000000, 0x00000001, 0x00040000, 0x00040001,
  0x01000000, 0x01000001, 0x01040000, 0x01040001,
  0x00000002, 0x00000003, 0x00040002, 0x00040003,
  0x01000002, 0x01000003, 0x01040002, 0x01040003,
  0x00000200, 0x00000201, 0x00040200, 0x00040201,
  0x01000200, 0x01000201, 0x01040200, 0x01040201,
  0x00000202, 0x00000203, 0x00040202, 0x00040203,
  0x01000202, 0x01000203, 0x01040202, 0x01040203,
  0x08000000, 0x08000001, 0x08040000, 0x08040001,
  0x09000000, 0x09000001, 0x09040000, 0x09040001,
  0x08000002, 0x08000003, 0x08040002, 0x08040003,
  0x09000002, 0x09000003, 0x09040002, 0x09040003,
  0x08000200, 0x08000201, 0x08040200, 0x08040201,
  0x09000200, 0x09000201, 0x09040200, 0x09040201,
  0x08000202, 0x08000203, 0x08040202, 0x08040203,
  0x09000202, 0x09000203, 0x09040202, 0x09040203,
  0x00000000, 0x00100000, 0x00000100, 0x00100100,
  0x00000008, 0x00100008, 0x00000108, 0x00100108,
  0x00001000, 0x00101000, 0x00001100, 0x00101100,
  0x00001008, 0x00101008, 0x00001108, 0x00101108,
  0x04000000, 0x04100000, 0x04000100, 0x04100100,
  0x04000008, 0x04100008, 0x04000108, 0x04100108,
  0x04001000, 0x04101000, 0x04001100, 0x04101100,
  0x04001008, 0x04101008, 0x04001108, 0x04101108,
  0x00020000, 0x00120000, 0x00020100, 0x00120100,
  0x00020008, 0x00120008, 0x00020108, 0x00120108,
  0x00021000, 0x00121000, 0x00021100, 0x00121100,
  0x00021008, 0x00121008, 0x00021108, 0x00121108,
  0x04020000, 0x04120000, 0x04020100, 0x04120100,
  0x04020008, 0x04120008, 0x04020108, 0x04120108,
  0x04021000, 0x04121000, 0x04021100, 0x04121100,
  0x04021008, 0x04121008, 0x04021108, 0x04121108,
  0x00000000, 0x10000000, 0x00010000, 0x10010000,
  0x00000004, 0x10000004, 0x00010004, 0x10010004,
  0x20000000, 0x30000000, 0x20010000, 0x30010000,
  0x20000004, 0x30000004, 0x20010004, 0x30010004,
  0x00100000, 0x10100000, 0x00110000, 0x10110000,
  0x00100004, 0x10100004, 0x00110004, 0x10110004,
  0x20100000, 0x30100000, 0x20110000, 0x30110000,
  0x20100004, 0x30100004, 0x20110004, 0x30110004,
  0x00001000, 0x10001000, 0x00011000, 0x10011000,
  0x00001004, 0x10001004, 0x00011004, 0x10011004,
  0x20001000, 0x30001000, 0x20011000, 0x30011000,
  0x20001004, 0x30001004, 0x20011004, 0x30011004,
  0x00101000, 0x10101000, 0x00111000, 0x10111000,
  0x00101004, 0x10101004, 0x00111004, 0x10111004,
  0x20101000, 0x30101000, 0x20111000, 0x30111000,
  0x20101004, 0x30101004, 0x20111004, 0x30111004,
  0x00000000, 0x08000000, 0x00000008, 0x08000008,
  0x00000400, 0x08000400, 0x00000408, 0x08000408,
  0x00020000, 0x08020000, 0x00020008, 0x08020008,
  0x00020400, 0x08020400, 0x00020408, 0x08020408,
  0x00000001, 0x08000001, 0x00000009, 0x08000009,
  0x00000401, 0x08000401, 0x00000409, 0x08000409,
  0x00020001, 0x08020001, 0x00020009, 0x08020009,
  0x00020401, 0x08020401, 0x00020409, 0x08020409,
  0x02000000, 0x0A000000, 0x02000008, 0x0A000008,
  0x02000400, 0x0A000400, 0x02000408, 0x0A000408,
  0x02020000, 0x0A020000, 0x02020008, 0x0A020008,
  0x02020400, 0x0A020400, 0x02020408, 0x0A020408,
  0x02000001, 0x0A000001, 0x02000009, 0x0A000009,
  0x02000401, 0x0A000401, 0x02000409, 0x0A000409,
  0x02020001, 0x0A020001, 0x02020009, 0x0A020009,
  0x02020401, 0x0A020401, 0x02020409, 0x0A020409,
  0x00000000, 0x00000100, 0x00080000, 0x00080100,
  0x01000000, 0x01000100, 0x01080000, 0x01080100,
  0x00000010, 0x00000110, 0x00080010, 0x00080110,
  0x01000010, 0x01000110, 0x01080010, 0x01080110,
  0x00200000, 0x00200100, 0x00280000, 0x00280100,
  0x01200000, 0x01200100, 0x01280000, 0x01280100,
  0x00200010, 0x00200110, 0x00280010, 0x00280110,
  0x01200010, 0x01200110, 0x01280010, 0x01280110,
  0x00000200, 0x00000300, 0x00080200, 0x00080300,
  0x01000200, 0x01000300, 0x01080200, 0x01080300,
  0x00000210, 0x00000310, 0x00080210, 0x00080310,
  0x01000210, 0x01000310, 0x01080210, 0x01080310,
  0x00200200, 0x00200300, 0x00280200, 0x00280300,
  0x01200200, 0x01200300, 0x01280200, 0x01280300,
  0x00200210, 0x00200310, 0x00280210, 0x00280310,
  0x01200210, 0x01200310, 0x01280210, 0x01280310,
  0x00000000, 0x04000000, 0x00040000, 0x04040000,
  0x00000002, 0x04000002, 0x00040002, 0x04040002,
  0x00002000, 0x04002000, 0x00042000, 0x04042000,
  0x00002002, 0x04002002, 0x00042002, 0x04042002,
  0x00000020, 0x04000020, 0x00040020, 0x04040020,
  0x00000022, 0x04000022, 0x00040022, 0x04040022,
  0x00002020, 0x04002020, 0x00042020, 0x04042020,
  0x00002022, 0x04002022, 0x00042022, 0x04042022,
  0x00000800, 0x04000800, 0x00040800, 0x04040800,
  0x00000802, 0x04000802, 0x00040802, 0x04040802,
  0x00002800, 0x04002800, 0x00042800, 0x04042800,
  0x00002802, 0x04002802, 0x00042802, 0x04042802,
  0x00000820, 0x04000820, 0x00040820, 0x04040820,
  0x00000822, 0x04000822, 0x00040822, 0x04040822,
  0x00002820, 0x04002820, 0x00042820, 0x04042820,
  0x00002822, 0x04002822, 0x00042822, 0x04042822,
};
static char shifts2[16] = {0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0};
void des_set_key(key, schedule)
     unsigned char *key;
     struct key *schedule;
{
  register ulong c, d, t, s;
  register uchar *in;
  register ulong *k;
  register int i;
  k = (ulong *) schedule;
  in = (uchar *) key;
  (c = ((ulong) (*((in)++))), c |= ((ulong) (*((in)++))) << 8, c |= ((ulong) (*((in)++))) << 16, c |= ((ulong) (*((in)++))) << 24);
  (d = ((ulong) (*((in)++))), d |= ((ulong) (*((in)++))) << 8, d |= ((ulong) (*((in)++))) << 16, d |= ((ulong) (*((in)++))) << 24);
  ((t) = ((((d) >> (4)) ^ (c)) & (0x0f0f0f0f)), (c) ^= (t), (d) ^= ((t) << (4)));
  ((t) = ((((c) << (16 - (-2))) ^ (c)) & (0xcccc0000)), (c) = (c) ^ (t) ^ (t >> (16 - (-2))));
  ((t) = ((((c) << (16 - (-1))) ^ (c)) & (0xaaaa0000)), (c) = (c) ^ (t) ^ (t >> (16 - (-1))));
  ((t) = ((((c) << (16 - (8))) ^ (c)) & (0x00ff0000)), (c) = (c) ^ (t) ^ (t >> (16 - (8))));
  ((t) = ((((c) << (16 - (-1))) ^ (c)) & (0xaaaa0000)), (c) = (c) ^ (t) ^ (t >> (16 - (-1))));
  ((t) = ((((d) << (16 - (-8))) ^ (d)) & (0xff000000)), (d) = (d) ^ (t) ^ (t >> (16 - (-8))));
  ((t) = ((((d) << (16 - (8))) ^ (d)) & (0x00ff0000)), (d) = (d) ^ (t) ^ (t >> (16 - (8))));
  ((t) = ((((d) << (16 - (2))) ^ (d)) & (0x33330000)), (d) = (d) ^ (t) ^ (t >> (16 - (2))));
  d = ((d & 0x00aa00aa) << 7) | ((d & 0x55005500) >> 7) | (d & 0xaa55aa55);
  d = (d >> 8) | ((c & 0xf0000000) >> 4);
  c &= 0x0fffffff;
  for (i = 0; i < 16; i++)
    {
      if(shifts2[i])
	{
	  c = ((c >> 2) | (c << 26));
	  d = ((d >> 2) | (d << 26));
	} 
      else
	{
	  c = ((c >> 1) | (c << 27));
	  d = ((d >> 1) | (d << 27));
	}
      c &= 0x0fffffff;
      d &= 0x0fffffff;
      s = des_skb[0][(c) & 0x3f] |
	des_skb[1][((c >> 6) & 0x03) | ((c >> 7) & 0x3c)] |
	des_skb[2][((c >> 13) & 0x0f) | ((c >> 14) & 0x30)] |
	des_skb[3][((c >> 20) & 0x01) | ((c >> 21) & 0x06) |
                  ((c >> 22) & 0x38)];
      t = des_skb[4][(d) & 0x3f] |
	des_skb[5][((d >> 7) & 0x03) | ((d >> 8) & 0x3c)] |
	des_skb[6][(d >> 15) & 0x3f] |
	des_skb[7][((d >> 21) & 0x0f) | ((d >> 22) & 0x30)];
      *(k++) = ((t << 16) | (s & 0x0000ffff));
      s = ((s >> 16) | (t & 0xffff0000));
      s = (s << 4) | (s >> 28);
      *(k++) = s;
    }
}
static unsigned long des_SPtrans[8][64] = {
  0x00820200, 0x00020000, 0x80800000, 0x80820200,
  0x00800000, 0x80020200, 0x80020000, 0x80800000,
  0x80020200, 0x00820200, 0x00820000, 0x80000200,
  0x80800200, 0x00800000, 0x00000000, 0x80020000,
  0x00020000, 0x80000000, 0x00800200, 0x00020200,
  0x80820200, 0x00820000, 0x80000200, 0x00800200,
  0x80000000, 0x00000200, 0x00020200, 0x80820000,
  0x00000200, 0x80800200, 0x80820000, 0x00000000,
  0x00000000, 0x80820200, 0x00800200, 0x80020000,
  0x00820200, 0x00020000, 0x80000200, 0x00800200,
  0x80820000, 0x00000200, 0x00020200, 0x80800000,
  0x80020200, 0x80000000, 0x80800000, 0x00820000,
  0x80820200, 0x00020200, 0x00820000, 0x80800200,
  0x00800000, 0x80000200, 0x80020000, 0x00000000,
  0x00020000, 0x00800000, 0x80800200, 0x00820200,
  0x80000000, 0x80820000, 0x00000200, 0x80020200,
  0x10042004, 0x00000000, 0x00042000, 0x10040000,
  0x10000004, 0x00002004, 0x10002000, 0x00042000,
  0x00002000, 0x10040004, 0x00000004, 0x10002000,
  0x00040004, 0x10042000, 0x10040000, 0x00000004,
  0x00040000, 0x10002004, 0x10040004, 0x00002000,
  0x00042004, 0x10000000, 0x00000000, 0x00040004,
  0x10002004, 0x00042004, 0x10042000, 0x10000004,
  0x10000000, 0x00040000, 0x00002004, 0x10042004,
  0x00040004, 0x10042000, 0x10002000, 0x00042004,
  0x10042004, 0x00040004, 0x10000004, 0x00000000,
  0x10000000, 0x00002004, 0x00040000, 0x10040004,
  0x00002000, 0x10000000, 0x00042004, 0x10002004,
  0x10042000, 0x00002000, 0x00000000, 0x10000004,
  0x00000004, 0x10042004, 0x00042000, 0x10040000,
  0x10040004, 0x00040000, 0x00002004, 0x10002000,
  0x10002004, 0x00000004, 0x10040000, 0x00042000,
  0x41000000, 0x01010040, 0x00000040, 0x41000040,
  0x40010000, 0x01000000, 0x41000040, 0x00010040,
  0x01000040, 0x00010000, 0x01010000, 0x40000000,
  0x41010040, 0x40000040, 0x40000000, 0x41010000,
  0x00000000, 0x40010000, 0x01010040, 0x00000040,
  0x40000040, 0x41010040, 0x00010000, 0x41000000,
  0x41010000, 0x01000040, 0x40010040, 0x01010000,
  0x00010040, 0x00000000, 0x01000000, 0x40010040,
  0x01010040, 0x00000040, 0x40000000, 0x00010000,
  0x40000040, 0x40010000, 0x01010000, 0x41000040,
  0x00000000, 0x01010040, 0x00010040, 0x41010000,
  0x40010000, 0x01000000, 0x41010040, 0x40000000,
  0x40010040, 0x41000000, 0x01000000, 0x41010040,
  0x00010000, 0x01000040, 0x41000040, 0x00010040,
  0x01000040, 0x00000000, 0x41010000, 0x40000040,
  0x41000000, 0x40010040, 0x00000040, 0x01010000,
  0x00100402, 0x04000400, 0x00000002, 0x04100402,
  0x00000000, 0x04100000, 0x04000402, 0x00100002,
  0x04100400, 0x04000002, 0x04000000, 0x00000402,
  0x04000002, 0x00100402, 0x00100000, 0x04000000,
  0x04100002, 0x00100400, 0x00000400, 0x00000002,
  0x00100400, 0x04000402, 0x04100000, 0x00000400,
  0x00000402, 0x00000000, 0x00100002, 0x04100400,
  0x04000400, 0x04100002, 0x04100402, 0x00100000,
  0x04100002, 0x00000402, 0x00100000, 0x04000002,
  0x00100400, 0x04000400, 0x00000002, 0x04100000,
  0x04000402, 0x00000000, 0x00000400, 0x00100002,
  0x00000000, 0x04100002, 0x04100400, 0x00000400,
  0x04000000, 0x04100402, 0x00100402, 0x00100000,
  0x04100402, 0x00000002, 0x04000400, 0x00100402,
  0x00100002, 0x00100400, 0x04100000, 0x04000402,
  0x00000402, 0x04000000, 0x04000002, 0x04100400,
  0x02000000, 0x00004000, 0x00000100, 0x02004108,
  0x02004008, 0x02000100, 0x00004108, 0x02004000,
  0x00004000, 0x00000008, 0x02000008, 0x00004100,
  0x02000108, 0x02004008, 0x02004100, 0x00000000,
  0x00004100, 0x02000000, 0x00004008, 0x00000108,
  0x02000100, 0x00004108, 0x00000000, 0x02000008,
  0x00000008, 0x02000108, 0x02004108, 0x00004008,
  0x02004000, 0x00000100, 0x00000108, 0x02004100,
  0x02004100, 0x02000108, 0x00004008, 0x02004000,
  0x00004000, 0x00000008, 0x02000008, 0x02000100,
  0x02000000, 0x00004100, 0x02004108, 0x00000000,
  0x00004108, 0x02000000, 0x00000100, 0x00004008,
  0x02000108, 0x00000100, 0x00000000, 0x02004108,
  0x02004008, 0x02004100, 0x00000108, 0x00004000,
  0x00004100, 0x02004008, 0x02000100, 0x00000108,
  0x00000008, 0x00004108, 0x02004000, 0x02000008,
  0x20000010, 0x00080010, 0x00000000, 0x20080800,
  0x00080010, 0x00000800, 0x20000810, 0x00080000,
  0x00000810, 0x20080810, 0x00080800, 0x20000000,
  0x20000800, 0x20000010, 0x20080000, 0x00080810,
  0x00080000, 0x20000810, 0x20080010, 0x00000000,
  0x00000800, 0x00000010, 0x20080800, 0x20080010,
  0x20080810, 0x20080000, 0x20000000, 0x00000810,
  0x00000010, 0x00080800, 0x00080810, 0x20000800,
  0x00000810, 0x20000000, 0x20000800, 0x00080810,
  0x20080800, 0x00080010, 0x00000000, 0x20000800,
  0x20000000, 0x00000800, 0x20080010, 0x00080000,
  0x00080010, 0x20080810, 0x00080800, 0x00000010,
  0x20080810, 0x00080800, 0x00080000, 0x20000810,
  0x20000010, 0x20080000, 0x00080810, 0x00000000,
  0x00000800, 0x20000010, 0x20000810, 0x20080800,
  0x20080000, 0x00000810, 0x00000010, 0x20080010,
  0x00001000, 0x00000080, 0x00400080, 0x00400001,
  0x00401081, 0x00001001, 0x00001080, 0x00000000,
  0x00400000, 0x00400081, 0x00000081, 0x00401000,
  0x00000001, 0x00401080, 0x00401000, 0x00000081,
  0x00400081, 0x00001000, 0x00001001, 0x00401081,
  0x00000000, 0x00400080, 0x00400001, 0x00001080,
  0x00401001, 0x00001081, 0x00401080, 0x00000001,
  0x00001081, 0x00401001, 0x00000080, 0x00400000,
  0x00001081, 0x00401000, 0x00401001, 0x00000081,
  0x00001000, 0x00000080, 0x00400000, 0x00401001,
  0x00400081, 0x00001081, 0x00001080, 0x00000000,
  0x00000080, 0x00400001, 0x00000001, 0x00400080,
  0x00000000, 0x00400081, 0x00400080, 0x00001080,
  0x00000081, 0x00001000, 0x00401081, 0x00400000,
  0x00401080, 0x00000001, 0x00001001, 0x00401081,
  0x00400001, 0x00401080, 0x00401000, 0x00001001,
  0x08200020, 0x08208000, 0x00008020, 0x00000000,
  0x08008000, 0x00200020, 0x08200000, 0x08208020,
  0x00000020, 0x08000000, 0x00208000, 0x00008020,
  0x00208020, 0x08008020, 0x08000020, 0x08200000,
  0x00008000, 0x00208020, 0x00200020, 0x08008000,
  0x08208020, 0x08000020, 0x00000000, 0x00208000,
  0x08000000, 0x00200000, 0x08008020, 0x08200020,
  0x00200000, 0x00008000, 0x08208000, 0x00000020,
  0x00200000, 0x00008000, 0x08000020, 0x08208020,
  0x00008020, 0x08000000, 0x00000000, 0x00208000,
  0x08200020, 0x08008020, 0x08008000, 0x00200020,
  0x08208000, 0x00000020, 0x00200020, 0x08008000,
  0x08208020, 0x00200000, 0x08200000, 0x08000020,
  0x00208000, 0x00008020, 0x08008020, 0x08200000,
  0x00000020, 0x08208000, 0x00208020, 0x00000000,
  0x08000000, 0x08200020, 0x00008000, 0x00208020};
int des_encrypt(ulong *, ulong *, ulong *, int);
ulong *input;
ulong *output;
ulong *ks;
int encrypt;
int des_ecb_encrypt(input, output, ks, encrypt)
     unsigned char *input;
     unsigned char *output;
     struct key *ks;
     int encrypt;
{
  register ulong l0, l1;
  register uchar *in, *out;
  ulong ll[2];
  in = (uchar *) input;
  out = (uchar *) output;
  (l0 = ((ulong) (*((in)++))), l0 |= ((ulong) (*((in)++))) << 8, l0 |= ((ulong) (*((in)++))) << 16, l0 |= ((ulong) (*((in)++))) << 24);
  (l1 = ((ulong) (*((in)++))), l1 |= ((ulong) (*((in)++))) << 8, l1 |= ((ulong) (*((in)++))) << 16, l1 |= ((ulong) (*((in)++))) << 24);
  ll[0] = l0;
  ll[1] = l1;
  des_encrypt((ulong *) ll, (ulong *) ll, (ulong *) ks, encrypt);
  l0 = ll[0];
  l1 = ll[1];
  (*((out)++) = (uchar) (((l0)) & 0xff), *((out)++) = (uchar) (((l0) >> 8) & 0xff), *((out)++) = (uchar) (((l0) >> 16) & 0xff), *((out)++) = (uchar) (((l0) >> 24) & 0xff));
  (*((out)++) = (uchar) (((l1)) & 0xff), *((out)++) = (uchar) (((l1) >> 8) & 0xff), *((out)++) = (uchar) (((l1) >> 16) & 0xff), *((out)++) = (uchar) (((l1) >> 24) & 0xff));
  return (0);
}

int des_encrypt(input, output, ks, encrypt)
     ulong *input;
     ulong *output;
     ulong *ks;
     int encrypt;
{
  register ulong l, r, t, u;
  register int i;
  register ulong *s;
  l = input[0];
  r = input[1];
  ((t) = ((((r) >> (4)) ^ (l)) & (0x0f0f0f0f)), (l) ^= (t), (r) ^= ((t) << (4)));
  ((t) = ((((l) >> (16)) ^ (r)) & (0x0000ffff)), (r) ^= (t), (l) ^= ((t) << (16)));
  ((t) = ((((r) >> (2)) ^ (l)) & (0x33333333)), (l) ^= (t), (r) ^= ((t) << (2)));
  ((t) = ((((l) >> (8)) ^ (r)) & (0x00ff00ff)), (r) ^= (t), (l) ^= ((t) << (8)));
  ((t) = ((((r) >> (1)) ^ (l)) & (0x55555555)), (l) ^= (t), (r) ^= ((t) << (1)));
  t = (r << 1) | (r >> 31);
  r = (l << 1) | (l >> 31);
  l = t;
  s = (ulong *) ks;
  if(encrypt)
    {
      for (i = 0; i < 32; i += 4)
	{
	  u = (r ^ s[i + 0]);
	  t = r ^ s[i + 0 + 1];
	  t = ((t >> 4) + (t << 28));
	  l ^= des_SPtrans[1][(t) & 0x3f] | des_SPtrans[3][(t >> 8) & 0x3f] | des_SPtrans[5][(t >> 16) & 0x3f] | des_SPtrans[7][(t >> 24) & 0x3f] | des_SPtrans[0][(u) & 0x3f] | des_SPtrans[2][(u >> 8) & 0x3f] | des_SPtrans[4][(u >> 16) & 0x3f] | des_SPtrans[6][(u >> 24) & 0x3f];;
	  u = (l ^ s[i + 2]);
	  t = l ^ s[i + 2 + 1];
	  t = ((t >> 4) + (t << 28));
	  r ^= des_SPtrans[1][(t) & 0x3f] | des_SPtrans[3][(t >> 8) & 0x3f] | des_SPtrans[5][(t >> 16) & 0x3f] | des_SPtrans[7][(t >> 24) & 0x3f] | des_SPtrans[0][(u) & 0x3f] | des_SPtrans[2][(u >> 8) & 0x3f] | des_SPtrans[4][(u >> 16) & 0x3f] | des_SPtrans[6][(u >> 24) & 0x3f];;
	}

    } 
  else
    {
      for (i = 30; i > 0; i -= 4)
	{
	  u = (r ^ s[i - 0]);
	  t = r ^ s[i - 0 + 1];
	  t = ((t >> 4) + (t << 28));
	  l ^= des_SPtrans[1][(t) & 0x3f] | des_SPtrans[3][(t >> 8) & 0x3f] | des_SPtrans[5][(t >> 16) & 0x3f] | des_SPtrans[7][(t >> 24) & 0x3f] | des_SPtrans[0][(u) & 0x3f] | des_SPtrans[2][(u >> 8) & 0x3f] | des_SPtrans[4][(u >> 16) & 0x3f] | des_SPtrans[6][(u >> 24) & 0x3f];;
	  u = (l ^ s[i - 2]);
	  t = l ^ s[i - 2 + 1];
	  t = ((t >> 4) + (t << 28));
	  r ^= des_SPtrans[1][(t) & 0x3f] | des_SPtrans[3][(t >> 8) & 0x3f] | des_SPtrans[5][(t >> 16) & 0x3f] | des_SPtrans[7][(t >> 24) & 0x3f] | des_SPtrans[0][(u) & 0x3f] | des_SPtrans[2][(u >> 8) & 0x3f] | des_SPtrans[4][(u >> 16) & 0x3f] | des_SPtrans[6][(u >> 24) & 0x3f];;
	}

    }
  l = (l >> 1) | (l << 31);
  r = (r >> 1) | (r << 31);
  ((t) = ((((r) >> (1)) ^ (l)) & (0x55555555)), (l) ^= (t), (r) ^= ((t) << (1)));
  ((t) = ((((l) >> (8)) ^ (r)) & (0x00ff00ff)), (r) ^= (t), (l) ^= ((t) << (8)));
  ((t) = ((((r) >> (2)) ^ (l)) & (0x33333333)), (l) ^= (t), (r) ^= ((t) << (2)));
  ((t) = ((((l) >> (16)) ^ (r)) & (0x0000ffff)), (r) ^= (t), (l) ^= ((t) << (16)));
  ((t) = ((((r) >> (4)) ^ (l)) & (0x0f0f0f0f)), (l) ^= (t), (r) ^= ((t) << (4)));
  output[0] = l;
  output[1] = r;
  return (0);
}

struct test8
{
  unsigned char key[8];
  unsigned char plain[8];
  unsigned char cipher[8];
};
struct test8 test8[] =
{
  {
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef}

    ,
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xe7}

    ,
    {0xc9, 0x57, 0x44, 0x25, 0x6a, 0x5e, 0xd3, 0x1d}

  }
  ,
  {
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0x8c, 0xa6, 0x4d, 0xe9, 0xc1, 0xb1, 0x23, 0xa7}

  }
  ,
  {
    {0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01}

    ,
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0x8c, 0xa6, 0x4d, 0xe9, 0xc1, 0xb1, 0x23, 0xa7}

  }
  ,
  {
    {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff}

    ,
    {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff}

    ,
    {0x73, 0x59, 0xb2, 0x16, 0x3e, 0x4e, 0xdc, 0x58}

  }
  ,
  {
    {0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe}

    ,
    {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff}

    ,
    {0x73, 0x59, 0xb2, 0x16, 0x3e, 0x4e, 0xdc, 0x58}

  }
  ,
  {
    {0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe}

    ,
    {0x98, 0x23, 0x87, 0x36, 0x21, 0x83, 0x76, 0x78}

    ,
    {0x17, 0x3c, 0x55, 0x0d, 0xec, 0xed, 0x78, 0x65}

  }
  ,
  {
    {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11}

    ,
    {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11}

    ,
    {0xf4, 0x03, 0x79, 0xab, 0x9e, 0x0e, 0xc5, 0x33}

  }
  ,
  {
    {0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22}

    ,
    {0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22}

    ,
    {0x0f, 0x8a, 0xdf, 0xfb, 0x11, 0xdc, 0x27, 0x84}

  }
  ,
  {
    {0x62, 0x34, 0x86, 0x83, 0x27, 0x46, 0x82, 0x37}

    ,
    {0x83, 0x34, 0x67, 0x52, 0x73, 0x65, 0x76, 0x23}

    ,
    {0x5b, 0x78, 0xee, 0x69, 0x4f, 0x5c, 0xd9, 0xd5}

  }
  ,
  {
    {0x5f, 0xe7, 0x27, 0x3a, 0x32, 0x1d, 0xdc, 0xdf}

    ,
    {0x19, 0x68, 0xe7, 0xfe, 0x54, 0x1e, 0x07, 0x1f}

    ,
    {0x6b, 0xa7, 0x42, 0x7b, 0x54, 0x2c, 0xa7, 0x4e}

  }
  ,
  {
    {0xaa, 0x11, 0xa7, 0x25, 0xd9, 0x84, 0x54, 0x3f}

    ,
    {0x3a, 0xd3, 0xdd, 0x67, 0x43, 0xe4, 0x2c, 0xd9}

    ,
    {0x51, 0x4d, 0x7e, 0x3d, 0x74, 0x43, 0xc5, 0xa8}

  }
  ,
  {
    {0x3d, 0x9a, 0xb7, 0x00, 0x87, 0x71, 0x21, 0x5d}

    ,
    {0xc4, 0x47, 0x60, 0x15, 0xae, 0x6d, 0xdb, 0x83}

    ,
    {0xc7, 0xe4, 0x6d, 0x07, 0x9e, 0x41, 0xec, 0x22}

  }
  ,
  {
    {0xd6, 0x9c, 0xc9, 0xc8, 0xa7, 0xa6, 0x32, 0xfa}

    ,
    {0x28, 0xf9, 0x9b, 0xda, 0xb3, 0x49, 0xa0, 0xa3}

    ,
    {0x19, 0xbb, 0x4e, 0x04, 0x0e, 0xe8, 0x76, 0x09}

  }
  ,
  {
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0x8C, 0xA6, 0x4D, 0xE9, 0xC1, 0xB1, 0x23, 0xA7}

  }
  ,
  {
    {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}

    ,
    {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}

    ,
    {0x73, 0x59, 0xB2, 0x16, 0x3E, 0x4E, 0xDC, 0x58}

  }
  ,
  {
    {0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01}

    ,
    {0x95, 0x8E, 0x6E, 0x62, 0x7A, 0x05, 0x55, 0x7B}

  }
  ,
  {
    {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11}

    ,
    {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11}

    ,
    {0xF4, 0x03, 0x79, 0xAB, 0x9E, 0x0E, 0xC5, 0x33}

  }
  ,
  {
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}

    ,
    {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11}

    ,
    {0x17, 0x66, 0x8D, 0xFC, 0x72, 0x92, 0x53, 0x2D}

  }
  ,
  {
    {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11}

    ,
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}

    ,
    {0x8A, 0x5A, 0xE1, 0xF8, 0x1A, 0xB8, 0xF2, 0xDD}

  }
  ,
  {
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0x8C, 0xA6, 0x4D, 0xE9, 0xC1, 0xB1, 0x23, 0xA7}

  }
  ,
  {
    {0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10}

    ,
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}

    ,
    {0xED, 0x39, 0xD9, 0x50, 0xFA, 0x74, 0xBC, 0xC4}

  }
  ,
  {
    {0x7C, 0xA1, 0x10, 0x45, 0x4A, 0x1A, 0x6E, 0x57}

    ,
    {0x01, 0xA1, 0xD6, 0xD0, 0x39, 0x77, 0x67, 0x42}

    ,
    {0x69, 0x0F, 0x5B, 0x0D, 0x9A, 0x26, 0x93, 0x9B}

  }
  ,
  {
    {0x01, 0x31, 0xD9, 0x61, 0x9D, 0xC1, 0x37, 0x6E}

    ,
    {0x5C, 0xD5, 0x4C, 0xA8, 0x3D, 0xEF, 0x57, 0xDA}

    ,
    {0x7A, 0x38, 0x9D, 0x10, 0x35, 0x4B, 0xD2, 0x71}

  }
  ,
  {
    {0x07, 0xA1, 0x13, 0x3E, 0x4A, 0x0B, 0x26, 0x86}

    ,
    {0x02, 0x48, 0xD4, 0x38, 0x06, 0xF6, 0x71, 0x72}

    ,
    {0x86, 0x8E, 0xBB, 0x51, 0xCA, 0xB4, 0x59, 0x9A}

  }
  ,
  {
    {0x38, 0x49, 0x67, 0x4C, 0x26, 0x02, 0x31, 0x9E}

    ,
    {0x51, 0x45, 0x4B, 0x58, 0x2D, 0xDF, 0x44, 0x0A}

    ,
    {0x71, 0x78, 0x87, 0x6E, 0x01, 0xF1, 0x9B, 0x2A}

  }
  ,
  {
    {0x04, 0xB9, 0x15, 0xBA, 0x43, 0xFE, 0xB5, 0xB6}

    ,
    {0x42, 0xFD, 0x44, 0x30, 0x59, 0x57, 0x7F, 0xA2}

    ,
    {0xAF, 0x37, 0xFB, 0x42, 0x1F, 0x8C, 0x40, 0x95}

  }
  ,
  {
    {0x01, 0x13, 0xB9, 0x70, 0xFD, 0x34, 0xF2, 0xCE}

    ,
    {0x05, 0x9B, 0x5E, 0x08, 0x51, 0xCF, 0x14, 0x3A}

    ,
    {0x86, 0xA5, 0x60, 0xF1, 0x0E, 0xC6, 0xD8, 0x5B}

  }
  ,
  {
    {0x01, 0x70, 0xF1, 0x75, 0x46, 0x8F, 0xB5, 0xE6}

    ,
    {0x07, 0x56, 0xD8, 0xE0, 0x77, 0x47, 0x61, 0xD2}

    ,
    {0x0C, 0xD3, 0xDA, 0x02, 0x00, 0x21, 0xDC, 0x09}

  }
  ,
  {
    {0x43, 0x29, 0x7F, 0xAD, 0x38, 0xE3, 0x73, 0xFE}

    ,
    {0x76, 0x25, 0x14, 0xB8, 0x29, 0xBF, 0x48, 0x6A}

    ,
    {0xEA, 0x67, 0x6B, 0x2C, 0xB7, 0xDB, 0x2B, 0x7A}

  }
  ,
  {
    {0x07, 0xA7, 0x13, 0x70, 0x45, 0xDA, 0x2A, 0x16}

    ,
    {0x3B, 0xDD, 0x11, 0x90, 0x49, 0x37, 0x28, 0x02}

    ,
    {0xDF, 0xD6, 0x4A, 0x81, 0x5C, 0xAF, 0x1A, 0x0F}

  }
  ,
  {
    {0x04, 0x68, 0x91, 0x04, 0xC2, 0xFD, 0x3B, 0x2F}

    ,
    {0x26, 0x95, 0x5F, 0x68, 0x35, 0xAF, 0x60, 0x9A}

    ,
    {0x5C, 0x51, 0x3C, 0x9C, 0x48, 0x86, 0xC0, 0x88}

  }
  ,
  {
    {0x37, 0xD0, 0x6B, 0xB5, 0x16, 0xCB, 0x75, 0x46}

    ,
    {0x16, 0x4D, 0x5E, 0x40, 0x4F, 0x27, 0x52, 0x32}

    ,
    {0x0A, 0x2A, 0xEE, 0xAE, 0x3F, 0xF4, 0xAB, 0x77}

  }
  ,
  {
    {0x1F, 0x08, 0x26, 0x0D, 0x1A, 0xC2, 0x46, 0x5E}

    ,
    {0x6B, 0x05, 0x6E, 0x18, 0x75, 0x9F, 0x5C, 0xCA}

    ,
    {0xEF, 0x1B, 0xF0, 0x3E, 0x5D, 0xFA, 0x57, 0x5A}

  }
  ,
  {
    {0x58, 0x40, 0x23, 0x64, 0x1A, 0xBA, 0x61, 0x76}

    ,
    {0x00, 0x4B, 0xD6, 0xEF, 0x09, 0x17, 0x60, 0x62}

    ,
    {0x88, 0xBF, 0x0D, 0xB6, 0xD7, 0x0D, 0xEE, 0x56}

  }
  ,
  {
    {0x02, 0x58, 0x16, 0x16, 0x46, 0x29, 0xB0, 0x07}

    ,
    {0x48, 0x0D, 0x39, 0x00, 0x6E, 0xE7, 0x62, 0xF2}

    ,
    {0xA1, 0xF9, 0x91, 0x55, 0x41, 0x02, 0x0B, 0x56}

  }
  ,
  {
    {0x49, 0x79, 0x3E, 0xBC, 0x79, 0xB3, 0x25, 0x8F}

    ,
    {0x43, 0x75, 0x40, 0xC8, 0x69, 0x8F, 0x3C, 0xFA}

    ,
    {0x6F, 0xBF, 0x1C, 0xAF, 0xCF, 0xFD, 0x05, 0x56}

  }
  ,
  {
    {0x4F, 0xB0, 0x5E, 0x15, 0x15, 0xAB, 0x73, 0xA7}

    ,
    {0x07, 0x2D, 0x43, 0xA0, 0x77, 0x07, 0x52, 0x92}

    ,
    {0x2F, 0x22, 0xE4, 0x9B, 0xAB, 0x7C, 0xA1, 0xAC}

  }
  ,
  {
    {0x49, 0xE9, 0x5D, 0x6D, 0x4C, 0xA2, 0x29, 0xBF}

    ,
    {0x02, 0xFE, 0x55, 0x77, 0x81, 0x17, 0xF1, 0x2A}

    ,
    {0x5A, 0x6B, 0x61, 0x2C, 0xC2, 0x6C, 0xCE, 0x4A}

  }
  ,
  {
    {0x01, 0x83, 0x10, 0xDC, 0x40, 0x9B, 0x26, 0xD6}

    ,
    {0x1D, 0x9D, 0x5C, 0x50, 0x18, 0xF7, 0x28, 0xC2}

    ,
    {0x5F, 0x4C, 0x03, 0x8E, 0xD1, 0x2B, 0x2E, 0x41}

  }
  ,
  {
    {0x1C, 0x58, 0x7F, 0x1C, 0x13, 0x92, 0x4F, 0xEF}

    ,
    {0x30, 0x55, 0x32, 0x28, 0x6D, 0x6F, 0x29, 0x5A}

    ,
    {0x63, 0xFA, 0xC0, 0xD0, 0x34, 0xD9, 0xF7, 0x93}

  }
  ,
  {
    {0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01}

    ,
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}

    ,
    {0x61, 0x7B, 0x3A, 0x0C, 0xE8, 0xF0, 0x71, 0x00}

  }
  ,
  {
    {0x1F, 0x1F, 0x1F, 0x1F, 0x0E, 0x0E, 0x0E, 0x0E}

    ,
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}

    ,
    {0xDB, 0x95, 0x86, 0x05, 0xF8, 0xC8, 0xC6, 0x06}

  }
  ,
  {
    {0xE0, 0xFE, 0xE0, 0xFE, 0xF1, 0xFE, 0xF1, 0xFE}

    ,
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}

    ,
    {0xED, 0xBF, 0xD1, 0xC6, 0x6C, 0x29, 0xCC, 0xC7}

  }
  ,
  {
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}

    ,
    {0x35, 0x55, 0x50, 0xB2, 0x15, 0x0E, 0x24, 0x51}

  }
  ,
  {
    {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}

    ,
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0xCA, 0xAA, 0xAF, 0x4D, 0xEA, 0xF1, 0xDB, 0xAE}

  }
  ,
  {
    {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}

    ,
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

    ,
    {0xD5, 0xD4, 0x4F, 0xF7, 0x20, 0x68, 0x3D, 0x0D}

  }
  ,
  {
    {0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10}

    ,
    {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}

    ,
    {0x2A, 0x2B, 0xB0, 0x08, 0xDF, 0x97, 0xC2, 0xF2}

  }
  ,
};
beq(a, b, z)
     unsigned char *a, *b;
     int z;
{
  while (--z >= 0)
    if(*a++ != *b++)
      return (0);
  return (1);
}

unsigned long keys[32];
maindes()
{
	int k;
	int l;
	for (l = 0; l < 10; l++) {
		for (k = 0; k < 100; k++) {
			struct test8 *t;
			unsigned char cipher[16];
			int i;
			for (i = 0, t = test8; i < (sizeof(test8) / sizeof(test8[0])); i++, t++)
			{
				des_set_key(t->key, (struct key *) keys);
				des_ecb_encrypt(t->plain, cipher, (struct key *) keys, 1);
			}
		}
		rvex_succeed("d");
	}
	return 0;
}
