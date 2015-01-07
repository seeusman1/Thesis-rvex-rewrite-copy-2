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
use rvex.core_pipeline_pkg.all;
use rvex.core_trap_pkg.all;
use rvex.core_opcode_pkg.all;
use rvex.core_opcodeBranch_pkg.all;

-- pragma translate_off
use rvex.simUtils_pkg.all;
-- pragma translate_on

--=============================================================================
-- This entity contains the optional branch unit for a pipelane.
-------------------------------------------------------------------------------
entity core_br is
--=============================================================================
  generic (
    
    -- Configuration.
    CFG                         : rvex_generic_config_type
    
  );
  port (
    
    ---------------------------------------------------------------------------
    -- System control
    ---------------------------------------------------------------------------
    -- Active high synchronous reset input.
    reset                       : in  std_logic;
    
    -- Clock input, registers are rising edge triggered.
    clk                         : in  std_logic;
    
    -- Active high global clock enable input.
    clkEn                       : in  std_logic;
    
    -- Active high stall input for the pipeline.
    stall                       : in  std_logic;
    
    ---------------------------------------------------------------------------
    -- VHDL simulation debug information
    ---------------------------------------------------------------------------
    -- pragma translate_off
    br2pl_sim                   : out rvex_string_builder_array(S_IF to S_IF);
    -- pragma translate_on
    
    ---------------------------------------------------------------------------
    -- Configuration inputs
    ---------------------------------------------------------------------------
    -- Number of coupled lane groups.
    cfg2br_numGroupsLog2        : in  rvex_2bit_type;
    
    ---------------------------------------------------------------------------
    -- Next operation outputs
    ---------------------------------------------------------------------------
    -- The PC for the current instruction, as chosen by the active branch unit
    -- within the group. The PC is distributed by the context-pipelane
    -- interface block so all coupled pipelanes have it.
    br2cxplif_PC                : out rvex_address_array(S_IF to S_IF);
    
    -- Whether an instruction fetch is being initiated or not.
    br2cxplif_imemFetch         : out std_logic_vector(S_IF to S_IF);
    br2cxplif_limmValid         : out std_logic_vector(S_IF to S_IF);
    
    -- Whether the next instruction is valid and should be committed or not.
    br2cxplif_valid             : out std_logic_vector(S_IF to S_IF);
    
    -- Whether breakpoints are valid in the next instruction or not. This is
    -- low when returning from a debug interrupt.
    br2cxplif_brkValid          : out std_logic_vector(S_IF to S_IF);
    
    -- Whether or not pipeline stages S_IF+1 to S_BR-1 should be invalidated
    -- due to a branch or the core stopping.
    br2cxplif_imemCancel        : out std_logic_vector(S_IF+L_IF to S_IF+L_IF);
    br2cxplif_invalUntilBR      : out std_logic_vector(S_BR to S_BR);
    
    ---------------------------------------------------------------------------
    -- Run control signals
    ---------------------------------------------------------------------------
    -- External interrupt identification. Guaranteed to be loaded in the trap
    -- argument register in the same clkEn'd cycle where irqAck is high.
    cxplif2br_irqID             : in  rvex_address_array(S_BR to S_BR);
    
    -- External interrupt acknowledge signal, active high. and'ed with the
    -- stall input, so it goes high for exactly one clkEn'abled cycle.
    br2cxplif_irqAck            : out std_logic_vector(S_BR to S_BR);
    
    -- Active high run signal. This is the combined run signal from the
    -- external run input and the BRK flag in the debug control register.
    cxplif2br_run               : in  std_logic;
    
    ---------------------------------------------------------------------------
    -- Branch control signals from and to pipelane
    ---------------------------------------------------------------------------
    -- Opcode for the branch unit.
    pl2br_opcode                : in  rvex_opcode_array(S_BR to S_BR);
    
    -- Whether the opcode is valid.
    pl2br_valid                 : in  std_logic_vector(S_BR to S_BR);
    
    -- PC+1 input for normal program flow.
    pl2br_PC_plusOne_IFP1       : in  rvex_address_array(S_IF+1 to S_IF+1);
    
    -- PC+1 input from branch stage for STOP instruction, which should stop
    -- execution and set the resumption PC to the instruction following the
    -- stop.
    pl2br_PC_plusOne_BR         : in  rvex_address_array(S_BR to S_BR);
    
    -- Link register branch target for RETURN, ICALL and IGOTO.
    pl2br_brTgtLink             : in  rvex_address_array(S_BR to S_BR);
    
    -- PC-relative branch target for other branch instructions.
    pl2br_brTgtRel              : in  rvex_address_array(S_BR to S_BR);
    
    -- Branch operand for conditional branches.
    pl2br_opBr                  : in  std_logic_vector(S_BR to S_BR);
    
    -- Whether a trap is pending in the pipeline somewhere.
    pl2br_trapPending           : in  std_logic_vector(S_BR to S_BR);
    
    -- Trap which should be handled by this instruction, if any, along with
    -- the trap point, and the address of the handler as it was while the
    -- instruction with the trap was being executed.
    pl2br_trapToHandleInfo      : in  trap_info_array(S_BR to S_BR);
    pl2br_trapToHandlePoint     : in  rvex_address_array(S_BR to S_BR);
    pl2br_trapToHandleHandler   : in  rvex_address_array(S_BR to S_BR);
    
    -- Commands the register logic to reset the trap cause to 0 and restore
    -- the control registers which were saved upon trap entry. This is sent to
    -- the pipelane first to delay it until S_MEM to keep the RFI command for
    -- the control registers synchronized with most other register accesses.
    br2pl_rfi                   : out std_logic_vector(S_BR to S_BR);
    
    -- Trap output for unaligned branches.
    br2pl_trap                  : out trap_info_array(S_BR to S_BR);
    
    ---------------------------------------------------------------------------
    -- Branch control signals from and to context registers
    ---------------------------------------------------------------------------
    -- The current value of the context PC register and associated override
    -- flag. When the override flag is set, the branch unit should behave as if
    -- there was a branch to the value in contextPC. This happens when the
    -- debug bus writes to the PC register.
    cxplif2br_contextPC         : in  rvex_address_array(S_IF+1 to S_IF+1);
    cxplif2br_overridePC        : in  std_logic_vector(S_IF+1 to S_IF+1);
    
    -- Trap information for the trap currently handled by the branch unit, if
    -- any. We can commit this in the branch stage already, because it is
    -- guaranteed that there is no instruction valid in S_MEM while a trap is
    -- entered.
    br2cxplif_trapInfo          : out trap_info_array(S_BR to S_BR);
    br2cxplif_trapPoint         : out rvex_address_array(S_BR to S_BR);
    
    -- Debug trap information for externally handled breakpoints. When the
    -- enable bit in the trap information record is high, the BRK bit should
    -- be set to halt the core and the trap information should be stored for
    -- the external debugger.
    br2cxplif_exDbgTrapInfo     : out trap_info_array(S_BR to S_BR);
    
    -- Stop signal, goes high when the branch unit is executing a stop
    -- instruction. When high, the done bit is set and the BRK bit is set to
    -- halt the core.
    br2cxplif_stop              : out std_logic_vector(S_BR to S_BR);
    
    -- Trap handler return address. This is just connected to the current value
    -- of the trap point register.
    cxplif2br_trapReturn        : in  rvex_address_array(S_BR to S_BR);
    
    -- Set when the current value of the trap cause register maps to a debug
    -- trap.
    cxplif2br_handlingDebugTrap : in  std_logic_vector(S_BR to S_BR);
    
    -- Whether debug traps are to be handled normally or by halting execution
    -- for debugging through the external bebug bus.
    cxplif2br_extDebug          : in  std_logic_vector(S_BR to S_BR)
    
  );
