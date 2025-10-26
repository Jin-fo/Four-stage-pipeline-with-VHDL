library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all; 
use work.unsigned_asm.all;
use work.signed_asm.all;

package rest_instruction is
	procedure RSI_main(
		signal opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		signal in_PORT2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal in_PORT1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal in_immed		: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

		signal out_PORTD	: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal wback_flag	: out std_logic
	);
end package; 

package body rest_instruction is
	procedure RSI_main(
	    signal opcode		: in  std_logic_vector(OPCODE_LENGTH-1 downto 0);
	    signal in_PORT2		: in  std_logic_vector(REGISTER_LENGTH-1 downto 0);
	    signal in_PORT1		: in  std_logic_vector(REGISTER_LENGTH-1 downto 0);
		signal in_immed		: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

	    signal out_PORTD	: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	    signal wback_flag	: out std_logic
	) is
	    variable temp_out   : std_logic_vector(REGISTER_LENGTH-1 downto 0);
	    variable int_var    : integer := 0;
	    variable unsign16   : unsigned(15 downto 0);
	    variable vector16   : std_logic_vector(15 downto 0);
	    variable vector32   : std_logic_vector(31 downto 0);
	    variable wback_var  : std_logic := '1';
	begin
	    case opcode(3 downto 0) is
	        when "0000" => --no operation
				wback_var := '0'; 
			
	
	        when "0001" => --shift right halfword immediate
	            int_var := to_integer(unsigned(in_immed(3 downto 0)));
	            for i in 0 to 7 loop
	                unsign16 := unsigned(in_PORT1(16*(i+1)-1 downto i*16));
	                unsign16 := shift_right(unsign16, int_var);
	                temp_out(16*(i+1)-1 downto i*16) := std_logic_vector(unsign16);
	            end loop;
	
	        when "0010" => --add word unsigned
	            for i in 0 to 3 loop
	                add_32_unsigned(
	                    in_PORT2(32*(i+1)-1 downto i*32),
	                    in_PORT1(32*(i+1)-1 downto i*32),
	                    temp_out(32*(i+1)-1 downto i*32)
	                );
	            end loop;
	
	        when "0011" => --count 1s in halfword
	            for i in 0 to 7 loop
	                vector16 := in_PORT1(16*(i+1)-1 downto i*16);
	                int_var := 0;
	                for j in 0 to 15 loop
	                    if vector16(j) = '1' then
	                        int_var := int_var + 1;
	                    end if;
	                end loop;
	                temp_out(16*(i+1)-1 downto i*16) := std_logic_vector(to_unsigned(int_var, 16));
	            end loop;
	
	        when "0100" => --add halfword saturated
	            for i in 0 to 7 loop
	                add_16(
	                    in_PORT2(16*(i+1)-1 downto i*16),
	                    in_PORT1(16*(i+1)-1 downto i*16),
	                    temp_out(16*(i+1)-1 downto i*16)
	                );
	            end loop;
	
	        when "0101" => --bitwise logical or
	            temp_out := in_PORT2 or in_PORT1;
	
	        when "0110" => --broadcast word
	            vector32 := in_PORT1(REGISTER_LENGTH-1 downto REGISTER_LENGTH-32);
	            for i in 0 to 3 loop
	                temp_out(32*(i+1)-1 downto i*32) := vector32;
	            end loop;
	
	        when "0111" => -- max signed word
	            for i in 0 to 3 loop
	                if signed(in_PORT2(32*(i+1)-1 downto i*32)) > signed(in_PORT1(32*(i+1)-1 downto i*32)) then
	                   temp_out(32*(i+1)-1 downto i*32) := in_PORT2(32*(i+1)-1 downto i*32);
	                else
	                   temp_out(32*(i+1)-1 downto i*32) := in_PORT1(32*(i+1)-1 downto i*32);
	                end if;
	            end loop;
	
	        when "1000" => --min signed word
	            for i in 0 to 3 loop
	                if signed(in_PORT2(32*(i+1)-1 downto i*32)) < signed(in_PORT1(32*(i+1)-1 downto i*32)) then
	                   temp_out(32*(i+1)-1 downto i*32) := in_PORT2(32*(i+1)-1 downto i*32);
	                else
	                   temp_out(32*(i+1)-1 downto i*32) := in_PORT1(32*(i+1)-1 downto i*32);
	                end if;
	            end loop;
	
	        when "1001" => --multiply low unsigned
	            for i in 0 to 3 loop
	                mult_16_unsigned(
						in_PORT1(16*(i*2+1)-1 downto 16*(i*2)),
	                    in_PORT2(16*(i*2+1)-1 downto 16*(i*2)),
	                    temp_out(32*(i+1)-1 downto 32*i)
	                );
	            end loop;
				
			when "1010" => --multiply low by constant unsigned
			   	for i in 0 to 3 loop   
					mult_16_unsigned(
						in_PORT1(16*(i*2+1)-1 downto 16*(i*2)),
						"00000000000" & in_immed(4 downto 0),
						temp_out(32*(i+1)-1 downto 32*i)
					);	 
				end loop;
				
	        when "1011" => --bitwise logical and
	            temp_out := in_PORT2 and in_PORT1;
	
	        when "1100" => --count leading zeroes in words
	            for i in 0 to 3 loop
	                vector32 := in_PORT1(32*(i+1)-1 downto i*32);
	                int_var := 0; 
					if unsigned(vector32) = 0 then 
						int_var := 0; 
					else 
		                for bit_index in 31 downto 0 loop
		                    if vector32(bit_index) = '0' then
		                        int_var := int_var + 1;
		                    else
		                        exit;
		                    end if;
		                end loop;
					end if;
	                temp_out(32*(i+1)-1 downto i*32) := std_logic_vector(to_unsigned(int_var, 32));
	            end loop;
	
	        when "1101" => --rotate bits in word
	            for i in 0 to 3 loop
	                vector32 := in_PORT1(32*(i+1)-1 downto i*32);
	                int_var := to_integer(unsigned(in_immed(4 downto 0))) mod 32;
	                if int_var = 0 then
	                    temp_out(32*(i+1)-1 downto 32*i) := vector32;
	                else
	                    temp_out(32*(i+1)-1 downto 32*i) := vector32(int_var-1 downto 0) & vector32(31 downto int_var);
	                end if;
	            end loop;
	
	        when "1110" => --subtract from word unsigned
	            for i in 0 to 3 loop
	                sub_32_unsigned(
	                    in_PORT2(32*(i+1)-1 downto 32*i),
	                    in_PORT1(32*(i+1)-1 downto 32*i),
	                    temp_out(32*(i+1)-1 downto 32*i)
	                );
	            end loop;
	
	        when "1111" => --subtract from halfword saturated
	            for i in 0 to 7 loop
	                sub_16(
	                    in_PORT2(16*(i+1)-1 downto 16*i),
	                    in_PORT1(16*(i+1)-1 downto 16*i),
	                    temp_out(16*(i+1)-1 downto 16*i)
	                );
	            end loop;
	
	        when others =>
				wback_var := '0';
	    end case;
			if wback_var = '1' then 
		    	out_PORTD <= temp_out; 
			end if;
			wback_flag <= wback_var;
				
	end procedure;
end package body rest_instruction;

