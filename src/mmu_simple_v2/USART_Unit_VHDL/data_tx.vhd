library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
entity data_tx is
    port (
        clk        : in  std_logic;
        rst_bar  : in  std_logic;

        -- UART input
        tx_data    : in  std_logic_vector(7 downto 0);
        tx_ready   : in  std_logic;

        -- UART output
        tx         : out std_logic;
        tx_start   : out std_logic;

        -- optional debug
        load_done  : out std_logic
    );
end entity;

architecture behavior of data_tx is

    signal shift_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_count  : integer range 0 to 7 := 0;

    signal tx_reg     : std_logic := '1'; -- idle state is high
    signal start_reg  : std_logic := '0';
    signal done_reg   : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then

            ----------------------------------------------------------------
            -- RESET
            ----------------------------------------------------------------
            if rst_bar = '0' then
                shift_reg  <= (others => '0');
                bit_count  <= 0;
                tx_reg     <= '1'; -- idle state is high
                start_reg  <= '0';
                done_reg   <= '0';

            else

                ----------------------------------------------------------------
                -- DEFAULT PULSE BEHAVIOR
                ----------------------------------------------------------------
                start_reg <= '0';
                done_reg  <= '0';   
            