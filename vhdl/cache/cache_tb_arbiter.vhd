-- r-VEX processor
-- Copyright (C) 2008-2014 by TU Delft.
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

-- Copyright (C) 2008-2014 by TU Delft.

-- Refer to reconfCache_pkg.vhd for configuration constants and most
-- documentation.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library rvex;
use rvex.cache_pkg.all;

entity cache_tb_arbiter is
  port (
    
    -- Clock input.
    clk                       : in  std_logic;
    
    -- Active high reset input.
    reset                     : in  std_logic;
    
    -- Active high clock enable input.
    clkEn                     : in  std_logic;
    
    -- Slave bus A.
    arbToCacheA               : out reconfCache_memIn;
    cacheAToArb               : in  reconfCache_memOut;
    
    -- Slave bus B.
    arbToCacheB               : out reconfCache_memIn;
    cacheBToArb               : in  reconfCache_memOut;
    
    -- Master bus.
    memToArb                  : in  reconfCache_memIn;
    arbToMem                  : out reconfCache_memOut
    
  );
end cache_tb_arbiter;

architecture Behavioral of cache_tb_arbiter is
  
  -- State machine state/mux selection signals.
  signal selectCacheB_next    : std_logic;
  signal selectCacheB         : std_logic;
  
begin
  
  --===========================================================================
  -- Generate mux/demux logic
  --===========================================================================
  arbToCacheA.ready     <= memToArb.ready and not selectCacheB;
  arbToCacheA.data      <= memToArb.data;
  
  arbToCacheB.ready     <= memToArb.ready and selectCacheB;
  arbToCacheB.data      <= memToArb.data;
  
  arbToMem.addr         <= cacheBToArb.addr        when selectCacheB_next = '1' else cacheAToArb.addr;
  arbToMem.readEnable   <= cacheBToArb.readEnable  when selectCacheB_next = '1' else cacheAToArb.readEnable;
  arbToMem.writeData    <= cacheBToArb.writeData   when selectCacheB_next = '1' else cacheAToArb.writeData;
  arbToMem.writeMask    <= cacheBToArb.writeMask   when selectCacheB_next = '1' else cacheAToArb.writeMask;
  arbToMem.writeEnable  <= cacheBToArb.writeEnable when selectCacheB_next = '1' else cacheAToArb.writeEnable;
  arbToMem.burstEnable  <= cacheBToArb.burstEnable when selectCacheB_next = '1' else cacheAToArb.burstEnable;
  
  --===========================================================================
  -- Generate the selection state machine
  --===========================================================================
  select_comb: process (
    memToArb.ready, selectCacheB,
    cacheAToArb.readEnable, cacheAToArb.writeEnable,
    cacheBToArb.readEnable, cacheBToArb.writeEnable
  ) is
  begin
    if memToArb.ready = '1' then
      
      -- If the other cache wants to do a bus access, switch.
      if selectCacheB = '1' then
        if cacheAToArb.readEnable = '1' or cacheAToArb.writeEnable = '1' then
          selectCacheB_next <= '0';
        else
          selectCacheB_next <= '1';
        end if;
      else
        if cacheBToArb.readEnable = '1' or cacheBToArb.writeEnable = '1' then
          selectCacheB_next <= '1';
        else
          selectCacheB_next <= '0';
        end if;
      end if;
      
    else
      
      -- Switching is not allowed in the middle of a transaction.
      selectCacheB_next <= selectCacheB;
      
    end if;
  end process;
  
  select_seq: process (clk) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        selectCacheB <= '0';
      elsif clkEn = '1' then
        selectCacheB <= selectCacheB_next;
      end if;
    end if;
  end process;
  
end Behavioral;
