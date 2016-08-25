#include "gfx.h"

static const unsigned short sans12_data[515] = {
  0x0000, 0x0000, 0x0000, 0x06FC, 0x001C, 0x0000, 0x001C, 0x0100, 0x0520, 0x03E0, 
  0x0138, 0x0720, 0x01F0, 0x0128, 0x0020, 0x0270, 0x0448, 0x1FFC, 0x0488, 0x0390, 
  0x0038, 0x0044, 0x0444, 0x0338, 0x00C0, 0x0060, 0x0398, 0x0444, 0x0440, 0x0380, 
  0x0380, 0x0678, 0x0424, 0x0444, 0x0488, 0x0300, 0x0500, 0x04C0, 0x001C, 0x01F0, 
  0x0E0E, 0x0802, 0x0802, 0x0E0E, 0x01F0, 0x0048, 0x0030, 0x00FC, 0x0030, 0x0048, 
  0x0080, 0x0080, 0x0080, 0x07F0, 0x0080, 0x0080, 0x0080, 0x0E00, 0x0080, 0x0080, 
  0x0080, 0x0600, 0x0C00, 0x0380, 0x0070, 0x000C, 0x01F0, 0x060C, 0x0404, 0x0404, 
  0x060C, 0x01F0, 0x0404, 0x0404, 0x07FC, 0x0400, 0x0400, 0x0408, 0x0604, 0x0504, 
  0x0484, 0x044C, 0x0438, 0x0208, 0x0404, 0x0444, 0x0444, 0x0444, 0x03B8, 0x0180, 
  0x0160, 0x0110, 0x010C, 0x07FC, 0x0100, 0x023C, 0x0424, 0x0424, 0x0424, 0x0664, 
  0x03C0, 0x01F0, 0x0648, 0x0424, 0x0424, 0x0664, 0x03C8, 0x0004, 0x0404, 0x0304, 
  0x00C4, 0x0034, 0x000C, 0x03B8, 0x0444, 0x0444, 0x0444, 0x0444, 0x03B8, 0x0278, 
  0x04CC, 0x0484, 0x0484, 0x024C, 0x01F0, 0x0660, 0x0E60, 0x00C0, 0x00C0, 0x00C0, 
  0x0120, 0x0120, 0x0120, 0x0330, 0x0210, 0x0140, 0x0140, 0x0140, 0x0140, 0x0140, 
  0x0140, 0x0140, 0x0140, 0x0210, 0x0330, 0x0120, 0x0120, 0x0120, 0x00C0, 0x00C0, 
  0x00C0, 0x0008, 0x0004, 0x06C4, 0x0024, 0x0018, 0x03E0, 0x0410, 0x0808, 0x11C4, 
  0x1224, 0x1224, 0x1224, 0x13E4, 0x0A08, 0x0118, 0x00E0, 0x0400, 0x0380, 0x0170, 
  0x010C, 0x010C, 0x0170, 0x0380, 0x0400, 0x07FC, 0x0444, 0x0444, 0x0444, 0x0444, 
  0x03B8, 0x01F0, 0x0208, 0x0404, 0x0404, 0x0404, 0x0208, 0x07FC, 0x0404, 0x0404, 
  0x0404, 0x0404, 0x0208, 0x01F0, 0x07FC, 0x0444, 0x0444, 0x0444, 0x0444, 0x0444, 
  0x07FC, 0x0044, 0x0044, 0x0044, 0x0044, 0x01F0, 0x0208, 0x0404, 0x0404, 0x0444, 
  0x0444, 0x03C8, 0x07FC, 0x0040, 0x0040, 0x0040, 0x0040, 0x0040, 0x07FC, 0x07FC, 
  0x1000, 0x1000, 0x0FFC, 0x07FC, 0x0040, 0x00A0, 0x0110, 0x0208, 0x0404, 0x07FC, 
  0x0400, 0x0400, 0x0400, 0x0400, 0x07FC, 0x0018, 0x0060, 0x0180, 0x0180, 0x0060, 
  0x0018, 0x07FC, 0x07FC, 0x000C, 0x0030, 0x0040, 0x0180, 0x0600, 0x07FC, 0x01F0, 
  0x0208, 0x0404, 0x0404, 0x0404, 0x0208, 0x01F0, 0x07FC, 0x0044, 0x0044, 0x0044, 
  0x0044, 0x0038, 0x01F0, 0x0208, 0x0404, 0x0404, 0x0C04, 0x1208, 0x01F0, 0x07FC, 
  0x0044, 0x0044, 0x0044, 0x00C4, 0x0338, 0x0400, 0x0238, 0x0444, 0x0444, 0x0444, 
  0x0444, 0x0388, 0x0004, 0x0004, 0x0004, 0x07FC, 0x0004, 0x0004, 0x0004, 0x03FC, 
  0x0600, 0x0400, 0x0400, 0x0400, 0x0600, 0x03FC, 0x000C, 0x0070, 0x0180, 0x0600, 
  0x0600, 0x0180, 0x0070, 0x000C, 0x0004, 0x0038, 0x01C0, 0x0600, 0x01E0, 0x001C, 
  0x01E0, 0x0600, 0x01C0, 0x0038, 0x0004, 0x0404, 0x020C, 0x01B0, 0x0040, 0x01B0, 
  0x020C, 0x0404, 0x0004, 0x0018, 0x0060, 0x0780, 0x0060, 0x0018, 0x0004, 0x0604, 
  0x0504, 0x0484, 0x0444, 0x0424, 0x0414, 0x040C, 0x1FFC, 0x1004, 0x000C, 0x0070, 
  0x0380, 0x0C00, 0x1004, 0x1FFC, 0x0010, 0x0008, 0x0004, 0x0004, 0x0008, 0x0010, 
  0x2000, 0x2000, 0x2000, 0x2000, 0x2000, 0x2000, 0x0002, 0x0004, 0x0320, 0x0490, 
  0x0490, 0x0490, 0x0290, 0x07E0, 0x07FE, 0x0630, 0x0410, 0x0410, 0x0630, 0x03E0, 
  0x03E0, 0x0630, 0x0410, 0x0410, 0x0220, 0x03E0, 0x0630, 0x0410, 0x0410, 0x0630, 
  0x07FE, 0x03E0, 0x06B0, 0x0490, 0x0490, 0x04B0, 0x02E0, 0x0010, 0x07FC, 0x0012, 
  0x0012, 0x03E0, 0x1630, 0x2410, 0x2410, 0x3630, 0x1FF0, 0x07FE, 0x0020, 0x0010, 
  0x0010, 0x0010, 0x07E0, 0x07F4, 0x2000, 0x3FF4, 0x07FE, 0x0080, 0x0140, 0x0220, 
  0x0410, 0x07FE, 0x07F0, 0x0010, 0x0010, 0x0010, 0x07E0, 0x0010, 0x0010, 0x0010, 
  0x07E0, 0x07F0, 0x0020, 0x0010, 0x0010, 0x0010, 0x07E0, 0x03E0, 0x0630, 0x0410, 
  0x0410, 0x0630, 0x03E0, 0x3FF0, 0x0630, 0x0410, 0x0410, 0x0630, 0x03E0, 0x03E0, 
  0x0630, 0x0410, 0x0410, 0x0630, 0x3FF0, 0x07F0, 0x0020, 0x0010, 0x0010, 0x0260, 
  0x0490, 0x0490, 0x0490, 0x0320, 0x0010, 0x07FC, 0x0410, 0x0410, 0x03F0, 0x0400, 
  0x0400, 0x0400, 0x0200, 0x07F0, 0x0030, 0x01C0, 0x0600, 0x0600, 0x01C0, 0x0030, 
  0x0030, 0x01C0, 0x0600, 0x01C0, 0x0030, 0x01C0, 0x0600, 0x01C0, 0x0030, 0x0410, 
  0x0360, 0x0080, 0x0080, 0x0360, 0x0410, 0x2030, 0x20C0, 0x1300, 0x0E00, 0x01C0, 
  0x0030, 0x0610, 0x0510, 0x0490, 0x0450, 0x0430, 0x0080, 0x0080, 0x1F7C, 0x1004, 
  0x1004, 0x3FFC, 0x1004, 0x1004, 0x1F7C, 0x0080, 0x0080, 0x0080, 0x0040, 0x0040, 
  0x0040, 0x0080, 0x0080, 0x0080, 0x0040
};

