library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.signed_asm.all;

package saturate_math is
	procedure STM_main(
		signal opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		signal in_PORT3		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal in_PORT2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal in_PORT1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);

		signal out_PORTD	: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal wback_flag	: out std_logic
	);
end package saturate_math;
	
package body saturate_math is 
	procedure STM_main (
		signal opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		signal in_PORT3		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal in_PORT2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal in_PORT1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		
		signal out_PORTD	: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal wback_flag	: out std_logic
	) is
		variable ret32		: std_logic_vector(31 downto 0);
		variable ret64		: std_logic_vector(63 downto 0);
		variable temp_out	: std_logic_vector(REGISTER_LENGTH-1 downto 0);	
		variable wback_var	: std_logic := '1';
	begin
		case opcode(2 downto 0) is

			when "000" =>
				for i in 3 downto 0 loop --low 16-bit integer mult-add
					mult_16(
						in_PORT3(16*(i*2+1)-1 downto 16*(i*2)),
						in_PORT2(16*(i*2+1)-1 downto 16*(i*2)),
						ret32
					);
					add_32(
						in_PORT1(16*(i*2+2)-1 downto 16*(i*2)), 
						ret32, 
						temp_out(16*(i*2+2)-1 downto 16*(i*2))
					);
					--temp_out(16*(i*2+2)-1 downto 16*(i*2)) := ret32;
				end loop;

			when "001" => 
				for i in 3 downto 0 loop --high 16-bit integer mult-add
					mult_16(
						in_PORT3(16*(i*2+2)-1 downto 16*(i*2+1)),
						in_PORT2(16*(i*2+2)-1 downto 16*(i*2+1)),
						ret32
					);
					add_32(
						in_PORT1(16*(i*2+2)-1 downto 16*(i*2)), 
						ret32, 
						temp_out(16*(i*2+2)-1 downto 16*(i*2))
					);
				end loop;

			when "010" =>
				for i in 3 downto 0 loop --low 16-bit integer mult-sub
					mult_16(
						in_PORT3(16*(i*2+1)-1 downto 16*(i*2)),
						in_PORT2(16*(i*2+1)-1 downto 16*(i*2)),
						ret32
					);
					sub_32(
						in_PORT1(16*(i*2+2)-1 downto 16*(i*2)),
						ret32,
						temp_out(16*(i*2+2)-1 downto 16*(i*2))
					);
				end loop;

			when "011" =>
				for i in 3 downto 0 loop --high 16-bit integer mult-sub
					mult_16(
						in_PORT3(16*(i*2+2)-1 downto 16*(i*2+1)),
						in_PORT2(16*(i*2+2)-1 downto 16*(i*2+1)),
						ret32
					);
					sub_32(
						in_PORT1(16*(i*2+2)-1 downto 16*(i*2)),
						ret32,
						temp_out(16*(i*2+2)-1 downto 16*(i*2))
					);
				end loop;

			when "100" =>
				for i in 1 downto 0 loop --low 32-bit integer mult-add
					mult_32(
						in_PORT3(32*(i*2+1)-1 downto 32*(i*2)),
						in_PORT2(32*(i*2+1)-1 downto 32*(i*2)),
						ret64
					);	 
					add_64(												   
						in_PORT1(32*(i*2+2)-1 downto 32*(i*2)),
						ret64,
						temp_out(32*(i*2+2)-1 downto 32*(i*2))
					);
				end loop;

			when "101" =>
				for i in 1 downto 0 loop --high 32-bit integer mult-add
					mult_32(
						in_PORT3(32*(i*2+2)-1 downto 32*(i*2+1)),
						in_PORT2(32*(i*2+2)-1 downto 32*(i*2+1)),
						ret64
					);
					add_64(
						in_PORT1(32*(i*2+2)-1 downto 32*(i*2)),
						ret64,
						temp_out(32*(i*2+2)-1 downto 32*(i*2))
					);
				end loop;

			when "110" =>
				for i in 1 downto 0 loop --low 32-bit integer mult-sub
					mult_32(
						in_PORT3(32*(i*2+1)-1 downto 32*(i*2)),
						in_PORT2(32*(i*2+1)-1 downto 32*(i*2)),
						ret64
					);
					sub_64(
						in_PORT1(32*(i*2+2)-1 downto 32*(i*2)),
						ret64,
						temp_out(32*(i*2+2)-1 downto 32*(i*2))
					);
				end loop;

			when "111" =>
				for i in 1 downto 0 loop --high 32-bit integer mult-sub
					mult_32(
						in_PORT3(32*(i*2+2)-1 downto 32*(i*2+1)),
						in_PORT2(32*(i*2+2)-1 downto 32*(i*2+1)),
						ret64
					);
					sub_64(
						in_PORT1(32*(i*2+2)-1 downto 32*(i*2)),
						ret64,
						temp_out(32*(i*2+2)-1 downto 32*(i*2))
					);
				end loop;

			when others =>	
				wback_var := '0';		
		end case;
			wback_flag <= wback_var;
			out_PORTD <= temp_out;
	end procedure;
end package body saturate_math;
