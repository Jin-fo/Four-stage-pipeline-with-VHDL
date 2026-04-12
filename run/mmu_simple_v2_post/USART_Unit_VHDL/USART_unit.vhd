library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity USART_unit is
    port (
        clk        : in  std_logic;
        reset_bar  : in  std_logic;

        -- control
        enable     : in  std_logic;

        -- serial input
        rx         : in  std_logic;

        -- parallel output to accumulator
        rx_data    : out std_logic_vector(7 downto 0);
        rx_ready   : out std_logic
    );
end entity;

architecture structural of USART_unit is

    --------------------------------------------------------------------
    -- internal baud signal
    --------------------------------------------------------------------
    signal baud_tick : std_logic;

begin

    --------------------------------------------------------------------
    -- 1. BAUD GENERATOR
    --------------------------------------------------------------------
    baud_inst : entity work.baud_gen(behavior)
    port map (
        clk        => clk,
        reset_bar  => reset_bar,
        enable_bar     => enable,
        baud_tick  => baud_tick
    );

    --------------------------------------------------------------------
    -- 2. UART RECEIVER (8N1)
    --------------------------------------------------------------------
    rx_inst : entity work.data_rx(behavior)
    port map (
        clk        => clk,
        reset_bar  => reset_bar,
        baud_tick  => baud_tick,

        rx         => rx,
        rx_data    => rx_data,
        rx_ready   => rx_ready
    );

end architecture;