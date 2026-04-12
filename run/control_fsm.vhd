library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity control_fsm is
    port (
        clk        : in  std_logic;
        rst_bar    : in  std_logic;
        enable     : in  std_logic;

        load_done  : in  std_logic;

        -- control outputs
        cpu_reset  : out std_logic;
        uart_en    : out std_logic;
        cpu_en     : out std_logic;
        wr_enable  : out std_logic
    );
end entity;

architecture behavior of control_fsm is

    type state_type is (RESET, LOAD, EXECUTE);
    signal state, next_state : state_type;

begin

    --------------------------------------------------------------------
    -- STATE REGISTER
    --------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst_bar = '0' then
                state <= RESET;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- NEXT STATE LOGIC
    --------------------------------------------------------------------
    process(state, rst_bar, enable, load_done)
    begin

        next_state <= state;

        case state is

            ------------------------------------------------------------
            when RESET =>
                if rst_bar = '1' then
                    next_state <= LOAD;
                end if;

            ------------------------------------------------------------
            when LOAD =>
                if enable = '1' and load_done = '1' then
                    next_state <= EXECUTE;
                else
                    next_state <= LOAD;
                end if;

            ------------------------------------------------------------
            when EXECUTE =>
                next_state <= EXECUTE;  -- run forever until reset

        end case;
    end process;

    --------------------------------------------------------------------
    -- OUTPUT LOGIC
    --------------------------------------------------------------------
    process(state)
    begin

        -- defaults
        cpu_reset <= '1';
        uart_en   <= '0';
        cpu_en    <= '0';
        wr_enable <= '0';

        case state is

            ------------------------------------------------------------
            when RESET =>
                cpu_reset <= '1';
                uart_en   <= '0';
                cpu_en    <= '0';
                wr_enable <= '0';

            ------------------------------------------------------------
            when LOAD =>
                cpu_reset <= '1';   -- CPU held in reset
                uart_en   <= '1';   -- UART active
                cpu_en    <= '0';
                wr_enable <= '1';   -- allow BRAM writes

            ------------------------------------------------------------
            when EXECUTE =>
                cpu_reset <= '0';   -- release CPU
                uart_en   <= '0';   -- disable UART loading
                cpu_en    <= '1';   -- CPU runs
                wr_enable <= '0';   -- prevent overwriting program

        end case;
    end process;

end architecture;