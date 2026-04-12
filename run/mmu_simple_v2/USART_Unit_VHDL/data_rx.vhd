library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_rx is
    port (
        clk       : in  std_logic;
        rest_bar  : in  std_logic;
        baud_tick : in  std_logic;

        rx        : in  std_logic;

        rx_data   : out std_logic_vector(7 downto 0);
        rx_ready  : out std_logic
    );
end entity;

architecture behavior of data_rx is

    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE;

    signal shift : std_logic_vector(7 downto 0);
    signal index : integer range 0 to 7 := 0;
    signal ready : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rest_bar = '0' then
                state <= IDLE;
                ready <= '0';

            elsif baud_tick = '1' then

                case state is

                    when IDLE =>
                        ready <= '0';
                        if rx = '0' then
                            state <= START;
                        end if;

                    when START =>
                        index <= 0;
                        state <= DATA;

                    when DATA =>
                        shift(index) <= rx;

                        if index = 7 then
                            state <= STOP;
                        else
                            index <= index + 1;
                        end if;

                    when STOP =>
                        rx_data <= shift;
                        ready <= '1';
                        state <= IDLE;
                end case;
            else
                ready <= '0';
            end if;
        end if;
    end process;

    rx_ready <= ready;

end architecture;