const font_t sans12 = {
  13, // height
  { // info
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
    0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x0803, 0x1804, 0x4007, 
    0x280F, 0x5014, 0x401E, 0x0826, 0x1827, 0x182A, 0x282D, 0x3832, 0x0839, 
    0x183A, 0x083D, 0x203E, 0x3042, 0x2848, 0x304D, 0x3053, 0x3059, 0x305F, 
    0x3065, 0x306B, 0x3071, 0x3077, 0x087D, 0x087E, 0x407F, 0x4087, 0x408F, 
    0x2897, 0x589C, 0x40A7, 0x30AF, 0x30B5, 0x38BB, 0x30C2, 0x28C8, 0x38CD, 
    0x38D4, 0x08DB, 0x18DC, 0x30DF, 0x28E5, 0x40EA, 0x38F2, 0x38F9, 0x3100, 
    0x3906, 0x390D, 0x3114, 0x391A, 0x3921, 0x4128, 0x5930, 0x393B, 0x3942, 
    0x3949, 0x1150, 0x2152, 0x1156, 0x3158, 0x315E, 0x1164, 0x3166, 0x316C, 
    0x2972, 0x3177, 0x317D, 0x2183, 0x3187, 0x318D, 0x0993, 0x1194, 0x2996, 
    0x099B, 0x499C, 0x31A5, 0x31AB, 0x31B1, 0x31B7, 0x21BD, 0x29C1, 0x21C6, 
    0x31CA, 0x31D0, 0x49D6, 0x31DF, 0x31E5, 0x29EB, 0x29F0, 0x09F5, 0x29F6, 
    0x41FB, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 0x1800, 
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
  sans12_data
};
