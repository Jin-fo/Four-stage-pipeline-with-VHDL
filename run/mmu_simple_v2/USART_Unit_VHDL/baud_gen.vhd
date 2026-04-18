library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity baud_gen is
    port (
        clk        : in  std_logic;
        enable     : in std_logic;
        reset_bar  : in  std_logic;
        baud_tick  : out std_logic
    );
end entity;

architecture behavior of baud_gen is
    constant BAUD_DIV : integer := CLK_FREQ /(SAMPLE_COUNT * BAUD_RATE);
    signal cnt : integer range 0 to BAUD_DIV := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_bar = '0' then
                cnt <= 0;
                baud_tick <= '0';
            elsif enable = '1' then
                if cnt = BAUD_DIV then
                    cnt <= 0;
                    baud_tick <= '1';
                else
                    cnt <= cnt + 1;
                    baud_tick <= '0';
                end if;
            end if;
        end if;
    end process;
end architecture;