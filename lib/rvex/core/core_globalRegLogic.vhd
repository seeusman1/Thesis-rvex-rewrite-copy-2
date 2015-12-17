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
use rvex.utils_pkg.all;
use rvex.core_pkg.all;
use rvex.core_intIface_pkg.all;
use rvex.core_ctrlRegs_pkg.all;
--use rvex.cache_pkg.all;

--=============================================================================
-- This entity contains the specifications and logic for the control registers
-- which are shared between all cores. They are read only to the core, but the
-- debug bus can write to them (depending on specification).
-------------------------------------------------------------------------------
entity core_globalRegLogic is
--=============================================================================
  generic (
    
    -- Configuration.
    CFG                         : rvex_generic_config_type
    --CCFG                         : cache_generic_config_type
  );
  port (
    
    ---------------------------------------------------------------------------
    -- System control
    ---------------------------------------------------------------------------
    -- Active high synchronous reset input.
    resetIn                     : in  std_logic;
    
    -- Active high synchronous reset output.
    resetOut                    : out std_logic;
    
    -- Clock input, registers are rising edge triggered.
    clk                         : in  std_logic;
    
    -- Active high global clock enable input.
    clkEn                       : in  std_logic;
    
    ---------------------------------------------------------------------------
    -- Interface with the control registers and bus logic
    ---------------------------------------------------------------------------
    -- Interface for the control registers.
    gbreg2creg                  : out gbreg2creg_type;
    creg2gbreg                  : in  creg2gbreg_type;
    
    ---------------------------------------------------------------------------
    -- Interface with configuration logic
    ---------------------------------------------------------------------------
    -- Each nibble in the data word corresponds to a pipelane group, of which
    -- bit 3 specifies whether the pipelane group should be disabled (high) or
    -- enabled (low) and, if low, bit 2..0 specify the context it should run
    -- on. Bits which are not supported by the core (as specified in the CFG
    -- generic) should be written zero or the request will be ignored (as
    -- specified by the error flag in the global control register file).
    -- The enable signal is active high, and is valid one clkEn'd cycle BEFORE
    -- the data vector is. This is because the enable signal is connected to
    -- the bus write enable signal for the register and the data is connected
    -- to the register output.
    gbreg2cfg_requestData_r     : out rvex_data_type;
    gbreg2cfg_requestEnable     : out std_logic;
    
    -- Current configuration, using the same encoding as the request data.
    cfg2gbreg_currentCfg        : in  rvex_data_type;
    
    -- Configuration busy signal. When set, new configuration requests are not
    -- accepted.
    cfg2gbreg_busy              : in  std_logic;
    
    -- Configuration error signal. This is set when the last configuration
    -- request was erroneous.
    cfg2gbreg_error             : in  std_logic;
    
    -- When reconfiguration is requested, this field is set to the index of
    -- the context which requested the configuration, or all ones if the source
    -- was the debug bus.
    cfg2gbreg_requesterID       : in  std_logic_vector(3 downto 0);
    
    ---------------------------------------------------------------------------
    -- Interface with memory
    ---------------------------------------------------------------------------
    -- Affinity signal from the memory.
    imem2gbreg_affinity         : in  std_logic_vector(2**CFG.numLaneGroupsLog2*CFG.numLaneGroupsLog2-1 downto 0)
    
  );
end core_globalRegLogic;

--=============================================================================
architecture Behavioral of core_globalRegLogic is
--=============================================================================
  
