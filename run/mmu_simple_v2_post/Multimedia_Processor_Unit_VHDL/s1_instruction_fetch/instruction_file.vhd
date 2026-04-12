library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity instruction_file is
    port(
        pc_count : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        BRAM     : in  mem_array;
        instruc  : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0)
    );
end entity;

architecture behavior of instruction_file is
begin
    instruc <= BRAM(to_integer(unsigned(pc_count)));
end architecture;