end core_br;

--=============================================================================
architecture Behavioral of core_br is
--=============================================================================
  
  -- Decoded opcode signals.
  signal ctrl                   : branchCtrlSignals_array(S_BR to S_BR);
  
  -- Combined run flag. run_r is delayes by one cycle so the first instruction
  -- after a halt can be detected.
  signal run, run_r             : std_logic_vector(S_BR to S_BR);
  
  -- Stop flags. When stop or stop_r are active, instruction fetching should be
  -- disabled, and if stop_r is active, a stop trap should be generated.
  signal stop, stop_r           : std_logic_vector(S_BR to S_BR);
  
  -- Breakpoint enable signal for the next instruction. Goes low for the first
  -- valid instruction after leaving a debug trap.
  signal brkptEnable            : std_logic_vector(S_IF to S_IF);
  
  -- Breakpoint enable set and reset signals.
  signal brkptEnableSet         : std_logic_vector(S_IF to S_IF);
  signal brkptEnableClear       : std_logic_vector(S_BR to S_BR);
  
  -- Next PC source type and signal.
  subtype nextPCsrc_type is std_logic_vector(2 downto 0);
  constant NEXT_PC_NORMAL       : nextPCsrc_type := "000"; -- Normal flow: PC(IF+1)+1
  constant NEXT_PC_CURRENT      : nextPCsrc_type := "001"; -- Current PC (halt): contextPC
  constant NEXT_PC_TRAP_POINT   : nextPCsrc_type := "010"; -- Incoming trap point
  constant NEXT_PC_TRAP_HANDLER : nextPCsrc_type := "011"; -- Trap handler
  constant NEXT_PC_TRAP_RETURN  : nextPCsrc_type := "100"; -- Trap return address (trap point register)
  constant NEXT_PC_BR_RELATIVE  : nextPCsrc_type := "101"; -- PC+1+offset
  constant NEXT_PC_BR_LINK      : nextPCsrc_type := "110"; -- Link register
  type nextPCsrc_array is array (natural range <>) of nextPCsrc_type;
  signal nextPCsrc              : nextPCsrc_array(S_BR to S_BR);
  
  -- Branch signal. This is high whenever the next PC source is something other
  -- than the "expected" normal PC+1 case.
  signal branching              : std_logic_vector(S_BR to S_BR);
  
  -- This is an output of the next PC decoding logic. When high, the next PC
  -- should NOT be post-decremented by 1 in the case that a necessary LIMMH
  -- operation might be present in the previous pair. This is the case when the
  -- core should be halted, to prevent the context PC register from
  -- decrementing.
  signal noLimmPrefetch         : std_logic_vector(S_BR to S_BR);
  
  -- Computed PC for IF stage.
  signal nextPC                 : rvex_address_array(S_IF to S_IF);
  
  -- This goes high when the next PC is not aligned to the syllable size for a
  -- single group.
  signal nextPCMisaligned       : std_logic_vector(S_IF to S_IF);
  
  -- Branch reason, for simulation.
  -- pragma translate_off
  signal simReason              : rvex_string_builder_type;
  -- pragma translate_on
  
  -- Action taken, for simulation.
  -- pragma translate_off
  signal simAction              : rvex_string_builder_type;
  -- pragma translate_on
  
