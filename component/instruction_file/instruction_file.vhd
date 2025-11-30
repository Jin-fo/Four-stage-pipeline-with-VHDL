library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
use work.numeric_var.all;

entity instruction_file is 
	port(				  
	  pc_count	: in std_logic_vector(COUNTER_LENGTH-1 downto 0);	
	  in_file	: in std_logic_vector(FILE_SIZE-1 downto 0); 
	  reload_bar	: in std_logic;
	  instruc	: out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0) := (others => '-')
	);
end entity;

architecture behavior of instruction_file is	
    signal INSTRUC_FILE : std_logic_vector(FILE_SIZE-1 downto 0) := (others => '0');
begin
	reg_file : process(pc_count, reload_bar, in_file)
		variable temp_instruc	: std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		variable pc_index : integer;
		variable msb      : integer;
		variable lsb      : integer;
	begin
		if reload_bar = '0' then
			INSTRUC_FILE <= in_file;		--little endian, lsb on the left and msb on the right
			temp_instruc := (others => '-');
		else 	  
			pc_index := to_integer(unsigned(pc_count));
			msb := (pc_index * INSTRUCTION_LENGTH + INSTRUCTION_LENGTH) -1;
			lsb := msb - INSTRUCTION_LENGTH + 1;
			temp_instruc := INSTRUC_FILE(msb downto lsb); 

		end if;						 
		instruc <= temp_instruc;
	end process;
end architecture;
