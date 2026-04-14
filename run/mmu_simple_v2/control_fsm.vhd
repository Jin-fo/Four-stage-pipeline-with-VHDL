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
        
        rst_busy   : in std_logic;

        -- control outputs
        uart_en    : out std_logic;
        cpu_en     : out std_logic
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
    process(state, rst_bar, enable, load_done, rst_busy)
    begin

        next_state <= state;

        case state is

            ------------------------------------------------------------
            when RESET =>
                if rst_busy = '1' then
                    next_state <= RESET;
                elsif rst_bar = '1' then
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
        uart_en   <= '0';
        cpu_en    <= '0';

        case state is

            ------------------------------------------------------------
            when RESET =>
                uart_en   <= '0';
                cpu_en    <= '0';

            ------------------------------------------------------------
            when LOAD =>
                uart_en   <= '1';   -- UART active
                cpu_en    <= '0';

            ------------------------------------------------------------
            when EXECUTE =>
                uart_en   <= '0';   -- disable UART loading
                cpu_en    <= '1';   -- CPU runs

        end case;
    end process;

end architecture;