--=============================================================================
begin -- architecture
--=============================================================================
  
  -- Single process which handles all combinatorial logic for the context
  -- control registers.
  logic: process (
    creg2gbreg, cfg2gbreg_currentCfg, cfg2gbreg_busy, cfg2gbreg_error,
    cfg2gbreg_requesterID, imem2gbreg_affinity
  ) is
    variable l2c  : gbreg2creg_type;
    variable c2l  : creg2gbreg_type;
  begin
    l2c := (others => HW2REG_DEFAULT);
    c2l := creg2gbreg;
    
    ---------------------------------------------------------------------------
    -- Global status register (GSR)
    ---------------------------------------------------------------------------
    -- 
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    -- GSR   |R|                                 |E|B|  RID  |               |
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    -- 
    -- RID    = Context ID for the last context which successfully passed
    --          through reconfiguration request arbitration, or 0xF in the last
    --          request was from the debug bus.
    -- 
    -- B      = Reconfiguration busy. While high, reconfiguration requests are
    --          ignored.
    -- 
    -- E      = Reconfiguration error. This is set when an invalid
    --          configuration was requested, and is cleared when a valid one is
    --          requested.
    -- 
    -- R      = When the debug bus writes a one to this bit, the entire rvex
    --          will be reset, as if the external reset input was asserted for
    --          one cycle.
    
    -- Make the requester ID field.
    creg_makeHardwiredField(l2c, c2l, CR_GSR, 11, 8, cfg2gbreg_requesterID);
    
    -- Make the reconfiguration busy and error fields.
    creg_makeHardwiredField(l2c, c2l, CR_GSR, 13, 12, cfg2gbreg_error & cfg2gbreg_busy);
    
    -- Wire up the reset signal.
    creg_makeNormalRegister(l2c, c2l, CR_GSR, 31, 31,
      permissions   => DEBUG_CAN_WRITE
    );
    resetOut <= creg_readRegisterBit(l2c, c2l, CR_GSR, 31);
    
    ---------------------------------------------------------------------------
    -- Bus reconfiguration request register (BCRR) and current configuration
    -- register (CC).
    ---------------------------------------------------------------------------
    -- 
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    -- BCRR  |  CT7  |  CT6  |  CT5  |  CT4  |  CT3  |  CT2  |  CT1  |  CT0  |
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    -- CC    |  CT7  |  CT6  |  CT5  |  CT4  |  CT3  |  CT2  |  CT1  |  CT0  |
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    --
    -- The CT* fields specify which context should run on the indexed pipelane
    -- group. The value written should be within 0..2**CFG.numContextsLog2-1 OR
    -- it should be 8. When 8, a pipeline group is disabled. The value written
    -- to the field for nonexisting pipelane groups should be 0. When at least
    -- the LSB of the register is written by the debug bus, a reconfiguration
    -- request is sent to the configuration control unit. If all goes well,
    -- the rvex will be reconfigured as requested. There are several rules
    -- which need to be followed for the new configuration to be accepted;
    -- there should be some more documentation on this subject elsewhere... If
    -- there isn't, look through the rvex_cfgCtrl.vhd and rvex_cfgCtrl_tb.vhd
    -- files.
    
    -- Set the write permissions on the BCCR register.
    creg_makeNormalRegister(l2c, c2l, CR_BCRR, 31, 0,
      permissions   => DEBUG_CAN_WRITE
    );
    
    -- Drive data.
    gbreg2cfg_requestData_r <= creg_readRegisterVect(l2c, c2l, CR_BCRR, 31, 0);
    
    -- Drive requestEnable.
    gbreg2cfg_requestEnable <= creg_isBusWritingToBit(l2c, c2l, CR_BCRR, 0);
    
    -- Make current configuration availiable to processor and debug bus.
    creg_makeHardwiredField(l2c, c2l, CR_CC, 31, 0, cfg2gbreg_currentCfg);
    
    ---------------------------------------------------------------------------
    -- Cache/memory block affinity register (AFF)
    ---------------------------------------------------------------------------
    -- 
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    -- AFF   | | AF7 | | AF6 | | AF5 | | AF4 | | AF3 | | AF2 | | AF1 | | AF0 |
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    --
    -- The AF* fields specify the preferred lane group which the indexed
    -- context should be run on next for maximum cache locality.
    
    -- Generate the affinity fields.
    if CFG.numLaneGroupsLog2 > 0 then
      for laneGroup in 0 to 2**CFG.numLaneGroupsLog2-1 loop
        creg_makeHardwiredField(l2c, c2l, CR_AFF, laneGroup*4+CFG.numLaneGroupsLog2-1, laneGroup*4,
          imem2gbreg_affinity(laneGroup*CFG.numLaneGroupsLog2 + CFG.numLaneGroupsLog2-1 downto laneGroup*CFG.numLaneGroupsLog2));
      end loop;
    end if;
    
    ---------------------------------------------------------------------------
    -- Cycle counter register (CNT)
    ---------------------------------------------------------------------------
    -- 
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    -- CNT   |                         cycle counter                         |
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    --
    -- Simply increments each processor cycle and overflows when it reaches
    -- 0xFFFFFFFF.
    
    -- Make the cycle counter.
    creg_makeCounter64(l2c, c2l, CR_CNT,
      inc           => '1',
      permissions   => READ_ONLY
    );
    
    ---------------------------------------------------------------------------
    -- Processor version register (PVR)
    ---------------------------------------------------------------------------
    -- 
    --       |---+---+---+---|---+---+---+---|---+---+---+---|---+---+---+---|
    -- PVR_l |  bundleAlign  |  numContexts  | numLaneGroups |    numLanes   |
    --       |---+---+---+---|---+---+---+---|---+---+---+---|---+---+---+---|
    --
    --       |---+---+---+---|---+---+---+---|---+---+---+---|---+---+---+---|
    -- PVR_h | U   L   P   F |numBreakpoints |memLaneRevIndex|multiplierLanes|
    --       |---+---+---+---|---+---+---+---|---+---+---+---|---+---+---+---|
    --
    -- F - Forwarding
    -- P - limmh from previous pair
    -- L - r63 is link register
    -- U - Unified trap
    
    -- Make the version register
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 3, 0, uint2vect(2**CFG.numLanesLog2,4));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 7, 4, uint2vect(2**CFG.numLaneGroupsLog2,4));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 11, 8, uint2vect(2**CFG.numContextsLog2,4));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 15, 12, uint2vect(2**CFG.bundleAlignLog2,4));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 19, 16, uint2vect(CFG.multiplierLanes,4));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 23, 20, uint2vect(CFG.memLaneRevIndex,4));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 27, 24, uint2vect(CFG.numBreakpoints,4));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 28, 28, uint2vect(bool2int(CFG.forwarding),1));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 29, 29, uint2vect(bool2int(CFG.limmhFromPreviousPair),1));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 30, 30, uint2vect(bool2int(CFG.reg63isLink),1));
    creg_makeHardwiredField(l2c, c2l, CR_PVR, 31, 31, uint2vect(bool2int(CFG.unifiedStall),1));

    ---------------------------------------------------------------------------
    -- Cache sizes register
    ---------------------------------------------------------------------------
    -- 
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    -- CSR   |     Data cache size (KiB)     |  Instruction cache size (KiB) |
    --       |-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    --
    
    -- Make the Instruction cache size register
    --creg_makeHardwiredField(l2c, c2l, CR_CSR, 15, 0, std_logic_vector(to_unsigned(((2**CCFG.instrCacheLinesLog2)*(2**CFG.numLanesLog2)*4)/1024,16)));

    -- Make the Data cache size register (nr of cache lines * linesize (4) * cacheblocks (4) )
    --creg_makeHardwiredField(l2c, c2l, CR_CSR, 31, 16, std_logic_vector(to_unsigned(((2**CCFG.dataCacheLinesLog2)*4*4)/1024,16)));
    
    
    ---------------------------------------------------------------------------
    -- Forward control signals
    ---------------------------------------------------------------------------
    gbreg2creg <= l2c;
    
  end process;
  
end Behavioral;

