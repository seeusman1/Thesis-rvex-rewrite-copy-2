#include "gfx.h"

static const unsigned short sans9_data[385] = {
  0x0000, 0x0000, 0x0000, 0x017C, 0x000C, 0x0000, 0x000C, 0x0050, 0x01D0, 0x007C, 
  0x01D0, 0x007C, 0x0050, 0x0130, 0x0128, 0x03FC, 0x0148, 0x00C8, 0x003C, 0x0024, 
  0x01BC, 0x0060, 0x0030, 0x01EC, 0x0120, 0x01E0, 0x00C0, 0x0138, 0x0124, 0x00C4, 
  0x0188, 0x0160, 0x000C, 0x00FC, 0x0102, 0x0186, 0x0078, 0x0024, 0x0018, 0x003C, 
  0x0018, 0x0024, 0x0040, 0x0040, 0x01F0, 0x0040, 0x0040, 0x0300, 0x0040, 0x0040, 
  0x0100, 0x0180, 0x0070, 0x000C, 0x00F8, 0x0104, 0x0104, 0x00F8, 0x0104, 0x01FC, 
  0x0100, 0x0188, 0x0144, 0x0124, 0x0118, 0x0108, 0x0124, 0x0124, 0x00D8, 0x00C0, 
  0x00B0, 0x0088, 0x01FC, 0x0080, 0x013C, 0x0124, 0x0124, 0x00C4, 0x00F8, 0x012C, 
  0x0124, 0x00C4, 0x0004, 0x0184, 0x0074, 0x000C, 0x00D8, 0x0124, 0x0124, 0x00D8, 
  0x0138, 0x0124, 0x01A4, 0x00F8, 0x0110, 0x0310, 0x0040, 0x0040, 0x00A0, 0x00A0, 
  0x00A0, 0x0110, 0x00A0, 0x00A0, 0x00A0, 0x00A0, 0x00A0, 0x00A0, 0x0110, 0x00A0, 
  0x00A0, 0x00A0, 0x0040, 0x0040, 0x0004, 0x0164, 0x0014, 0x000C, 0x00F0, 0x0108, 
  0x0264, 0x0294, 0x0294, 0x01F4, 0x0088, 0x0070, 0x0180, 0x0070, 0x004C, 0x004C, 
  0x0070, 0x0180, 0x01FC, 0x0124, 0x0124, 0x0124, 0x00D8, 0x00F8, 0x018C, 0x0104, 
  0x0104, 0x0108, 0x01FC, 0x0104, 0x0104, 0x018C, 0x00F8, 0x01FC, 0x0124, 0x0124, 
  0x0124, 0x01FC, 0x0024, 0x0024, 0x0024, 0x00F8, 0x018C, 0x0104, 0x0124, 0x00E8, 
  0x01FC, 0x0020, 0x0020, 0x0020, 0x01FC, 0x01FC, 0x0400, 0x03FC, 0x01FC, 0x0020, 
  0x0050, 0x0088, 0x0104, 0x01FC, 0x0100, 0x0100, 0x0100, 0x01FC, 0x0018, 0x0060, 
  0x0060, 0x0018, 0x01FC, 0x01FC, 0x0018, 0x0020, 0x00C0, 0x01FC, 0x00F8, 0x018C, 
  0x0104, 0x018C, 0x00F8, 0x01FC, 0x0024, 0x0024, 0x0018, 0x00F8, 0x018C, 0x0104, 
  0x038C, 0x00F8, 0x01FC, 0x0024, 0x0064, 0x009C, 0x0100, 0x0098, 0x0124, 0x0124, 
  0x0124, 0x00C8, 0x0004, 0x0004, 0x01FC, 0x0004, 0x0004, 0x00FC, 0x0100, 0x0100, 
  0x0100, 0x00FC, 0x000C, 0x0070, 0x0180, 0x0180, 0x0070, 0x000C, 0x000C, 0x0070, 
  0x01C0, 0x003C, 0x01C0, 0x0070, 0x000C, 0x0104, 0x008C, 0x0070, 0x0070, 0x018C, 
  0x0104, 0x0004, 0x0018, 0x01E0, 0x0018, 0x0004, 0x0184, 0x0144, 0x0124, 0x0114, 
  0x010C, 0x03FC, 0x0204, 0x000C, 0x0070, 0x0180, 0x0204, 0x03FC, 0x0008, 0x0004, 
  0x0004, 0x0008, 0x0400, 0x0400, 0x0400, 0x0400, 0x0400, 0x0002, 0x0004, 0x01C0, 
  0x0150, 0x0150, 0x01F0, 0x01FE, 0x0110, 0x0110, 0x00E0, 0x00E0, 0x0110, 0x0110, 
  0x0110, 0x00E0, 0x0110, 0x0110, 0x01FE, 0x00E0, 0x0150, 0x0150, 0x0160, 0x0010, 
  0x01FE, 0x0012, 0x0002, 0x00E0, 0x0510, 0x0510, 0x03F0, 0x01FE, 0x0010, 0x0010, 
  0x01F0, 0x01F4, 0x0400, 0x07F4, 0x01FE, 0x0040, 0x00A0, 0x0110, 0x01FE, 0x01F0, 
  0x0010, 0x0010, 0x01F0, 0x0010, 0x0010, 0x01F0, 0x01F0, 0x0010, 0x0010, 0x01F0, 
  0x00E0, 0x0110, 0x0110, 0x00E0, 0x07F0, 0x0110, 0x0110, 0x00E0, 0x00E0, 0x0110, 
  0x0110, 0x07F0, 0x01F0, 0x0010, 0x0010, 0x0130, 0x0150, 0x01D0, 0x0010, 0x01F8, 
  0x0110, 0x0110, 0x01F0, 0x0100, 0x0100, 0x01F0, 0x0030, 0x00C0, 0x0100, 0x00C0, 
  0x0030, 0x0070, 0x0180, 0x0060, 0x0010, 0x0060, 0x0180, 0x0070, 0x0110, 0x00A0, 
  0x0040, 0x00A0, 0x0110, 0x0430, 0x04C0, 0x0300, 0x00C0, 0x0030, 0x0110, 0x0190, 
  0x0150, 0x0130, 0x0020, 0x03DC, 0x0204, 0x07FC, 0x0204, 0x03DC, 0x0020, 0x0040, 
  0x0020, 0x0020, 0x0040, 0x0040, 0x0020
};