--=============================================================================
begin -- architecture
--=============================================================================
  
  -----------------------------------------------------------------------------
  -- Generate internal control signals
  -----------------------------------------------------------------------------
  -- Decode the opcode.
  ctrl(S_BR) <= OPCODE_TABLE(vect2uint(pl2br_opcode(S_BR))).branchCtrl;
  
  -- Load the incoming run signal into a local signal for convenience.
  run(S_BR) <= cxplif2br_run;
  
  -- Generate the registers used to delay run and stop with.
  run_stop_reg_gen: process (clk) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        run_r(S_BR) <= '0';
        stop_r(S_BR) <= '0';
      elsif clkEn = '1' and stall = '0' then
        run_r(S_BR) <= run(S_BR);
        stop_r(S_BR) <= stop(S_BR);
      end if;
    end if;
  end process;
  
  -- Generate the breakpoint enable set/reset register. This is used to disable
  -- breakpoints in the first instruction processed after a debug trap.
  brk_enable_gen: process (clk) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        brkptEnable(S_IF) <= '1';
      elsif clkEn = '1' and stall = '0' then
        if brkptEnableClear(S_BR) = '1' then
          brkptEnable(S_IF) <= '0';
        elsif brkptEnableSet(S_IF) = '1' then
          brkptEnable(S_IF) <= '1';
        end if;
      end if;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Determine next PC source and control signal states
  -----------------------------------------------------------------------------
  det_branch: process (
    stall, ctrl, run, run_r, stop_r, cxplif2br_irqID,
    pl2br_valid, pl2br_opBr,
    pl2br_trapPending, cxplif2br_overridePC,
    pl2br_trapToHandleInfo, pl2br_trapToHandlePoint,
    cxplif2br_extDebug, cxplif2br_handlingDebugTrap
  ) is
  begin
    
    -- Set trap information defaults.
    br2cxplif_trapInfo(S_BR)      <= pl2br_trapToHandleInfo(S_BR);
    br2cxplif_trapPoint(S_BR)     <= pl2br_trapToHandlePoint(S_BR);
    br2cxplif_exDbgTrapInfo(S_BR) <= pl2br_trapToHandleInfo(S_BR);
    
    -- This is a normal branch by default.
    noLimmPrefetch(S_BR) <= '0';
    
    -- Set special instruction flags low by default.
    br2pl_rfi(S_BR) <= '0';
    br2cxplif_stop(S_BR) <= '0';
    stop(S_BR) <= '0';
    
    -- Don't clear the breakpoint enable register by default.
    brkptEnableClear(S_BR) <= '0';
    
    -- Do not acknowledge interrupts by default.
    br2cxplif_irqAck(S_BR) <= '0';
    
    if cxplif2br_overridePC(S_IF+1) = '1' then
      
      -- Branch to the address in the context PC register when requested.
      nextPCsrc(S_BR) <= NEXT_PC_CURRENT;
      
      -- pragma translate_off
      simReason <= to_rvs("resuming");
      -- pragma translate_on
      
    elsif pl2br_trapToHandleInfo(S_BR).active = '1' then
      
      -- Handle traps.
      if run(S_BR) = '0' then
        
        -- The core is halting. Instead of trying to handle the trap now, we
        -- delay this until the core resumes again, by simply resetting the PC
        -- to the instruction which caused the trap.
        nextPCsrc(S_BR) <= NEXT_PC_TRAP_POINT;
        br2cxplif_trapInfo(S_BR).active <= '0';
        br2cxplif_exDbgTrapInfo(S_BR).active <= '0';
        
        -- pragma translate_off
        simReason <= to_rvs("halting, deferring trap");
        -- pragma translate_on
        
      elsif (rvex_isDebugTrap(pl2br_trapToHandleInfo(S_BR)) = '1' and cxplif2br_extDebug(S_BR) = '1')
         or (rvex_isStopTrap(pl2br_trapToHandleInfo(S_BR)) = '1')
      then
        
        -- This is a debug trap and external debugging is turned on, or this is
        -- a stop trap (issued one cycle after a stop instruction). Disable
        -- regular trapping behavior; instead, halt the core (this happens
        -- automatically based on the exDbgTrapInfo.active signal or by means
        -- of the stop output signal) and set the resumption address/PC to the
        -- trap point.
        nextPCsrc(S_BR) <= NEXT_PC_TRAP_POINT;
        br2cxplif_trapInfo(S_BR).active <= '0';
        
        if rvex_isStopTrap(pl2br_trapToHandleInfo(S_BR)) = '1' then
          
          -- Assert the stop control signal, which sets the brk and done flags.
          br2cxplif_stop(S_BR) <= '1';
          
          -- pragma translate_off
          simReason <= to_rvs("stop trap");
          -- pragma translate_on
          
        else
          
          -- pragma translate_off
          simReason <= to_rvs("ext. debug trap");
          -- pragma translate_on
          
        end if;
        
      else
        
        -- This is a normal trap, or a debug trap with external debugging
        -- turned off. Hardware control register saving is handled
        -- automatically by the context register logic based on the
        -- trapInfo.active signal, so all we need to do is branch to the trap
        -- handler.
        nextPCsrc(S_BR) <= NEXT_PC_TRAP_HANDLER;
        br2cxplif_exDbgTrapInfo(S_BR).active <= '0';
        
        -- Handle interrupt handshaking and override the trap argument with the
        -- current interrupt ID.
        if rvex_isInterruptTrap(pl2br_trapToHandleInfo(S_BR)) = '1' then
          br2cxplif_trapInfo(S_BR).arg <= cxplif2br_irqID(S_BR);
          br2cxplif_irqAck(S_BR) <= not stall;
        end if;
        
        -- pragma translate_off
        simReason <= to_rvs("trap");
        -- pragma translate_on
        
      end if;
      
    elsif ctrl(S_BR).RFI = '1' and pl2br_valid(S_BR) = '1' then
      
      -- RFI instruction. Jump to the trap return address (stored in the trap
      -- point context control register) and set the RFI flag high for the
      -- control register restore logic.
      nextPCsrc(S_BR) <= NEXT_PC_TRAP_RETURN;
      br2pl_rfi(S_BR) <= '1';
      
      -- If we were are returning from a debug trap, disable breakpoints for
      -- the next cycle.
      brkptEnableClear(S_BR) <= cxplif2br_handlingDebugTrap(S_BR);
      
      -- pragma translate_off
      simReason <= to_rvs("RFI instr.");
      -- pragma translate_on
      
    elsif ctrl(S_BR).stop = '1' and pl2br_valid(S_BR) = '1' then
      
      -- Stop instruction. We want to generate a stop trap with the trap point
      -- set to PC+1; easiest way to do that is to just proceed to the next
      -- instruction and cause a trap there. So, we select the regular PC+1 mux
      -- input for the next PC, and set a stop flag. This flag will do two
      -- things: it prevents the next opcode fetch and it is delayed by one
      -- cycle to cause the trap. Note that we need to check for validity here,
      -- because otherwise we'd be committing a trap for a disabled
      -- instruction.
      nextPCsrc(S_BR) <= NEXT_PC_NORMAL;
      stop(S_BR) <= '1';
      
      -- pragma translate_off
      simReason <= to_rvs("STOP instr.");
      -- pragma translate_on
      
    elsif (
      (ctrl(S_BR).branchIfTrue  and     pl2br_opBr(S_BR)) or
      (ctrl(S_BR).branchIfFalse and not pl2br_opBr(S_BR))
    ) = '1' and pl2br_valid(S_BR) = '1' then
      
      -- Regular branch instruction. Jump to the selected branch target.
      if ctrl(S_BR).branchToLink = '1' then
        nextPCsrc(S_BR) <= NEXT_PC_BR_LINK;
        -- pragma translate_off
        simReason <= to_rvs("branch to link");
        -- pragma translate_on
      else
        nextPCsrc(S_BR) <= NEXT_PC_BR_RELATIVE;
        -- pragma translate_off
        simReason <= to_rvs("relative branch");
        -- pragma translate_on
      end if;
      
    elsif run(S_BR) = '0' or pl2br_trapPending(S_BR) = '1' then
      
      -- Halt the core. We need to "branch" to the current instruction
      -- constantly while the core is halted to maintain the current value of
      -- the PC register.
      nextPCsrc(S_BR) <= NEXT_PC_CURRENT;
      
      -- Don't try to fetch the previous instruction, because that will mess up
      -- the PC register.
      noLimmPrefetch(S_BR) <= '1';
      
      -- pragma translate_off
      if run(S_BR) = '0' then
        if pl2br_trapPending(S_BR) = '1' then
          simReason <= to_rvs("halting, trap pending");
        else
          simReason <= to_rvs("halting");
        end if;
      else
        simReason <= to_rvs("trap pending");
      end if;
      -- pragma translate_on
      
    elsif run_r(S_BR) = '0' then
      
      -- (Re)start the core. We need to actively jump to the context PC
      -- register in order to start at that address and not the address
      -- immediately following.
      nextPCsrc(S_BR) <= NEXT_PC_CURRENT;
      
      -- pragma translate_off
      simReason <= to_rvs("resuming");
      -- pragma translate_on
      
    else
      
      -- Normal operation; don't branch.
      nextPCsrc(S_BR) <= NEXT_PC_NORMAL;
      
      -- No need to fetch the previous instruction first, because we either
      -- have already done that at this point or instructions are being
      -- executed in order.
      noLimmPrefetch(S_BR) <= '1';
      
      -- pragma translate_off
      simReason <= to_rvs("running");
      -- pragma translate_on
    end if;
    
    -- pragma translate_off
    if stop_r(S_BR) = '1' then
      simReason <= to_rvs("causing stop trap");
    end if;
    -- pragma translate_on
    
    
  end process;
  
  -----------------------------------------------------------------------------
  -- Instantiate mux for the next PC
  -----------------------------------------------------------------------------
  next_pc_mux: process (
    pl2br_PC_plusOne_BR, pl2br_brTgtLink, pl2br_brTgtRel, cxplif2br_trapReturn,
    pl2br_trapToHandlePoint, pl2br_trapToHandleHandler, cxplif2br_contextPC,
    pl2br_PC_plusOne_IFP1, nextPCsrc
  ) is
  begin
    case nextPCsrc(S_BR) is
      when NEXT_PC_CURRENT      => nextPC(S_IF) <= cxplif2br_contextPC(S_IF+1);
      when NEXT_PC_TRAP_POINT   => nextPC(S_IF) <= pl2br_trapToHandlePoint(S_BR);
      when NEXT_PC_TRAP_HANDLER => nextPC(S_IF) <= pl2br_trapToHandleHandler(S_BR);
      when NEXT_PC_TRAP_RETURN  => nextPC(S_IF) <= cxplif2br_trapReturn(S_BR);
      when NEXT_PC_BR_RELATIVE  => nextPC(S_IF) <= pl2br_brTgtRel(S_BR);
      when NEXT_PC_BR_LINK      => nextPC(S_IF) <= pl2br_brTgtLink(S_BR);
      when others               => nextPC(S_IF) <= pl2br_PC_plusOne_IFP1(S_IF+1);
    end case;
  end process;
  
  -- Determine whether we're branching or not.
  branching(S_BR) <= '1' when nextPCsrc(S_BR) /= NEXT_PC_NORMAL else '0';
  
  -----------------------------------------------------------------------------
  -- Test next PC alignment
  -----------------------------------------------------------------------------
  -- Determine if the branch target is aligned.
  nextPCMisaligned(S_IF) <=
    '0' when
      vect2uint(nextPC(S_IF)(
        (CFG.numLanesLog2-CFG.numLaneGroupsLog2)+SYLLABLE_SIZE_LOG2B-1 downto 0
      )) = 0
    else '1';
  
  -----------------------------------------------------------------------------
  -- Drive trap output.
  -----------------------------------------------------------------------------
  trap_output: process (
    nextPCMisaligned, nextPC, stop_r
  ) is
    variable ti : trap_info_type;
  begin
    
    -- Cause misaligned branch traps.
    ti := (
      active => nextPCMisaligned(S_IF),
      cause  => rvex_trap(RVEX_TRAP_MISALIGNED_BRANCH),
      arg    => nextPC(S_IF)
    );
    
    -- Cause stop traps.
    ti := ti & (
      active => stop_r(S_BR),
      cause  => rvex_trap(RVEX_TRAP_STOP),
      arg    => nextPC(S_IF) -- This is don't care; use the misaligned branch
    );                       -- trap arg to save a mux.
    
    -- Drive the trap output.
    br2pl_trap(S_BR) <= ti;
    
  end process;
  
  -----------------------------------------------------------------------------
  -- Determine which operation to perform next
  -----------------------------------------------------------------------------
  det_next_op: process (
    nextPC, branching, noLimmPrefetch, cfg2br_numGroupsLog2, run, run_r,
    pl2br_trapPending, brkptEnable, nextPCMisaligned, stop, stop_r
  ) is
    variable nextPC_v           : rvex_address_array(S_IF to S_IF);
    variable fetch              : std_logic_vector(S_IF to S_IF);
    variable fetchOnly          : std_logic_vector(S_IF to S_IF);
    variable numCoupledLanesLog2: natural;
    -- pragma translate_off
    variable simAction_v        : rvex_string_builder_type;
    -- pragma translate_on
  begin
    
    -- Determine log2(number of coupled lanes).
    numCoupledLanesLog2 :=
      vect2uint(cfg2br_numGroupsLog2)             -- Number of coupled groups.
      + (CFG.numLanesLog2-CFG.numLaneGroupsLog2); -- Number of lanes per group.
    
    -- Check if we need to fetch the previous instruction first for the
    -- long-immediate-from-previous-pair logic.
    fetchOnly(S_IF) := '0';
    if CFG.limmhFromPreviousPair and noLimmPrefetch(S_BR) = '0' then
      
      -- Fetch the previous instruction first if:
      --  - the next PC is aligned to the current number of lanes operating
      --    (i.e., in 4-way mode, the PC is aligned to 4 syllables), and
      --  - the next PC is NOT aligned to the generic binary bunble size.
      
      -- Test alignment to number of coupled lanes.
      if vect2uint(nextPC(S_IF)(
        numCoupledLanesLog2+SYLLABLE_SIZE_LOG2B-1 downto
        (CFG.numLanesLog2-CFG.numLaneGroupsLog2)+SYLLABLE_SIZE_LOG2B
      )) = 0 then
        
        -- Test misalignment to generic bundle size.
        if vect2uint(nextPC(S_IF)(
          CFG.genBundleSizeLog2+SYLLABLE_SIZE_LOG2B-1 downto
          (CFG.numLanesLog2-CFG.numLaneGroupsLog2)+SYLLABLE_SIZE_LOG2B
        )) /= 0 then
          
          fetchOnly(S_IF) := '1';
          
        end if;
        
      end if;
      
    end if;
    
    -- Subtract 1 from the PC when we need to fetch the previous instruction
    -- first.
    nextPC_v(S_IF) := nextPC(S_IF);
    if fetchOnly(S_IF) = '1' then
      
      -- This does not need to be a full subtractor, because we never
      -- subtract beyond addresses aligned by the generic bundle size
      -- (because there will never be relevant long immediate instructions
      -- in the previous generic binary bundle).
      nextPC_v(S_IF)(CFG.genBundleSizeLog2+SYLLABLE_SIZE_LOG2B-1 downto SYLLABLE_SIZE_LOG2B)
        := std_logic_vector(
          vect2unsigned(nextPC(S_IF)(CFG.genBundleSizeLog2+SYLLABLE_SIZE_LOG2B-1 downto SYLLABLE_SIZE_LOG2B))
          - to_unsigned(2**(numCoupledLanesLog2), CFG.genBundleSizeLog2)
        );
      
    end if;
    
    -- Determine if we want to fetch the next instruction.
    fetch(S_IF)
      := run(S_BR)
      and (not pl2br_trapPending(S_BR))
      and (not nextPCMisaligned(S_IF))
      and (not stop(S_BR))
      and (not stop_r(S_BR));
    
    -- Drive PC output signals.
    br2cxplif_PC(S_IF)                <= nextPC_v(S_IF);
    
    -- Drive fetch output signals.
    br2cxplif_imemFetch(S_IF)         <= fetch(S_IF);
    br2cxplif_limmValid(S_IF)         <= fetch(S_IF);
    
    -- Drive valid output signals.
    br2cxplif_valid(S_IF)             <= fetch(S_IF) and not fetchOnly(S_IF);
    brkptEnableSet(S_IF)              <= fetch(S_IF) and not fetchOnly(S_IF);
    
    -- Drive breakpoint enable signals.
    br2cxplif_brkValid(S_IF)          <= brkptEnable(S_IF);
    
    -- Drive cancel/invalidate signals.
    br2cxplif_imemCancel(S_IF+L_IF)   <= branching(S_BR);
    br2cxplif_invalUntilBR(S_BR)      <= branching(S_BR);
    
    -- Generate simulation information.
    -- pragma translate_off
    if GEN_VHDL_SIM_INFO then
      rvs_clear(simAction_v);
      if fetch(S_IF) = '0' then
        rvs_append(simAction_v, "did not fetch ");
      elsif fetchOnly(S_IF) = '1' then
        rvs_append(simAction_v, "LIMMH-fetched ");
      else
        rvs_append(simAction_v, "fetched ");
      end if;
      rvs_append(simAction_v, rvs_hex(nextPC_v(S_IF)));
      rvs_append(simAction_v, "; ");
      simAction <= simAction_v;
    end if;
    -- pragma translate_on
    
  end process;
  
  -- Merge debugging information.
  -- pragma translate_off
  sim_info_gen: if GEN_VHDL_SIM_INFO generate
    br2pl_sim(S_IF) <= simAction & simReason;
  end generate;
  -- pragma translate_on
  
end Behavioral;
