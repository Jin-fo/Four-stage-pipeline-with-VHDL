library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity pc_reg is
    port(
        clk        : in  std_logic;
        enable     : in  std_logic;
        reset_bar  : in  std_logic;

        next_pc    : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);

        pc_out     : out std_logic_vector(COUNTER_LENGTH-1 downto 0)
    );
end entity;

architecture behavior of pc_reg is
    signal pc_reg : unsigned(COUNTER_LENGTH-1 downto 0);
begin

process(clk, reset_bar)
begin
    if reset_bar = '0' then
        pc_reg <= (others => '0');

    elsif rising_edge(clk) then
        if enable = '1' then
            pc_reg <= unsigned(next_pc);
        end if;
    end if;
end process;

pc_out <= std_logic_vector(pc_reg);

end architecture;