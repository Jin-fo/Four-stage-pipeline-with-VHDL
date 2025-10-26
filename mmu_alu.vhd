library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.load_immediate.all;
use work.saturate_math.all;
use work.rest_instruction.all;


entity MMU_ALU is 
	port (
	opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	in_PORT3	: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	in_PORT2	: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	in_PORT1	: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	
	in_immed	: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
	in_d_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	
	out_PORTD	: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	out_d_ptr 	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	wback_flag	: out std_logic
	);
end entity;

architecture behavior of MMU_ALU is

	procedure rest_ctr (
		signal out_PORTD	: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal out_d_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		signal wback_flag	: out std_logic
	) is
	begin
		out_PORTD  <= (others => '0');
		out_d_ptr  <= (others => '0');
		wback_flag <= '0';
	end procedure;
	
begin 
	main : process( 
		opcode, 
		in_PORT3, in_PORT2, in_PORT1, in_immed,
		in_d_ptr
		)
	begin
		out_d_ptr <= in_d_ptr;
		case opcode(OPCODE_LENGTH-1 downto OPCODE_LENGTH-2) is 
			when "00" | "01" =>
				LDI_memory(
					opcode, 
					in_PORT3, 
					in_immed,     
					
					out_PORTD, 
					wback_flag
				);
			
			when "10" =>
				STM_main(
					opcode, 
					in_PORT3, 
					in_PORT2, 
					in_PORT1,  	
					
					out_PORTD, 
					wback_flag
				);
			
			when "11" => 
				RSI_main(
					opcode, 
					in_PORT2, 
					in_PORT1,
					in_immed,	
					
					out_PORTD, 
					wback_flag
				);
			
			when others => 
				rest_ctr (
					out_PORTD, 
					out_d_ptr,
					wback_flag
				);
			
		end case;
	end process;
end architecture;
				
	
	