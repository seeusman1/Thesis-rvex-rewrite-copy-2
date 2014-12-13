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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library rvex;
use rvex.common_pkg.all;
use rvex.utils_pkg.all;
use rvex.bus_pkg.all;

--=============================================================================
-- This entity infers block RAMs, which are accessible using the standard bus
-- interface specified in bus_pkg.vhd. Both memory ports are 
-------------------------------------------------------------------------------
entity bus_ramBlock is
--=============================================================================
  generic (
    
    -- Size of the memory, specified as log2(size_in_bytes).
    DEPTH_LOG2B                 : natural
    
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
    
    ---------------------------------------------------------------------------
    -- Memory ports.
    ---------------------------------------------------------------------------
    -- Only the address bits from DEPTH_LOG2B-1 downto 2 are used. No faults
    -- are generated for out-of-range accesses; the memory is mirrored in
    -- stead.
    
    -- Memory port A.
    mst2mem_portA               : in  bus_mst2slv_type;
    mem2mst_portA               : out bus_slv2mst_type;
    
    -- Memory port B.
    mst2mem_portB               : in  bus_mst2slv_type;
    mem2mst_portB               : out bus_slv2mst_type
    
  );
end bus_ramBlock;

--=============================================================================
architecture Behavioral of bus_ramBlock is
--=============================================================================
  
  -- Current contents of the RAM. We need to use a shared variable to allow XST
  -- to recognize a RAM with two write ports.
  shared variable ram           : rvex_data_array(0 to 2**(DEPTH_LOG2B-2)-1);
  
  constant prt : natural := 0;
--=============================================================================
begin -- architecture
--=============================================================================
  
  -- Generate memory port A.
  port_A_proc: process (clk) is
    variable addr : natural range 0 to 2**(DEPTH_LOG2B-2)-1;
  begin
    if rising_edge(clk) then
      if clkEn = '1' then
        
        -- Decode address.
        addr := vect2uint(mst2mem_portA.address(DEPTH_LOG2B-1 downto 2));
        
        -- Handle writes.
        for b in 0 to 3 loop
          if mst2mem_portA.writeEnable = '1' and mst2mem_portA.writeMask(b) = '1' then
            ram(addr)(b*8+7 downto b*8) := mst2mem_portA.writeData(b*8+7 downto b*8);
          end if;
        end loop;
        
        -- Handle reads.
        mem2mst_portA.readData <= ram(addr);
        
      end if;
    end if;
  end process;
  
  -- Generate memory port B.
  port_B_proc: process (clk) is
    variable addr : natural range 0 to 2**(DEPTH_LOG2B-2)-1;
  begin
    if rising_edge(clk) then
      if clkEn = '1' then
        
        -- Decode address.
        addr := vect2uint(mst2mem_portB.address(DEPTH_LOG2B-1 downto 2));
        
        -- Handle writes.
        for b in 0 to 3 loop
          if mst2mem_portB.writeEnable = '1' and mst2mem_portB.writeMask(b) = '1' then
            ram(addr)(b*8+7 downto b*8) := mst2mem_portB.writeData(b*8+7 downto b*8);
          end if;
        end loop;
        
        -- Handle reads.
        mem2mst_portB.readData <= ram(addr);
        
      end if;
    end if;
  end process;
  
  -- Tie the fault and busy signals to '0'.
  mem2mst_portA.fault <= '0';
  mem2mst_portA.busy <= '0';
  mem2mst_portB.fault <= '0';
  mem2mst_portB.busy <= '0';
  
end Behavioral;

