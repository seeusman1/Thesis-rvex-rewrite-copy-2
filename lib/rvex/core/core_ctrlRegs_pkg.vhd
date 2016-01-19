-- r-VEX processor
-- Copyright (C) 2008-2015 by TU Delft.
-- All Rights Reserved.

-- THIS IS A LEGAL DOCUMENT, BY USING r-VEX,
-- YOU ARE AGREEING TO THESE TERMS AND CONDITIONS.

-- No portion of this work may be used by any commercial entity, or for any
-- commercial purpose, without the prior, written permission of TU Delft.
-- Nonprofit and noncommercial use is permitted as described below.

-- 1. r-VEX is provided AS IS, with no warranty of any kind, express
-- or implied. The user of the code accepts full responsibility for the
-- application of the code and the use of any results.

-- 2. Nonprofit and noncommercial use is encouraged. r-VEX may be
-- downloaded, compiled, synthesized, copied, and modified solely for nonprofit,
-- educational, noncommercial research, and noncommercial scholarship
-- purposes provided that this notice in its entirety accompanies all copies.
-- Copies of the modified software can be delivered to persons who use it
-- solely for nonprofit, educational, noncommercial research, and
-- noncommercial scholarship purposes provided that this notice in its
-- entirety accompanies all copies.

-- 3. ALL COMMERCIAL USE, AND ALL USE BY FOR PROFIT ENTITIES, IS EXPRESSLY
-- PROHIBITED WITHOUT A LICENSE FROM TU Delft (J.S.S.M.Wong@tudelft.nl).

-- 4. No nonprofit user may place any restrictions on the use of this software,
-- including as modified by the user, by any other authorized user.

-- 5. Noncommercial and nonprofit users may distribute copies of r-VEX
-- in compiled or binary form as set forth in Section 2, provided that
-- either: (A) it is accompanied by the corresponding machine-readable source
-- code, or (B) it is accompanied by a written offer, with no time limit, to
-- give anyone a machine-readable copy of the corresponding source code in
-- return for reimbursement of the cost of distribution. This written offer
-- must permit verbatim duplication by anyone, or (C) it is distributed by
-- someone who received only the executable form, and is accompanied by a
-- copy of the written offer of source code.

-- 6. r-VEX was developed by Stephan Wong, Thijs van As, Fakhar Anjam,
-- Roel Seedorf, Anthony Brandon, Jeroen van Straten. r-VEX is currently
-- maintained by TU Delft (J.S.S.M.Wong@tudelft.nl).

-- Copyright (C) 2008-2015 by TU Delft.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library rvex;
use rvex.common_pkg.all;

