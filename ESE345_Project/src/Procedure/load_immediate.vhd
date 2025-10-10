library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.parsing_format.all;

package load_immediate is
  -- Just the interfaces here 
	
	procedure LD_to_mem(
		signal opcode		: in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		signal in_porta 	: in std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal write_flag	: out std_logic;				  
		signal out_port     : out std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0)
	);
end package load_immediate;


package body load_immediate is
	
	-- One write signal  
	procedure LD_to_mem (
	    signal opcode     : in  std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
	    signal in_porta   : in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
	    signal write_flag : out std_logic;
	    signal out_port   : out std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0)
	) is
	    variable high_bit : integer; 
	    variable low_bit  : integer;
	    variable temp_out  : std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
	begin
	    -- start with the input
	    temp_out := in_porta;
	
	    if unsigned(opcode(LI_VALUE_H-1 downto LI_VALUE_L)) = 0 then
	        write_flag <= '0'; 
	    else
	        write_flag <= '1';  
	
	        low_bit   := to_integer(unsigned(opcode(LI_INDEX_H-1 downto LI_INDEX_L))) * MAX_VALUE_LENGTH;
	        high_bit  := low_bit + MAX_VALUE_LENGTH;
	
	        -- overwrite just the slice in the variable
	        temp_out(high_bit-1 downto low_bit) := opcode(LI_VALUE_H-1 downto LI_VALUE_L);
	    end if;
	
	    -- finally assign the variable to the output signal
	    out_port <= temp_out;
	end procedure;

end package body load_immediate;