const font_t sans9 = {
  10, // height
  { // info
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x0803, 0x1804, 0x3007, 
    0x280D, 0x4012, 0x301A, 0x0820, 0x1021, 0x1023, 0x2825, 0x282A, 0x082F, 
    0x1030, 0x0832, 0x1833, 0x2036, 0x183A, 0x203D, 0x2041, 0x2845, 0x204A, 
    0x204E, 0x2052, 0x2056, 0x205A, 0x085E, 0x085F, 0x3060, 0x3066, 0x306C, 
    0x2072, 0x4076, 0x307E, 0x2884, 0x2889, 0x288E, 0x2093, 0x2097, 0x289B, 
    0x28A0, 0x08A5, 0x10A6, 0x28A8, 0x20AD, 0x30B1, 0x28B7, 0x28BC, 0x20C1, 
    0x28C5, 0x28CA, 0x28CF, 0x28D4, 0x28D9, 0x30DE, 0x38E4, 0x30EB, 0x28F1, 
    0x28F6, 0x10FB, 0x18FD, 0x1100, 0x2102, 0x2906, 0x110B, 0x210D, 0x2111, 
    0x2115, 0x2119, 0x211D, 0x2121, 0x2125, 0x2129, 0x092D, 0x112E, 0x2130, 
    0x0934, 0x3935, 0x213C, 0x2140, 0x2144, 0x2148, 0x194C, 0x194F, 0x2152, 
    0x2156, 0x295A, 0x395F, 0x2966, 0x296B, 0x2170, 0x1974, 0x0977, 0x1978, 
    0x317B, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800
  },
  sans9_data
};