--=============================================================================
-- This package contains constants specifying the word addresses of the control
-- registers as accessed from the debug bus or by a memory unit. It also
-- contains methods which generate register logic for several different kinds
-- of registers.
-------------------------------------------------------------------------------
package core_ctrlRegs_pkg is
--=============================================================================
  
  -----------------------------------------------------------------------------
  -- Control register geometry
  -----------------------------------------------------------------------------
  -- The control register memory map is coarsely hardcoded in core_ctrlRegs.vhd
  -- as follows.
  --                                    | Core  | Debug |
  --         ___________________________|_______|_______|
  --  0x3FF | Context registers         |  R/W  |  R/W  |
  --  0x200 |___________________________|_______|_______|
  --  0x1FF | General purpose registers |   -   |  R/W  |
  --  0x100 |___________________________|_______|_______|
  --  0x0FF | Global registers          |   R   |  R/W  |
  --  0x000 |___________________________|_______|_______|
  --
  -- There are two ways to access these registers. The first is from the core
  -- itself, by making memory accesses to a contiguous region of memory mapped
  -- to the registers. The region is 1kiB in size and must be aligned to 1kiB
  -- boundaries; other than that, the location is specified by cregStartAddress
  -- in CFG. The second method is the debug bus. Because there is no context
  -- associated with the debug bus, bits 12..10 of the address are used to
  -- specify it. The global registers are mirrored for each context, but should
  -- always be read from context 0. That way, platforms can override those
  -- 256-byte regions with platform-specific registers without wasting address
  -- space. The debug bus can read from and write to everything, but the core
  -- itself has limited access, as shown in the table above.
  --
  -- The core can only access registers belonging to the context it is
  -- currently running internally. If cross-context access is needed, the
  -- memory bus of the rvex must be connected to the debug bus externally.
  --
  -- The registers are fully specified in the :/config/ directory of the
  -- repository.
  
  -- Size of the control register file accessible from the core through data
  -- memory operations.
  constant CRG_SIZE_BLOG2       : natural := 10;
  
  -- ##################### GENERATED FROM HERE ONWARDS ##################### --
  -- Do not remove the above line. It is used as a marker by the generator
  -- scripts.
                                                                                                     -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Global status register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_GSR               : natural := 0;
  constant CR_GSR_V             : std_logic_vector(7 downto 2) := "000000";

  constant CR_GSR_R_H           : natural := 31;
  constant CR_GSR_R_L           : natural := 31;

  constant CR_GSR_E_H           : natural := 13;                                                     -- GENERATED --
  constant CR_GSR_E_L           : natural := 13;

  constant CR_GSR_B_H           : natural := 12;
  constant CR_GSR_B_L           : natural := 12;

  constant CR_GSR_RID_H         : natural := 11;
  constant CR_GSR_RID_L         : natural := 8;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Bus reconfiguration request register                                                            -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_BCRR              : natural := 1;
  constant CR_BCRR_V            : std_logic_vector(7 downto 2) := "000001";

  constant CR_BCRR_BCRR_H       : natural := 31;
  constant CR_BCRR_BCRR_L       : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Current configuration register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  constant CR_CC                : natural := 2;
  constant CR_CC_V              : std_logic_vector(7 downto 2) := "000010";

  constant CR_CC_CC_H           : natural := 31;
  constant CR_CC_CC_L           : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Cache affinity register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_AFF               : natural := 3;                                                      -- GENERATED --
  constant CR_AFF_V             : std_logic_vector(7 downto 2) := "000011";

  constant CR_AFF_AF_H          : natural := 31;
  constant CR_AFF_AF_L          : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Cycle counter register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CNT               : natural := 4;
  constant CR_CNT_V             : std_logic_vector(7 downto 2) := "000100";                          -- GENERATED --

  constant CR_CNT_CNT_H         : natural := 31;
  constant CR_CNT_CNT_L         : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Cycle counter register high
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CNTH              : natural := 5;
  constant CR_CNTH_V            : std_logic_vector(7 downto 2) := "000101";
                                                                                                     -- GENERATED --
  constant CR_CNTH_CNTH_H       : natural := 31;
  constant CR_CNTH_CNTH_L       : natural := 8;

  constant CR_CNTH_CNT_H        : natural := 7;
  constant CR_CNTH_CNT_L        : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Long immediate capability register $n$
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_LIMC7             : natural := 40;                                                     -- GENERATED --
  constant CR_LIMC7_V           : std_logic_vector(7 downto 2) := "101000";

  constant CR_LIMC7_BORROW15_H  : natural := 31;
  constant CR_LIMC7_BORROW15_L  : natural := 16;

  constant CR_LIMC7_BORROW14_H  : natural := 15;
  constant CR_LIMC7_BORROW14_L  : natural := 0;

  constant CR_LIMC6             : natural := 41;
  constant CR_LIMC6_V           : std_logic_vector(7 downto 2) := "101001";                          -- GENERATED --

  constant CR_LIMC6_BORROW13_H  : natural := 31;
  constant CR_LIMC6_BORROW13_L  : natural := 16;

  constant CR_LIMC6_BORROW12_H  : natural := 15;
  constant CR_LIMC6_BORROW12_L  : natural := 0;

  constant CR_LIMC5             : natural := 42;
  constant CR_LIMC5_V           : std_logic_vector(7 downto 2) := "101010";
                                                                                                     -- GENERATED --
  constant CR_LIMC5_BORROW11_H  : natural := 31;
  constant CR_LIMC5_BORROW11_L  : natural := 16;

  constant CR_LIMC5_BORROW10_H  : natural := 15;
  constant CR_LIMC5_BORROW10_L  : natural := 0;

  constant CR_LIMC4             : natural := 43;
  constant CR_LIMC4_V           : std_logic_vector(7 downto 2) := "101011";

  constant CR_LIMC4_BORROW9_H   : natural := 31;                                                     -- GENERATED --
  constant CR_LIMC4_BORROW9_L   : natural := 16;

  constant CR_LIMC4_BORROW8_H   : natural := 15;
  constant CR_LIMC4_BORROW8_L   : natural := 0;

  constant CR_LIMC3             : natural := 44;
  constant CR_LIMC3_V           : std_logic_vector(7 downto 2) := "101100";

  constant CR_LIMC3_BORROW7_H   : natural := 31;
  constant CR_LIMC3_BORROW7_L   : natural := 16;                                                     -- GENERATED --

  constant CR_LIMC3_BORROW6_H   : natural := 15;
  constant CR_LIMC3_BORROW6_L   : natural := 0;

  constant CR_LIMC2             : natural := 45;
  constant CR_LIMC2_V           : std_logic_vector(7 downto 2) := "101101";

  constant CR_LIMC2_BORROW5_H   : natural := 31;
  constant CR_LIMC2_BORROW5_L   : natural := 16;
                                                                                                     -- GENERATED --
  constant CR_LIMC2_BORROW4_H   : natural := 15;
  constant CR_LIMC2_BORROW4_L   : natural := 0;

  constant CR_LIMC1             : natural := 46;
  constant CR_LIMC1_V           : std_logic_vector(7 downto 2) := "101110";

  constant CR_LIMC1_BORROW3_H   : natural := 31;
  constant CR_LIMC1_BORROW3_L   : natural := 16;

  constant CR_LIMC1_BORROW2_H   : natural := 15;                                                     -- GENERATED --
  constant CR_LIMC1_BORROW2_L   : natural := 0;

  constant CR_LIMC0             : natural := 47;
  constant CR_LIMC0_V           : std_logic_vector(7 downto 2) := "101111";

  constant CR_LIMC0_BORROW1_H   : natural := 31;
  constant CR_LIMC0_BORROW1_L   : natural := 16;

  constant CR_LIMC0_BORROW0_H   : natural := 15;
  constant CR_LIMC0_BORROW0_L   : natural := 0;                                                      -- GENERATED --

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Syllable index capability register $n$
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_SIC3              : natural := 48;
  constant CR_SIC3_V            : std_logic_vector(7 downto 2) := "110000";

  constant CR_SIC3_SYL15CAP_H   : natural := 31;
  constant CR_SIC3_SYL15CAP_L   : natural := 24;
                                                                                                     -- GENERATED --
  constant CR_SIC3_SYL14CAP_H   : natural := 23;
  constant CR_SIC3_SYL14CAP_L   : natural := 16;

  constant CR_SIC3_SYL13CAP_H   : natural := 15;
  constant CR_SIC3_SYL13CAP_L   : natural := 8;

  constant CR_SIC3_SYL12CAP_H   : natural := 7;
  constant CR_SIC3_SYL12CAP_L   : natural := 0;

  constant CR_SIC2              : natural := 49;                                                     -- GENERATED --
  constant CR_SIC2_V            : std_logic_vector(7 downto 2) := "110001";

  constant CR_SIC2_SYL11CAP_H   : natural := 31;
  constant CR_SIC2_SYL11CAP_L   : natural := 24;

  constant CR_SIC2_SYL10CAP_H   : natural := 23;
  constant CR_SIC2_SYL10CAP_L   : natural := 16;

  constant CR_SIC2_SYL9CAP_H    : natural := 15;
  constant CR_SIC2_SYL9CAP_L    : natural := 8;                                                      -- GENERATED --

  constant CR_SIC2_SYL8CAP_H    : natural := 7;
  constant CR_SIC2_SYL8CAP_L    : natural := 0;

  constant CR_SIC1              : natural := 50;
  constant CR_SIC1_V            : std_logic_vector(7 downto 2) := "110010";

  constant CR_SIC1_SYL7CAP_H    : natural := 31;
  constant CR_SIC1_SYL7CAP_L    : natural := 24;
                                                                                                     -- GENERATED --
  constant CR_SIC1_SYL6CAP_H    : natural := 23;
  constant CR_SIC1_SYL6CAP_L    : natural := 16;

  constant CR_SIC1_SYL5CAP_H    : natural := 15;
  constant CR_SIC1_SYL5CAP_L    : natural := 8;

  constant CR_SIC1_SYL4CAP_H    : natural := 7;
  constant CR_SIC1_SYL4CAP_L    : natural := 0;

  constant CR_SIC0              : natural := 51;                                                     -- GENERATED --
  constant CR_SIC0_V            : std_logic_vector(7 downto 2) := "110011";

  constant CR_SIC0_SYL3CAP_H    : natural := 31;
  constant CR_SIC0_SYL3CAP_L    : natural := 24;

  constant CR_SIC0_SYL2CAP_H    : natural := 23;
  constant CR_SIC0_SYL2CAP_L    : natural := 16;

  constant CR_SIC0_SYL1CAP_H    : natural := 15;
  constant CR_SIC0_SYL1CAP_L    : natural := 8;                                                      -- GENERATED --

  constant CR_SIC0_SYL0CAP_H    : natural := 7;
  constant CR_SIC0_SYL0CAP_L    : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- General purpose register delay register B
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_GPS1              : natural := 52;
  constant CR_GPS1_V            : std_logic_vector(7 downto 2) := "110100";
                                                                                                     -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- General purpose register delay register A
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_GPS0              : natural := 53;
  constant CR_GPS0_V            : std_logic_vector(7 downto 2) := "110101";

  constant CR_GPS0_MEMAR_H      : natural := 27;
  constant CR_GPS0_MEMAR_L      : natural := 24;

  constant CR_GPS0_MEMDC_H      : natural := 23;                                                     -- GENERATED --
  constant CR_GPS0_MEMDC_L      : natural := 20;

  constant CR_GPS0_MEMDR_H      : natural := 19;
  constant CR_GPS0_MEMDR_L      : natural := 16;

  constant CR_GPS0_MULC_H       : natural := 15;
  constant CR_GPS0_MULC_L       : natural := 12;

  constant CR_GPS0_MULR_H       : natural := 11;
  constant CR_GPS0_MULR_L       : natural := 8;                                                      -- GENERATED --

  constant CR_GPS0_ALUC_H       : natural := 7;
  constant CR_GPS0_ALUC_L       : natural := 4;

  constant CR_GPS0_ALUR_H       : natural := 3;
  constant CR_GPS0_ALUR_L       : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Special delay register B
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  constant CR_SPS1              : natural := 54;
  constant CR_SPS1_V            : std_logic_vector(7 downto 2) := "110110";

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Special delay register A
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_SPS0              : natural := 55;
  constant CR_SPS0_V            : std_logic_vector(7 downto 2) := "110111";

  constant CR_SPS0_MEMMC_H      : natural := 31;                                                     -- GENERATED --
  constant CR_SPS0_MEMMC_L      : natural := 28;

  constant CR_SPS0_MEMMR_H      : natural := 27;
  constant CR_SPS0_MEMMR_L      : natural := 24;

  constant CR_SPS0_MEMDC_H      : natural := 23;
  constant CR_SPS0_MEMDC_L      : natural := 20;

  constant CR_SPS0_MEMDR_H      : natural := 19;
  constant CR_SPS0_MEMDR_L      : natural := 16;                                                     -- GENERATED --

  constant CR_SPS0_BRC_H        : natural := 15;
  constant CR_SPS0_BRC_L        : natural := 12;

  constant CR_SPS0_BRR_H        : natural := 11;
  constant CR_SPS0_BRR_L        : natural := 8;

  constant CR_SPS0_ALUC_H       : natural := 7;
  constant CR_SPS0_ALUC_L       : natural := 4;
                                                                                                     -- GENERATED --
  constant CR_SPS0_ALUR_H       : natural := 3;
  constant CR_SPS0_ALUR_L       : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Extension register 2
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_EXT2              : natural := 56;
  constant CR_EXT2_V            : std_logic_vector(7 downto 2) := "111000";

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  -- Extension register 1
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_EXT1              : natural := 57;
  constant CR_EXT1_V            : std_logic_vector(7 downto 2) := "111001";

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Extension register 0
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_EXT0              : natural := 58;
  constant CR_EXT0_V            : std_logic_vector(7 downto 2) := "111010";                          -- GENERATED --

  constant CR_EXT0_T_H          : natural := 27;
  constant CR_EXT0_T_L          : natural := 27;

  constant CR_EXT0_BRK_H        : natural := 26;
  constant CR_EXT0_BRK_L        : natural := 24;

  constant CR_EXT0_C_H          : natural := 19;
  constant CR_EXT0_C_L          : natural := 19;
                                                                                                     -- GENERATED --
  constant CR_EXT0_P_H          : natural := 18;
  constant CR_EXT0_P_L          : natural := 16;

  constant CR_EXT0_O_H          : natural := 2;
  constant CR_EXT0_O_L          : natural := 2;

  constant CR_EXT0_L_H          : natural := 1;
  constant CR_EXT0_L_L          : natural := 1;

  constant CR_EXT0_F_H          : natural := 0;                                                      -- GENERATED --
  constant CR_EXT0_F_L          : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Design-time configuration register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_DCFG              : natural := 59;
  constant CR_DCFG_V            : std_logic_vector(7 downto 2) := "111011";

  constant CR_DCFG_BA_H         : natural := 15;
  constant CR_DCFG_BA_L         : natural := 12;                                                     -- GENERATED --

  constant CR_DCFG_NC_H         : natural := 11;
  constant CR_DCFG_NC_L         : natural := 8;

  constant CR_DCFG_NG_H         : natural := 7;
  constant CR_DCFG_NG_L         : natural := 4;

  constant CR_DCFG_NL_H         : natural := 3;
  constant CR_DCFG_NL_L         : natural := 0;
                                                                                                     -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Core version register 1
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CVER1             : natural := 60;
  constant CR_CVER1_V           : std_logic_vector(7 downto 2) := "111100";

  constant CR_CVER1_VER_H       : natural := 31;
  constant CR_CVER1_VER_L       : natural := 24;

  constant CR_CVER1_CTAG0_H     : natural := 23;                                                     -- GENERATED --
  constant CR_CVER1_CTAG0_L     : natural := 16;

  constant CR_CVER1_CTAG1_H     : natural := 15;
  constant CR_CVER1_CTAG1_L     : natural := 8;

  constant CR_CVER1_CTAG2_H     : natural := 7;
  constant CR_CVER1_CTAG2_L     : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Core version register 0                                                                         -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CVER0             : natural := 61;
  constant CR_CVER0_V           : std_logic_vector(7 downto 2) := "111101";

  constant CR_CVER0_CTAG3_H     : natural := 31;
  constant CR_CVER0_CTAG3_L     : natural := 24;

  constant CR_CVER0_CTAG4_H     : natural := 23;
  constant CR_CVER0_CTAG4_L     : natural := 16;
                                                                                                     -- GENERATED --
  constant CR_CVER0_CTAG5_H     : natural := 15;
  constant CR_CVER0_CTAG5_L     : natural := 8;

  constant CR_CVER0_CTAG6_H     : natural := 7;
  constant CR_CVER0_CTAG6_L     : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Platform version register 1
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_PVER1             : natural := 62;                                                     -- GENERATED --
  constant CR_PVER1_V           : std_logic_vector(7 downto 2) := "111110";

  constant CR_PVER1_COID_H      : natural := 31;
  constant CR_PVER1_COID_L      : natural := 24;

  constant CR_PVER1_PTAG0_H     : natural := 23;
  constant CR_PVER1_PTAG0_L     : natural := 16;

  constant CR_PVER1_PTAG1_H     : natural := 15;
  constant CR_PVER1_PTAG1_L     : natural := 8;                                                      -- GENERATED --

  constant CR_PVER1_PTAG2_H     : natural := 7;
  constant CR_PVER1_PTAG2_L     : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Platform version register 0
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_PVER0             : natural := 63;
  constant CR_PVER0_V           : std_logic_vector(7 downto 2) := "111111";
                                                                                                     -- GENERATED --
  constant CR_PVER0_PTAG3_H     : natural := 31;
  constant CR_PVER0_PTAG3_L     : natural := 24;

  constant CR_PVER0_PTAG4_H     : natural := 23;
  constant CR_PVER0_PTAG4_L     : natural := 16;

  constant CR_PVER0_PTAG5_H     : natural := 15;
  constant CR_PVER0_PTAG5_L     : natural := 8;

  constant CR_PVER0_PTAG6_H     : natural := 7;                                                      -- GENERATED --
  constant CR_PVER0_PTAG6_L     : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Main context control register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CCR               : natural := 128;
  constant CR_CCR_V             : std_logic_vector(8 downto 2) := "0000000";

  constant CR_CCR_CAUSE_H       : natural := 31;
  constant CR_CCR_CAUSE_L       : natural := 24;                                                     -- GENERATED --

  constant CR_CCR_BRANCH_H      : natural := 23;
  constant CR_CCR_BRANCH_L      : natural := 16;

  constant CR_CCR_K_H           : natural := 9;
  constant CR_CCR_K_L           : natural := 8;

  constant CR_CCR_C_H           : natural := 7;
  constant CR_CCR_C_L           : natural := 6;
                                                                                                     -- GENERATED --
  constant CR_CCR_B_H           : natural := 5;
  constant CR_CCR_B_L           : natural := 4;

  constant CR_CCR_R_H           : natural := 3;
  constant CR_CCR_R_L           : natural := 2;

  constant CR_CCR_I_H           : natural := 1;
  constant CR_CCR_I_L           : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  -- Saved context control register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_SCCR              : natural := 129;
  constant CR_SCCR_V            : std_logic_vector(8 downto 2) := "0000001";

  constant CR_SCCR_ID_H         : natural := 31;
  constant CR_SCCR_ID_L         : natural := 24;

  constant CR_SCCR_K_H          : natural := 9;
  constant CR_SCCR_K_L          : natural := 8;                                                      -- GENERATED --

  constant CR_SCCR_C_H          : natural := 7;
  constant CR_SCCR_C_L          : natural := 6;

  constant CR_SCCR_B_H          : natural := 5;
  constant CR_SCCR_B_L          : natural := 4;

  constant CR_SCCR_R_H          : natural := 3;
  constant CR_SCCR_R_L          : natural := 2;
                                                                                                     -- GENERATED --
  constant CR_SCCR_I_H          : natural := 1;
  constant CR_SCCR_I_L          : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Link register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_LR                : natural := 130;
  constant CR_LR_V              : std_logic_vector(8 downto 2) := "0000010";

  constant CR_LR_LR_H           : natural := 31;                                                     -- GENERATED --
  constant CR_LR_LR_L           : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Program counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_PC                : natural := 131;
  constant CR_PC_V              : std_logic_vector(8 downto 2) := "0000011";

  constant CR_PC_PC_H           : natural := 31;
  constant CR_PC_PC_L           : natural := 0;                                                      -- GENERATED --

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Trap handler
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_TH                : natural := 132;
  constant CR_TH_V              : std_logic_vector(8 downto 2) := "0000100";

  constant CR_TH_TH_H           : natural := 31;
  constant CR_TH_TH_L           : natural := 0;
                                                                                                     -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Panic handler
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_PH                : natural := 133;
  constant CR_PH_V              : std_logic_vector(8 downto 2) := "0000101";

  constant CR_PH_PH_H           : natural := 31;
  constant CR_PH_PH_L           : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  -- Trap point
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_TP                : natural := 134;
  constant CR_TP_V              : std_logic_vector(8 downto 2) := "0000110";

  constant CR_TP_TP_H           : natural := 31;
  constant CR_TP_TP_L           : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Trap argument                                                                                   -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_TA                : natural := 135;
  constant CR_TA_V              : std_logic_vector(8 downto 2) := "0000111";

  constant CR_TA_TA_H           : natural := 31;
  constant CR_TA_TA_L           : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Breakpoint $n$
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  constant CR_BR0               : natural := 136;
  constant CR_BR0_V             : std_logic_vector(8 downto 2) := "0001000";

  constant CR_BR0_BR0_H         : natural := 31;
  constant CR_BR0_BR0_L         : natural := 0;

  constant CR_BR1               : natural := 137;
  constant CR_BR1_V             : std_logic_vector(8 downto 2) := "0001001";

  constant CR_BR1_BR1_H         : natural := 31;                                                     -- GENERATED --
  constant CR_BR1_BR1_L         : natural := 0;

  constant CR_BR2               : natural := 138;
  constant CR_BR2_V             : std_logic_vector(8 downto 2) := "0001010";

  constant CR_BR2_BR2_H         : natural := 31;
  constant CR_BR2_BR2_L         : natural := 0;

  constant CR_BR3               : natural := 139;
  constant CR_BR3_V             : std_logic_vector(8 downto 2) := "0001011";                         -- GENERATED --

  constant CR_BR3_BR3_H         : natural := 31;
  constant CR_BR3_BR3_L         : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Debug control register 1
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_DCR               : natural := 140;
  constant CR_DCR_V             : std_logic_vector(8 downto 2) := "0001100";
                                                                                                     -- GENERATED --
  constant CR_DCR_D_H           : natural := 31;
  constant CR_DCR_D_L           : natural := 31;

  constant CR_DCR_J_H           : natural := 30;
  constant CR_DCR_J_L           : natural := 30;

  constant CR_DCR_I_H           : natural := 28;
  constant CR_DCR_I_L           : natural := 28;

  constant CR_DCR_E_H           : natural := 27;                                                     -- GENERATED --
  constant CR_DCR_E_L           : natural := 27;

  constant CR_DCR_R_H           : natural := 26;
  constant CR_DCR_R_L           : natural := 26;

  constant CR_DCR_S_H           : natural := 25;
  constant CR_DCR_S_L           : natural := 25;

  constant CR_DCR_B_H           : natural := 24;
  constant CR_DCR_B_L           : natural := 24;                                                     -- GENERATED --

  constant CR_DCR_CAUSE_H       : natural := 23;
  constant CR_DCR_CAUSE_L       : natural := 16;

  constant CR_DCR_BR3_H         : natural := 13;
  constant CR_DCR_BR3_L         : natural := 12;

  constant CR_DCR_BR2_H         : natural := 9;
  constant CR_DCR_BR2_L         : natural := 8;
                                                                                                     -- GENERATED --
  constant CR_DCR_BR1_H         : natural := 5;
  constant CR_DCR_BR1_L         : natural := 4;

  constant CR_DCR_BR0_H         : natural := 1;
  constant CR_DCR_BR0_L         : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Debug control register 2
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_DCR2              : natural := 141;                                                    -- GENERATED --
  constant CR_DCR2_V            : std_logic_vector(8 downto 2) := "0001101";

  constant CR_DCR2_RESULT_H     : natural := 31;
  constant CR_DCR2_RESULT_L     : natural := 24;

  constant CR_DCR2_TRCAP_H      : natural := 15;
  constant CR_DCR2_TRCAP_L      : natural := 8;

  constant CR_DCR2_T_H          : natural := 7;
  constant CR_DCR2_T_L          : natural := 7;                                                      -- GENERATED --

  constant CR_DCR2_M_H          : natural := 6;
  constant CR_DCR2_M_L          : natural := 6;

  constant CR_DCR2_R_H          : natural := 5;
  constant CR_DCR2_R_L          : natural := 5;

  constant CR_DCR2_C_H          : natural := 4;
  constant CR_DCR2_C_L          : natural := 4;
                                                                                                     -- GENERATED --
  constant CR_DCR2_I_H          : natural := 3;
  constant CR_DCR2_I_L          : natural := 3;

  constant CR_DCR2_E_H          : natural := 0;
  constant CR_DCR2_E_L          : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Context reconfiguration request register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CRR               : natural := 144;                                                    -- GENERATED --
  constant CR_CRR_V             : std_logic_vector(8 downto 2) := "0010000";

  constant CR_CRR_CRR_H         : natural := 31;
  constant CR_CRR_CRR_L         : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Wakeup configuration
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_WCFG              : natural := 146;
  constant CR_WCFG_V            : std_logic_vector(8 downto 2) := "0010010";                         -- GENERATED --

  constant CR_WCFG_WCFG_H       : natural := 31;
  constant CR_WCFG_WCFG_L       : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Sleep and wake-up control register
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_SAWC              : natural := 147;
  constant CR_SAWC_V            : std_logic_vector(8 downto 2) := "0010011";
                                                                                                     -- GENERATED --
  constant CR_SAWC_RUN_H        : natural := 7;
  constant CR_SAWC_RUN_L        : natural := 1;

  constant CR_SAWC_S_H          : natural := 0;
  constant CR_SAWC_S_L          : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Scratchpad register $n$
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_SCRP1             : natural := 148;                                                    -- GENERATED --
  constant CR_SCRP1_V           : std_logic_vector(8 downto 2) := "0010100";

  constant CR_SCRP1_SCRP1_H     : natural := 31;
  constant CR_SCRP1_SCRP1_L     : natural := 0;

  constant CR_SCRP2             : natural := 149;
  constant CR_SCRP2_V           : std_logic_vector(8 downto 2) := "0010101";

  constant CR_SCRP2_SCRP2_H     : natural := 31;
  constant CR_SCRP2_SCRP2_L     : natural := 0;                                                      -- GENERATED --

  constant CR_SCRP3             : natural := 150;
  constant CR_SCRP3_V           : std_logic_vector(8 downto 2) := "0010110";

  constant CR_SCRP3_SCRP3_H     : natural := 31;
  constant CR_SCRP3_SCRP3_L     : natural := 0;

  constant CR_SCRP4             : natural := 151;
  constant CR_SCRP4_V           : std_logic_vector(8 downto 2) := "0010111";
                                                                                                     -- GENERATED --
  constant CR_SCRP4_SCRP4_H     : natural := 31;
  constant CR_SCRP4_SCRP4_L     : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Requested software context
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_RSC               : natural := 152;
  constant CR_RSC_V             : std_logic_vector(8 downto 2) := "0011000";

  constant CR_RSC_RSC_H         : natural := 31;                                                     -- GENERATED --
  constant CR_RSC_RSC_L         : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Current software context
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CSC               : natural := 153;
  constant CR_CSC_V             : std_logic_vector(8 downto 2) := "0011001";

  constant CR_CSC_CSC_H         : natural := 31;
  constant CR_CSC_CSC_L         : natural := 0;                                                      -- GENERATED --

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Requested swctxt on hwctxt $n$
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_RSC1              : natural := 154;
  constant CR_RSC1_V            : std_logic_vector(8 downto 2) := "0011010";

  constant CR_RSC1_RSC1_H       : natural := 31;
  constant CR_RSC1_RSC1_L       : natural := 0;
                                                                                                     -- GENERATED --
  constant CR_RSC2              : natural := 156;
  constant CR_RSC2_V            : std_logic_vector(8 downto 2) := "0011100";

  constant CR_RSC2_RSC2_H       : natural := 31;
  constant CR_RSC2_RSC2_L       : natural := 0;

  constant CR_RSC3              : natural := 158;
  constant CR_RSC3_V            : std_logic_vector(8 downto 2) := "0011110";

  constant CR_RSC3_RSC3_H       : natural := 31;                                                     -- GENERATED --
  constant CR_RSC3_RSC3_L       : natural := 0;

  constant CR_RSC4              : natural := 160;
  constant CR_RSC4_V            : std_logic_vector(8 downto 2) := "0100000";

  constant CR_RSC4_RSC4_H       : natural := 31;
  constant CR_RSC4_RSC4_L       : natural := 0;

  constant CR_RSC5              : natural := 162;
  constant CR_RSC5_V            : std_logic_vector(8 downto 2) := "0100010";                         -- GENERATED --

  constant CR_RSC5_RSC5_H       : natural := 31;
  constant CR_RSC5_RSC5_L       : natural := 0;

  constant CR_RSC6              : natural := 164;
  constant CR_RSC6_V            : std_logic_vector(8 downto 2) := "0100100";

  constant CR_RSC6_RSC6_H       : natural := 31;
  constant CR_RSC6_RSC6_L       : natural := 0;
                                                                                                     -- GENERATED --
  constant CR_RSC7              : natural := 166;
  constant CR_RSC7_V            : std_logic_vector(8 downto 2) := "0100110";

  constant CR_RSC7_RSC7_H       : natural := 31;
  constant CR_RSC7_RSC7_L       : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Current swctxt on hwctxt $n$
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CSC1              : natural := 155;                                                    -- GENERATED --
  constant CR_CSC1_V            : std_logic_vector(8 downto 2) := "0011011";

  constant CR_CSC1_CSC1_H       : natural := 31;
  constant CR_CSC1_CSC1_L       : natural := 0;

  constant CR_CSC2              : natural := 157;
  constant CR_CSC2_V            : std_logic_vector(8 downto 2) := "0011101";

  constant CR_CSC2_CSC2_H       : natural := 31;
  constant CR_CSC2_CSC2_L       : natural := 0;                                                      -- GENERATED --

  constant CR_CSC3              : natural := 159;
  constant CR_CSC3_V            : std_logic_vector(8 downto 2) := "0011111";

  constant CR_CSC3_CSC3_H       : natural := 31;
  constant CR_CSC3_CSC3_L       : natural := 0;

  constant CR_CSC4              : natural := 161;
  constant CR_CSC4_V            : std_logic_vector(8 downto 2) := "0100001";
                                                                                                     -- GENERATED --
  constant CR_CSC4_CSC4_H       : natural := 31;
  constant CR_CSC4_CSC4_L       : natural := 0;

  constant CR_CSC5              : natural := 163;
  constant CR_CSC5_V            : std_logic_vector(8 downto 2) := "0100011";

  constant CR_CSC5_CSC5_H       : natural := 31;
  constant CR_CSC5_CSC5_L       : natural := 0;

  constant CR_CSC6              : natural := 165;                                                    -- GENERATED --
  constant CR_CSC6_V            : std_logic_vector(8 downto 2) := "0100101";

  constant CR_CSC6_CSC6_H       : natural := 31;
  constant CR_CSC6_CSC6_L       : natural := 0;

  constant CR_CSC7              : natural := 167;
  constant CR_CSC7_V            : std_logic_vector(8 downto 2) := "0100111";

  constant CR_CSC7_CSC7_H       : natural := 31;
  constant CR_CSC7_CSC7_L       : natural := 0;                                                      -- GENERATED --

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Cycle counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_CYC               : natural := 192;
  constant CR_CYC_V             : std_logic_vector(8 downto 2) := "1000000";

  constant CR_CYC_CYC3_H        : natural := 31;
  constant CR_CYC_CYC3_L        : natural := 24;
                                                                                                     -- GENERATED --
  constant CR_CYC_CYC2_H        : natural := 23;
  constant CR_CYC_CYC2_L        : natural := 16;

  constant CR_CYC_CYC1_H        : natural := 15;
  constant CR_CYC_CYC1_L        : natural := 8;

  constant CR_CYC_CYC0_H        : natural := 7;
  constant CR_CYC_CYC0_L        : natural := 0;

  constant CR_CYCH              : natural := 193;                                                    -- GENERATED --
  constant CR_CYCH_V            : std_logic_vector(8 downto 2) := "1000001";

  constant CR_CYCH_CYC6_H       : natural := 31;
  constant CR_CYCH_CYC6_L       : natural := 24;

  constant CR_CYCH_CYC5_H       : natural := 23;
  constant CR_CYCH_CYC5_L       : natural := 16;

  constant CR_CYCH_CYC4_H       : natural := 15;
  constant CR_CYCH_CYC4_L       : natural := 8;                                                      -- GENERATED --

  constant CR_CYCH_CYC3_H       : natural := 7;
  constant CR_CYCH_CYC3_L       : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Stall cycle counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_STALL             : natural := 194;
  constant CR_STALL_V           : std_logic_vector(8 downto 2) := "1000010";
                                                                                                     -- GENERATED --
  constant CR_STALL_STALL3_H    : natural := 31;
  constant CR_STALL_STALL3_L    : natural := 24;

  constant CR_STALL_STALL2_H    : natural := 23;
  constant CR_STALL_STALL2_L    : natural := 16;

  constant CR_STALL_STALL1_H    : natural := 15;
  constant CR_STALL_STALL1_L    : natural := 8;

  constant CR_STALL_STALL0_H    : natural := 7;                                                      -- GENERATED --
  constant CR_STALL_STALL0_L    : natural := 0;

  constant CR_STALLH            : natural := 195;
  constant CR_STALLH_V          : std_logic_vector(8 downto 2) := "1000011";

  constant CR_STALLH_STALL6_H   : natural := 31;
  constant CR_STALLH_STALL6_L   : natural := 24;

  constant CR_STALLH_STALL5_H   : natural := 23;
  constant CR_STALLH_STALL5_L   : natural := 16;                                                     -- GENERATED --

  constant CR_STALLH_STALL4_H   : natural := 15;
  constant CR_STALLH_STALL4_L   : natural := 8;

  constant CR_STALLH_STALL3_H   : natural := 7;
  constant CR_STALLH_STALL3_L   : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Committed bundle counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  constant CR_BUN               : natural := 196;
  constant CR_BUN_V             : std_logic_vector(8 downto 2) := "1000100";

  constant CR_BUN_BUN3_H        : natural := 31;
  constant CR_BUN_BUN3_L        : natural := 24;

  constant CR_BUN_BUN2_H        : natural := 23;
  constant CR_BUN_BUN2_L        : natural := 16;

  constant CR_BUN_BUN1_H        : natural := 15;                                                     -- GENERATED --
  constant CR_BUN_BUN1_L        : natural := 8;

  constant CR_BUN_BUN0_H        : natural := 7;
  constant CR_BUN_BUN0_L        : natural := 0;

  constant CR_BUNH              : natural := 197;
  constant CR_BUNH_V            : std_logic_vector(8 downto 2) := "1000101";

  constant CR_BUNH_BUN6_H       : natural := 31;
  constant CR_BUNH_BUN6_L       : natural := 24;                                                     -- GENERATED --

  constant CR_BUNH_BUN5_H       : natural := 23;
  constant CR_BUNH_BUN5_L       : natural := 16;

  constant CR_BUNH_BUN4_H       : natural := 15;
  constant CR_BUNH_BUN4_L       : natural := 8;

  constant CR_BUNH_BUN3_H       : natural := 7;
  constant CR_BUNH_BUN3_L       : natural := 0;
                                                                                                     -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Committed syllable counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_SYL               : natural := 198;
  constant CR_SYL_V             : std_logic_vector(8 downto 2) := "1000110";

  constant CR_SYL_SYL3_H        : natural := 31;
  constant CR_SYL_SYL3_L        : natural := 24;

  constant CR_SYL_SYL2_H        : natural := 23;                                                     -- GENERATED --
  constant CR_SYL_SYL2_L        : natural := 16;

  constant CR_SYL_SYL1_H        : natural := 15;
  constant CR_SYL_SYL1_L        : natural := 8;

  constant CR_SYL_SYL0_H        : natural := 7;
  constant CR_SYL_SYL0_L        : natural := 0;

  constant CR_SYLH              : natural := 199;
  constant CR_SYLH_V            : std_logic_vector(8 downto 2) := "1000111";                         -- GENERATED --

  constant CR_SYLH_SYL6_H       : natural := 31;
  constant CR_SYLH_SYL6_L       : natural := 24;

  constant CR_SYLH_SYL5_H       : natural := 23;
  constant CR_SYLH_SYL5_L       : natural := 16;

  constant CR_SYLH_SYL4_H       : natural := 15;
  constant CR_SYLH_SYL4_L       : natural := 8;
                                                                                                     -- GENERATED --
  constant CR_SYLH_SYL3_H       : natural := 7;
  constant CR_SYLH_SYL3_L       : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Committed NOP counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_NOP               : natural := 200;
  constant CR_NOP_V             : std_logic_vector(8 downto 2) := "1001000";

  constant CR_NOP_NOP3_H        : natural := 31;                                                     -- GENERATED --
  constant CR_NOP_NOP3_L        : natural := 24;

  constant CR_NOP_NOP2_H        : natural := 23;
  constant CR_NOP_NOP2_L        : natural := 16;

  constant CR_NOP_NOP1_H        : natural := 15;
  constant CR_NOP_NOP1_L        : natural := 8;

  constant CR_NOP_NOP0_H        : natural := 7;
  constant CR_NOP_NOP0_L        : natural := 0;                                                      -- GENERATED --

  constant CR_NOPH              : natural := 201;
  constant CR_NOPH_V            : std_logic_vector(8 downto 2) := "1001001";

  constant CR_NOPH_NOP6_H       : natural := 31;
  constant CR_NOPH_NOP6_L       : natural := 24;

  constant CR_NOPH_NOP5_H       : natural := 23;
  constant CR_NOPH_NOP5_L       : natural := 16;
                                                                                                     -- GENERATED --
  constant CR_NOPH_NOP4_H       : natural := 15;
  constant CR_NOPH_NOP4_L       : natural := 8;

  constant CR_NOPH_NOP3_H       : natural := 7;
  constant CR_NOPH_NOP3_L       : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Instruction cache access counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_IACC              : natural := 202;                                                    -- GENERATED --
  constant CR_IACC_V            : std_logic_vector(8 downto 2) := "1001010";

  constant CR_IACC_IACC3_H      : natural := 31;
  constant CR_IACC_IACC3_L      : natural := 24;

  constant CR_IACC_IACC2_H      : natural := 23;
  constant CR_IACC_IACC2_L      : natural := 16;

  constant CR_IACC_IACC1_H      : natural := 15;
  constant CR_IACC_IACC1_L      : natural := 8;                                                      -- GENERATED --

  constant CR_IACC_IACC0_H      : natural := 7;
  constant CR_IACC_IACC0_L      : natural := 0;

  constant CR_IACCH             : natural := 203;
  constant CR_IACCH_V           : std_logic_vector(8 downto 2) := "1001011";

  constant CR_IACCH_IACC6_H     : natural := 31;
  constant CR_IACCH_IACC6_L     : natural := 24;
                                                                                                     -- GENERATED --
  constant CR_IACCH_IACC5_H     : natural := 23;
  constant CR_IACCH_IACC5_L     : natural := 16;

  constant CR_IACCH_IACC4_H     : natural := 15;
  constant CR_IACCH_IACC4_L     : natural := 8;

  constant CR_IACCH_IACC3_H     : natural := 7;
  constant CR_IACCH_IACC3_L     : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  -- Instruction cache miss counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_IMISS             : natural := 204;
  constant CR_IMISS_V           : std_logic_vector(8 downto 2) := "1001100";

  constant CR_IMISS_IMISS3_H    : natural := 31;
  constant CR_IMISS_IMISS3_L    : natural := 24;

  constant CR_IMISS_IMISS2_H    : natural := 23;
  constant CR_IMISS_IMISS2_L    : natural := 16;                                                     -- GENERATED --

  constant CR_IMISS_IMISS1_H    : natural := 15;
  constant CR_IMISS_IMISS1_L    : natural := 8;

  constant CR_IMISS_IMISS0_H    : natural := 7;
  constant CR_IMISS_IMISS0_L    : natural := 0;

  constant CR_IMISSH            : natural := 205;
  constant CR_IMISSH_V          : std_logic_vector(8 downto 2) := "1001101";
                                                                                                     -- GENERATED --
  constant CR_IMISSH_IMISS6_H   : natural := 31;
  constant CR_IMISSH_IMISS6_L   : natural := 24;

  constant CR_IMISSH_IMISS5_H   : natural := 23;
  constant CR_IMISSH_IMISS5_L   : natural := 16;

  constant CR_IMISSH_IMISS4_H   : natural := 15;
  constant CR_IMISSH_IMISS4_L   : natural := 8;

  constant CR_IMISSH_IMISS3_H   : natural := 7;                                                      -- GENERATED --
  constant CR_IMISSH_IMISS3_L   : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Data cache read access counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_DRACC             : natural := 206;
  constant CR_DRACC_V           : std_logic_vector(8 downto 2) := "1001110";

  constant CR_DRACC_DRACC3_H    : natural := 31;
  constant CR_DRACC_DRACC3_L    : natural := 24;                                                     -- GENERATED --

  constant CR_DRACC_DRACC2_H    : natural := 23;
  constant CR_DRACC_DRACC2_L    : natural := 16;

  constant CR_DRACC_DRACC1_H    : natural := 15;
  constant CR_DRACC_DRACC1_L    : natural := 8;

  constant CR_DRACC_DRACC0_H    : natural := 7;
  constant CR_DRACC_DRACC0_L    : natural := 0;
                                                                                                     -- GENERATED --
  constant CR_DRACCH            : natural := 207;
  constant CR_DRACCH_V          : std_logic_vector(8 downto 2) := "1001111";

  constant CR_DRACCH_DRACC6_H   : natural := 31;
  constant CR_DRACCH_DRACC6_L   : natural := 24;

  constant CR_DRACCH_DRACC5_H   : natural := 23;
  constant CR_DRACCH_DRACC5_L   : natural := 16;

  constant CR_DRACCH_DRACC4_H   : natural := 15;                                                     -- GENERATED --
  constant CR_DRACCH_DRACC4_L   : natural := 8;

  constant CR_DRACCH_DRACC3_H   : natural := 7;
  constant CR_DRACCH_DRACC3_L   : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Data cache read miss counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_DRMISS            : natural := 208;
  constant CR_DRMISS_V          : std_logic_vector(8 downto 2) := "1010000";                         -- GENERATED --

  constant CR_DRMISS_DRMISS3_H  : natural := 31;
  constant CR_DRMISS_DRMISS3_L  : natural := 24;

  constant CR_DRMISS_DRMISS2_H  : natural := 23;
  constant CR_DRMISS_DRMISS2_L  : natural := 16;

  constant CR_DRMISS_DRMISS1_H  : natural := 15;
  constant CR_DRMISS_DRMISS1_L  : natural := 8;
                                                                                                     -- GENERATED --
  constant CR_DRMISS_DRMISS0_H  : natural := 7;
  constant CR_DRMISS_DRMISS0_L  : natural := 0;

  constant CR_DRMISSH           : natural := 209;
  constant CR_DRMISSH_V         : std_logic_vector(8 downto 2) := "1010001";

  constant CR_DRMISSH_DRMISS6_H : natural := 31;
  constant CR_DRMISSH_DRMISS6_L : natural := 24;

  constant CR_DRMISSH_DRMISS5_H : natural := 23;                                                     -- GENERATED --
  constant CR_DRMISSH_DRMISS5_L : natural := 16;

  constant CR_DRMISSH_DRMISS4_H : natural := 15;
  constant CR_DRMISSH_DRMISS4_L : natural := 8;

  constant CR_DRMISSH_DRMISS3_H : natural := 7;
  constant CR_DRMISSH_DRMISS3_L : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Data cache write access counter                                                                 -- GENERATED --
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_DWACC             : natural := 210;
  constant CR_DWACC_V           : std_logic_vector(8 downto 2) := "1010010";

  constant CR_DWACC_DWACC3_H    : natural := 31;
  constant CR_DWACC_DWACC3_L    : natural := 24;

  constant CR_DWACC_DWACC2_H    : natural := 23;
  constant CR_DWACC_DWACC2_L    : natural := 16;
                                                                                                     -- GENERATED --
  constant CR_DWACC_DWACC1_H    : natural := 15;
  constant CR_DWACC_DWACC1_L    : natural := 8;

  constant CR_DWACC_DWACC0_H    : natural := 7;
  constant CR_DWACC_DWACC0_L    : natural := 0;

  constant CR_DWACCH            : natural := 211;
  constant CR_DWACCH_V          : std_logic_vector(8 downto 2) := "1010011";

  constant CR_DWACCH_DWACC6_H   : natural := 31;                                                     -- GENERATED --
  constant CR_DWACCH_DWACC6_L   : natural := 24;

  constant CR_DWACCH_DWACC5_H   : natural := 23;
  constant CR_DWACCH_DWACC5_L   : natural := 16;

  constant CR_DWACCH_DWACC4_H   : natural := 15;
  constant CR_DWACCH_DWACC4_L   : natural := 8;

  constant CR_DWACCH_DWACC3_H   : natural := 7;
  constant CR_DWACCH_DWACC3_L   : natural := 0;                                                      -- GENERATED --

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Data cache write miss counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_DWMISS            : natural := 212;
  constant CR_DWMISS_V          : std_logic_vector(8 downto 2) := "1010100";

  constant CR_DWMISS_DWMISS3_H  : natural := 31;
  constant CR_DWMISS_DWMISS3_L  : natural := 24;
                                                                                                     -- GENERATED --
  constant CR_DWMISS_DWMISS2_H  : natural := 23;
  constant CR_DWMISS_DWMISS2_L  : natural := 16;

  constant CR_DWMISS_DWMISS1_H  : natural := 15;
  constant CR_DWMISS_DWMISS1_L  : natural := 8;

  constant CR_DWMISS_DWMISS0_H  : natural := 7;
  constant CR_DWMISS_DWMISS0_L  : natural := 0;

  constant CR_DWMISSH           : natural := 213;                                                    -- GENERATED --
  constant CR_DWMISSH_V         : std_logic_vector(8 downto 2) := "1010101";

  constant CR_DWMISSH_DWMISS6_H : natural := 31;
  constant CR_DWMISSH_DWMISS6_L : natural := 24;

  constant CR_DWMISSH_DWMISS5_H : natural := 23;
  constant CR_DWMISSH_DWMISS5_L : natural := 16;

  constant CR_DWMISSH_DWMISS4_H : natural := 15;
  constant CR_DWMISSH_DWMISS4_L : natural := 8;                                                      -- GENERATED --

  constant CR_DWMISSH_DWMISS3_H : natural := 7;
  constant CR_DWMISSH_DWMISS3_L : natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Data cache bypass counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  constant CR_DBYPASS           : natural := 214;
  constant CR_DBYPASS_V         : std_logic_vector(8 downto 2) := "1010110";
                                                                                                     -- GENERATED --
  constant CR_DBYPASS_DBYPASS3_H: natural := 31;
  constant CR_DBYPASS_DBYPASS3_L: natural := 24;

  constant CR_DBYPASS_DBYPASS2_H: natural := 23;
  constant CR_DBYPASS_DBYPASS2_L: natural := 16;

  constant CR_DBYPASS_DBYPASS1_H: natural := 15;
  constant CR_DBYPASS_DBYPASS1_L: natural := 8;

  constant CR_DBYPASS_DBYPASS0_H: natural := 7;                                                      -- GENERATED --
  constant CR_DBYPASS_DBYPASS0_L: natural := 0;

  constant CR_DBYPASSH          : natural := 215;
  constant CR_DBYPASSH_V        : std_logic_vector(8 downto 2) := "1010111";

  constant CR_DBYPASSH_DBYPASS6_H: natural := 31;
  constant CR_DBYPASSH_DBYPASS6_L: natural := 24;

  constant CR_DBYPASSH_DBYPASS5_H: natural := 23;
  constant CR_DBYPASSH_DBYPASS5_L: natural := 16;                                                    -- GENERATED --

  constant CR_DBYPASSH_DBYPASS4_H: natural := 15;
  constant CR_DBYPASSH_DBYPASS4_L: natural := 8;

  constant CR_DBYPASSH_DBYPASS3_H: natural := 7;
  constant CR_DBYPASSH_DBYPASS3_L: natural := 0;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Data cache write buffer counter
  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -                       -- GENERATED --
  constant CR_DWBUF             : natural := 216;
  constant CR_DWBUF_V           : std_logic_vector(8 downto 2) := "1011000";

  constant CR_DWBUF_DWBUF3_H    : natural := 31;
  constant CR_DWBUF_DWBUF3_L    : natural := 24;

  constant CR_DWBUF_DWBUF2_H    : natural := 23;
  constant CR_DWBUF_DWBUF2_L    : natural := 16;

  constant CR_DWBUF_DWBUF1_H    : natural := 15;                                                     -- GENERATED --
  constant CR_DWBUF_DWBUF1_L    : natural := 8;

  constant CR_DWBUF_DWBUF0_H    : natural := 7;
  constant CR_DWBUF_DWBUF0_L    : natural := 0;

  constant CR_DWBUFH            : natural := 217;
  constant CR_DWBUFH_V          : std_logic_vector(8 downto 2) := "1011001";

  constant CR_DWBUFH_DWBUF6_H   : natural := 31;
  constant CR_DWBUFH_DWBUF6_L   : natural := 24;                                                     -- GENERATED --

  constant CR_DWBUFH_DWBUF5_H   : natural := 23;
  constant CR_DWBUFH_DWBUF5_L   : natural := 16;

  constant CR_DWBUFH_DWBUF4_H   : natural := 15;
  constant CR_DWBUFH_DWBUF4_L   : natural := 8;

  constant CR_DWBUFH_DWBUF3_H   : natural := 7;
  constant CR_DWBUFH_DWBUF3_L   : natural := 0;
                                                                                                     -- GENERATED --
end core_ctrlRegs_pkg;

package body core_ctrlRegs_pkg is
end core_ctrlRegs_pkg;
