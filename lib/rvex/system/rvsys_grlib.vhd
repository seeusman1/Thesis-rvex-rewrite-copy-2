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
use rvex.bus_pkg.all;
use rvex.core_pkg.all;
use rvex.cache_pkg.all;
use rvex.rvsys_grlib_pkg.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;

library gaisler;
use gaisler.leon3.all;

--=============================================================================
-- This entity is designed such that it can be used in place of the LEON3 core
-- from grlib.
-------------------------------------------------------------------------------
entity rvsys_grlib is
--=============================================================================
  generic (
    
    -- Configuration vector.
    CFG                         : rvex_grlib_generic_config_type := rvex_grlib_cfg;
    
    -- AHB master starting index. There will be as many AHB masters as there
    -- are lane groups in the core.
    AHB_MASTER_INDEX_START      : integer range 0 to NAHBMST-1 := 0;
    
    -- APB slave index.
    APB_INDEX                   : integer := 0;
    
    -- APB slave configuration. ADDR and MASK define the address ranges which
    -- the rvex should respond to, mapping to address bits 19 downto 8. With
    -- 8 bits of address space, all rvex core debug registers are mapped
    -- through the banking mechanism. With 9 bits of address space, additional
    -- platform-specific registers are mapped as well. With 13 bits of address
    -- space, all registers are mapped without banking. The address map is
    -- depicted below:
    -- 
    --          _____________________________
    --  0x1FFF | Context 7 GP reg 32-63      |
    --  0x1F80 |_____________________________|
    --         |_____________________________|
    --  0x1EFF | Context 7 GP reg 0-31       |
    --  0x1E80 |_____________________________|
    --  0x1E7F | Context 7 ctrl regs         |
    --  0x1E00 |_____________________________|
    --  0x1DFF | (context 1..6 mapped here)  |
    --  0x1200 |_____________________________|
    --  0x11FF | Context 0 GP reg 32-63      |
    --  0x1180 |_____________________________|
    --         |_____________________________|
    --  0x10FF | Context 0 GP reg 0-31       |
    --  0x1080 |_____________________________|
    --  0x107F | Context 0 ctrl regs         |
    --  0x1000 |_____________________________|
    --         |_____________________________|
    --  0x01FF | Reserved for MMU regs       |
    --  0x0180 |_____________________________|
    --  0x017F | Reserved for cache regs     |
    --  0x0100 |_____________________________| _
    --  0x00FF | Context i GP reg 0-31/32-63 |  \
    --  0x0080 |_____________________________|   \ Context and GP registers are
    --  0x007F | Context i ctrl regs         |   / selected using bank register
    --  0x0000 |_____________________________| _/
    -- 
    -- By default, we'll claim the full 13 bits of address space.
    APB_ADDR                    : integer := 0;
    APB_MASK                    : integer := 16#FE0#
    
  );
  port (
    
    ---------------------------------------------------------------------------
    -- System control
    ---------------------------------------------------------------------------
    -- Clock input, registers are rising edge triggered.
    clki                        : in  std_ulogic;
    
    -- Active *low* synchronous reset input.
    rstn                        : in  std_ulogic;
    
    ---------------------------------------------------------------------------
    -- Processor interface
    ---------------------------------------------------------------------------
    -- AHB master interface. This is used for instruction and data access. Each
    -- lane group has its own AHB master.
    ahbi                        : in  ahb_mst_in_type;
    ahbo                        : out ahb_mst_out_vector_type(2**CFG.core.numLaneGroupsLog2-1 downto 0);
    
    -- APB slave port, used to access the rvex debug and status registers from
    -- the bus.
    apbi                        : in  apb_slv_in_type;
    apbo                        : out apb_slv_out_type;
    
    -- Interrupt controller interface. This entity handles translation from the
    -- LEON3 interrupt controller to the rvex interrupt control signals. Note
    -- that each rvex context requires its own interrupt controller.
    irqi                        : in  irq_in_vector(0 to 2**CFG.core.numContextsLog2-1);
    irqo                        : out irq_out_vector(0 to 2**CFG.core.numContextsLog2-1)
    
  );
end rvsys_grlib;

