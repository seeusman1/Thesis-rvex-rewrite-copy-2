library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library rvex;
use rvex.common_pkg.all;
use rvex.utils_pkg.all;
use rvex.simUtils_pkg.all;
use rvex.bus_pkg.all;

entity uart_tb is
end uart_tb;

architecture behavioral of uart_tb is
  signal reset                  : std_logic;
  signal clk                    : std_logic;
  signal rx                     : std_logic;
  signal tx                     : std_logic;
  signal bus2uart               : bus_mst2slv_type;
  signal uart2bus               : bus_slv2mst_type;
  signal irq                    : std_logic;
  signal uart2dbg_bus           : bus_mst2slv_type;
  signal dbg2uart_bus           : bus_slv2mst_type;
  signal raw_rx_data            : std_logic_vector(7 downto 0);
  signal raw_rx_frameError      : std_logic;
  signal raw_rx_strobe          : std_logic;
  signal raw_tx_data            : std_logic_vector(7 downto 0);
  signal raw_tx_strobe          : std_logic;
  signal raw_tx_busy            : std_logic;
begin
  
  -- Instantiate unit under test.
  uut: entity rvex.periph_UART
    generic map (
      F_CLK                     => 10000000.0,
      F_BAUD                    => 115200.0
    )
    port map (
      
      -- System control.
      reset                     => reset,
      clk                       => clk,
      clkEn                     => '1',
      
      -- UART pins.
      rx                        => rx,
      tx                        => tx,
      
      -- Slave bus.
      bus2uart                  => bus2uart,
      uart2bus                  => uart2bus,
      irq                       => irq,
      
      -- Debug interface.
      uart2dbg_bus              => uart2dbg_bus,
      dbg2uart_bus              => dbg2uart_bus
      
    );
  
  -- Instantiate a memory for the unit under test to access.
  memory_inst: entity rvex.bus_ramBlock
    generic map (
      DEPTH_LOG2B               => 10
    )
    port map (
      
      -- System control.
      reset                     => reset,
      clk                       => clk,
      clkEn                     => '1',
      
      -- Memory ports.
      mst2mem_portA             => uart2dbg_bus,
      mem2mst_portA             => dbg2uart_bus,
      mst2mem_portB             => BUS_MST2SLV_IDLE,
      mem2mst_portB             => open
      
    );

  -- Generate raw UART to communicate with the unit under test.
  uart_inst: entity rvex.utils_uart
    generic map (
      F_CLK                     => 10000000.0,
      F_BAUD                    => 115200.0,
      ENABLE_TX                 => true,
      ENABLE_RX                 => true
    )
    port map (
      reset                     => reset,
      clk                       => clk,
      clkEn                     => '1',
      
      rx                        => tx,
      rx_data                   => raw_rx_data,
      rx_frameError             => raw_rx_frameError,
      rx_strobe                 => raw_rx_strobe,
      
      tx                        => rx,
      tx_data                   => raw_tx_data,
      tx_strobe                 => raw_tx_strobe,
      tx_busy                   => raw_tx_busy
    );
  
  -- Generate clock.
  process is
  begin
    clk <= '1';
    wait for 50 ns;
    clk <= '0';
    wait for 50 ns;
  end process;
  
  -- Report bytes sent by the unit-under-test.
  process is
  begin
    loop
      wait until rising_edge(clk) and raw_rx_strobe = '1';
      wait for 1 ns;
      dumpStdOut("Receive " & rvs_hex(raw_rx_data));
    end loop;
  end process;
  
  -- Generate stimuli.
  process is
    procedure transmit(data: std_logic_vector) is
    begin
      dumpStdOut("Transmit " & rvs_hex(data));
      wait until rising_edge(clk) and raw_tx_busy = '0';
      raw_tx_strobe <= '1';
      raw_tx_data <= data;
      wait until rising_edge(clk);
      raw_tx_strobe <= '0';
      raw_tx_data <= (others => 'U');
    end transmit;
  begin
    reset <= '1';
    raw_tx_strobe <= '0';
    raw_tx_data <= (others => 'U');
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    reset <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    
    -- CRC computation: http://www.zorc.breitbandkatze.de/crc.html
    -- order = 8
    -- poly = 07
    -- initial = 00, direct
    -- final xor = 00
    -- no reverse options
    
    -- Transmit some random user stuff.
    transmit(X"03");
    transmit(X"55");
    transmit(X"AA");
    transmit(X"FF");
    
    -- Transmit a write command.
    transmit(X"FD");
    transmit(X"2F");
    transmit(X"DE");
    transmit(X"AD");
    transmit(X"BE");
    transmit(X"EF");
    transmit(X"DE");
    transmit(X"AD");
    transmit(X"C0");
    transmit(X"DE");
    transmit(X"01");
    transmit(X"02");
    transmit(X"03");
    transmit(X"04");
    transmit(X"F1");
    --transmit(X"FE");
    
    -- Transmit a set address command.
    transmit(X"FD");
    transmit(X"5B");
    transmit(X"00");
    transmit(X"00");
    transmit(X"00");
    transmit(X"00");
    transmit(X"45");
    
    -- Transmit a read command.
    transmit(X"FD");
    transmit(X"3C");
    transmit(X"03");
    transmit(X"0C");
    transmit(X"FE");
    
    wait;
  end process;
  
end behavioral;
