-------------------------------------------------------------------------------
-- Title      : debugger breakpoint0
-- Project    : tta
-------------------------------------------------------------------------------
-- File       : breakpoint0-entity.vhdl
-- Author     : Tommi Zetterman  <tommi.zetterman@nokia.com>
-- Company    : Nokia Research Center
-- Created    : 2013-03-19
-- Last update: 2013-03-19
-- Platform   :
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Pre-calculate cycle counter accoring to db specification
--              for breakpoint 0
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Nokia Research Center
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-03-19  1.0      zetterma	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity breakpoint0 is
  generic (
    data_width_g : integer := 32
  );
  port (
    clk      : in std_logic;
    nreset   : in std_logic;
    update   : in std_logic;
    bp_in    : in std_logic_vector(data_width_g-1 downto 0);
    bp_type  : in std_logic_vector(1 downto 0);
    cyclecnt : in std_logic_vector(data_width_g-1 downto 0);
    bp_out   : out std_logic_vector(data_width_g-1 downto 0)
  );

end breakpoint0;