--=============================================================================
architecture Behavioral of rvsys_grlib is
--=============================================================================
  
  -- System control signals in the rvex library format.
  signal resetCPU               : std_logic;
  signal resetBus               : std_logic;
  signal clk                    : std_logic;
  signal clkEnCPU               : std_logic;
  signal clkEnBus               : std_logic;
  
  -- Soft reset signal from the APB bus.
  signal dbg_reset              : std_logic;
  
  -- rvex interrupt interface signals.
  signal rctrl2rv_irq           : std_logic_vector(2**CFG.core.numContextsLog2-1 downto 0);
  signal rctrl2rv_irqID         : rvex_address_array(2**CFG.core.numContextsLog2-1 downto 0);
  signal rv2rctrl_irqAck        : std_logic_vector(2**CFG.core.numContextsLog2-1 downto 0);
  
  -- rvex debug bus interface signals.
  signal dbg2rv_addr            : rvex_address_type;
  signal dbg2rv_readEnable      : std_logic;
  signal dbg2rv_writeEnable     : std_logic;
  signal dbg2rv_writeMask       : rvex_mask_type;
  signal dbg2rv_writeData       : rvex_data_type;
  signal rv2dbg_readData        : rvex_data_type;
  
  -- Common cache interface signals.
  signal rv2cache_decouple      : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal cache2rv_blockReconfig : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal cache2rv_stallIn       : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal rv2cache_stallOut      : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  
  -- Instruction cache interface signals.
  signal rv2icache_PCs          : rvex_address_array(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal rv2icache_fetch        : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal rv2icache_cancel       : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal icache2rv_instr        : rvex_syllable_array(2**CFG.core.numLanesLog2-1 downto 0);
  signal icache2rv_affinity     : std_logic_vector(2**CFG.core.numLaneGroupsLog2*CFG.core.numLaneGroupsLog2-1 downto 0);
  
  -- Data cache interface signals.
  signal rv2dcache_addr         : rvex_address_array(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal rv2dcache_readEnable   : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal rv2dcache_writeData    : rvex_data_array(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal rv2dcache_writeMask    : rvex_mask_array(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal rv2dcache_writeEnable  : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal rv2dcache_bypass       : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal dcache2rv_readData     : rvex_data_array(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  
  -- Cache to AHB bus bridge interface signals.
  signal cache2bridge_bus       : bus_mst2slv_array(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal bridge2cache_bus       : bus_slv2mst_array(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  
  -- Bus address which is to be invalidated when invalEnable is high.
  signal bus2cache_invalAddr    : rvex_address_type;
  
  -- If one of the data caches is causing the invalidation due to a write,
  -- the signal in this vector indexed by that data cache must be high. In
  -- all other cases, these signals should be low.
  signal bus2cache_invalSource  : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  
  -- Active high enable signal for line invalidation.
  signal bus2cache_invalEnable  : std_logic;
  
  -- Flush control signals.
  signal sc2icache_flush        : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  signal sc2dcache_flush        : std_logic_vector(2**CFG.core.numLaneGroupsLog2-1 downto 0);
  
--=============================================================================
begin -- architecture
--=============================================================================
  
  -- The APB bus is not used yet.
  apbo <= apb_none;
  
  -----------------------------------------------------------------------------
  -- System control
  -----------------------------------------------------------------------------
  resetCPU  <= dbg_reset or not rstn;
  resetBus  <= not rstn;
  clk       <= clki;
  clkEnCPU  <= '1';
  clkEnBus  <= '1';
  
  -----------------------------------------------------------------------------
  -- Instantiate the rvex core
  -----------------------------------------------------------------------------
  rvex_inst: entity rvex.core
    generic map (
      CFG                       => CFG.core
    )
    port map (
      
      -- System control.
      reset                     => resetCPU,
      clk                       => clk,
      clkEn                     => clkEnCPU,
      
      -- Run control interface.
      rctrl2rv_irq              => rctrl2rv_irq,
      rctrl2rv_irqID            => rctrl2rv_irqID,
      rv2rctrl_irqAck           => rv2rctrl_irqAck,
      
      -- Common memory interface.
      rv2mem_decouple           => rv2cache_decouple,
      mem2rv_blockReconfig      => cache2rv_blockReconfig,
      mem2rv_stallIn            => cache2rv_stallIn,
      rv2mem_stallOut           => rv2cache_stallOut,
      
      -- Instruction memory interface.
      rv2imem_PCs               => rv2icache_PCs,
      rv2imem_fetch             => rv2icache_fetch,
      rv2imem_cancel            => rv2icache_cancel,
      imem2rv_instr             => icache2rv_instr,
      imem2rv_affinity          => icache2rv_affinity,
      
      -- Data memory interface.
      rv2dmem_addr              => rv2dcache_addr,
      rv2dmem_readEnable        => rv2dcache_readEnable,
      rv2dmem_writeData         => rv2dcache_writeData,
      rv2dmem_writeMask         => rv2dcache_writeMask,
      rv2dmem_writeEnable       => rv2dcache_writeEnable,
      dmem2rv_readData          => dcache2rv_readData,
      
      -- Control/debug bus interface.
      dbg2rv_addr               => dbg2rv_addr,
      dbg2rv_readEnable         => dbg2rv_readEnable,
      dbg2rv_writeEnable        => dbg2rv_writeEnable,
      dbg2rv_writeMask          => dbg2rv_writeMask,
      dbg2rv_writeData          => dbg2rv_writeData,
      rv2dbg_readData           => rv2dbg_readData
      
    );
  
  -----------------------------------------------------------------------------
  -- Generate the bypass signals
  -----------------------------------------------------------------------------
  -- When the bypass signal is high, memory accesses bypass the cache. This is
  -- important for peripheral accesses. Because the rvex core does not generate
  -- such a signal, we generate one here based on the address: we assume that
  -- everything in the high 2 GiB memory space is mapped to peripherals and
  -- should not be cached.
  bypass_gen: for laneGroup in 2**CFG.core.numLaneGroupsLog2-1 downto 0 generate
    rv2dcache_bypass(laneGroup) <= rv2dcache_addr(laneGroup)(31);
  end generate;
  
  -----------------------------------------------------------------------------
  -- Instantiate the cache
  -----------------------------------------------------------------------------
  cache_inst: entity rvex.cache
    generic map (
      RCFG                      => CFG.core,
      CCFG                      => CFG.cache
    )
    port map (
      
      -- System control.
      reset                     => resetCPU,
      clk                       => clk,
      clkEnCPU                  => clkEnCPU,
      clkEnBus                  => clkEnBus,
      
      -- Core common memory interface.
      rv2cache_decouple         => rv2cache_decouple,
      cache2rv_blockReconfig    => cache2rv_blockReconfig,
      cache2rv_stallIn          => cache2rv_stallIn,
      rv2cache_stallOut         => rv2cache_stallOut,
      
      -- Core instruction memory interface.
      rv2icache_PCs             => rv2icache_PCs,
      rv2icache_fetch           => rv2icache_fetch,
      rv2icache_cancel          => rv2icache_cancel,
      icache2rv_instr           => icache2rv_instr,
      icache2rv_affinity        => icache2rv_affinity,
      
      -- Core data memory interface.
      rv2dcache_addr            => rv2dcache_addr,
      rv2dcache_readEnable      => rv2dcache_readEnable,
      rv2dcache_writeData       => rv2dcache_writeData,
      rv2dcache_writeMask       => rv2dcache_writeMask,
      rv2dcache_writeEnable     => rv2dcache_writeEnable,
      rv2dcache_bypass          => rv2dcache_bypass,
      dcache2rv_readData        => dcache2rv_readData,
      
      -- Bus master interface.
      cache2bus_bus             => cache2bridge_bus,
      bus2cache_bus             => bridge2cache_bus,
      
      -- Bus snooping interface.
      bus2cache_invalAddr       => bus2cache_invalAddr,
      bus2cache_invalSource     => bus2cache_invalSource,
      bus2cache_invalEnable     => bus2cache_invalEnable,
      
      -- Status and control signals.
      sc2icache_flush           => sc2icache_flush,
      sc2dcache_flush           => sc2dcache_flush
      
    );
  
  -----------------------------------------------------------------------------
  -- Instantiate the AHB bus bridges
  -----------------------------------------------------------------------------
  ahb_bus_bridge_gen: for laneGroup in 2**CFG.core.numLaneGroupsLog2-1 downto 0 generate
    
    ahb_bus_bridge_inst: entity rvex.bus2ahb
      generic map (
        
        -- Generic information as passed to grlib.dma2ahb.
        AHB_MASTER_INDEX        => AHB_MASTER_INDEX_START + laneGroup,
        AHB_VENDOR_ID           => VENDOR_TUDELFT,
        AHB_DEVICE_ID           => TUDELFT_RVEX,
        AHB_VERSION             => 0,
        
        -- rvex bus fault code used to indicate that an AHB bus error occured.
        BUS_ERROR_CODE          => (others => '0')
        
      )
      port map (
        
        -- System control.
        reset                   => resetBus,
        clk                     => clk,
        
        -- rvex library slave bus interface.
        bus2bridge              => cache2bridge_bus(laneGroup),
        bridge2bus              => bridge2cache_bus(laneGroup),
        
        -- AHB master interface.
        bridge2ahb              => ahbo(laneGroup),
        ahb2bridge              => ahbi
        
      );
    
  end generate;
  
  -----------------------------------------------------------------------------
  -- Bus snooper
  -----------------------------------------------------------------------------
  -- TODO
  bus2cache_invalAddr   <= (others => '0');
  bus2cache_invalSource <= (others => '0');
  bus2cache_invalEnable <= '0';
  
  -----------------------------------------------------------------------------
  -- Interrupt controller bridge
  -----------------------------------------------------------------------------
  irq_bridge_gen: for ctxt in 2**CFG.core.numContextsLog2-1 downto 0 generate
    
    -- TODO
    rctrl2rv_irq(ctxt)    <= '0';
    rctrl2rv_irqID(ctxt)  <= (others => '0');
    irqo(ctxt).intack     <= '0';
    irqo(ctxt).irl        <= "0000";
    irqo(ctxt).pwd        <= '0';
    irqo(ctxt).fpen       <= '0';
    irqo(ctxt).idle       <= '1';
    
  end generate;
  
  -----------------------------------------------------------------------------
  -- APB interface
  -----------------------------------------------------------------------------
  -- TODO
  dbg2rv_addr         <= (others => '0');
  dbg2rv_readEnable   <= '0';
  dbg2rv_writeEnable  <= '0';
  dbg2rv_writeMask    <= (others => '0');
  dbg2rv_writeData    <= (others => '0');
  sc2icache_flush     <= (others => '0');
  sc2dcache_flush     <= (others => '0');
  dbg_reset           <= '0';
  
end Behavioral;
