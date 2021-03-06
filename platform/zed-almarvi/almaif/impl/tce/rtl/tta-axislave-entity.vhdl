-- Copyright (c) 2016 Nokia Research Center
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
-------------------------------------------------------------------------------
-- Title      : AXI lite interface to TTA debugger and stream IO
-- Project    : 
-------------------------------------------------------------------------------
-- File       : axi4dbgslave-entity.vhdl
-- Author     : Tommi Zetterman  <tommi.zetterman@nokia.com>
-- Company    : Nokia Research Center
-- Created    : 2014-06-10
-- Last update: 2015-01-27
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 Nokia Research Center
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-06-23  1.0      zetterma Created (as axi4dbgslave-rtl.vhdl
-- 2015-01-27  1.1      viitanet Modified into a processor wrapper
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- TTA memory interfaces
use work.tta0_globals.all;
use work.tta0_params.all;
use work.tta0_imem_mau.all;
use work.misc.all;
use work.debugger_if.all;

entity tta_axislave is
  generic (
    -- Must be at least 2 + mmax(mmax(IMEMADDRWIDTH+1,debreg_addr_width_c),fu_LSU_addrw-2)
    axi_addrw_g : integer := 17
  );
  port (
    clk       : in std_logic;
    nreset    : in std_logic;

    -- AXI slave port
    s_axi_awaddr   : in  STD_LOGIC_VECTOR (axi_addrw_g-1 downto 0);
    s_axi_awvalid  : in  STD_LOGIC;
    s_axi_awready  : out STD_LOGIC;
    s_axi_wdata    : in  STD_LOGIC_VECTOR (31 downto 0);
    s_axi_wstrb    : in  STD_LOGIC_VECTOR (3 downto 0);
    s_axi_wvalid   : in  STD_LOGIC;
    s_axi_wready   : out STD_LOGIC;
    s_axi_bresp    : out STD_LOGIC_VECTOR (2-1 downto 0);
    s_axi_bvalid   : out STD_LOGIC;
    s_axi_bready   : in  STD_LOGIC;
    s_axi_araddr   : in  STD_LOGIC_VECTOR (axi_addrw_g-1 downto 0);
    s_axi_arvalid  : in  STD_LOGIC;
    s_axi_arready  : out STD_LOGIC;
    s_axi_rdata    : out STD_LOGIC_VECTOR (31 downto 0);
    s_axi_rresp    : out STD_LOGIC_VECTOR (2-1 downto 0);
    s_axi_rvalid   : out STD_LOGIC;
    s_axi_rready   : in  STD_LOGIC
  );
end entity tta_axislave;
