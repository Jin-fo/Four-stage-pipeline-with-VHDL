library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.parsing_format.all;

package opcode_rest is
  -- declare only the header (no 'is ... begin ... end')
	procedure OP_main(
		signal opcode	: in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		signal in_PORTA : in std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal in_PORTB : in std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal out_PORTD : out std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal write_flag : out std_logic
	);
end package;

package body opcode_rest is
  -- now provide the body	  
  
  	procedure add_32_unsigned(
	  	val_a, val_b : in std_logic_vector(31 downto 0);
		ret			: out std_logic_vector(31 downto 0)
	) is  
		variable a_33, b_33 : unsigned(32 downto 0);
		variable sum : unsigned(32 downto 0); 
	begin	 	
		a_33 := resize(unsigned(val_a), 33);
		b_33 := resize(unsigned(val_b), 33);
		
		sum := a_33 + b_33;
		
		if sum > MAX32_unsigned then
			ret := std_logic_vector(MAX32_unsigned);
		else 
			ret := std_logic_vector(sum(31 downto 0));
		end if;
	end procedure;
	
	procedure add_16(
		val_a, val_b	: in std_logic_vector(15 downto 0);
		ret				: out std_logic_vector(15 downto 0)
	) is
	variable a_17 : signed(16 downto 0);
	variable b_17 : signed(16 downto 0);
	variable sum : signed(16 downto 0);
	begin 
		a_17 := resize(signed(val_a), 17);
		b_17 := resize(signed(val_b), 17);
		
		sum := a_17 + b_17;
		
		if sum > MAX16 then
			ret := std_logic_vector(MAX16);	 
		elsif sum < MIN16 then 
			ret := std_logic_vector(MIN16);
		else 
			ret := std_logic_vector(sum(15 downto 0));
		end if;
	end procedure;
	

	procedure OP_main(
		signal opcode	: in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		signal in_PORTA : in std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal in_PORTB : in std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal out_PORTD : out std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal write_flag : out std_logic
	) is   
	variable temp_out : std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0) := (others => '0');
	variable num_int : integer;	
    variable hw_unsigned  : unsigned(15 downto 0); 
	variable hw_vector	  : std_logic_vector(15 downto 0);
	variable wd_vector	  : std_logic_vector(31 downto 0);
	
	begin
		case opcode(OR_CODE_H-1 downto OR_CODE_L) is
			when "----0000" => --NOP	 
				write_flag <= '0';
				temp_out := (others => '-'); 
				
			when "----0001" => --SHRHI	 
			    -- immediate is in the low 4 bits of rs2
			    num_int := to_integer(unsigned(in_PORTA(3 downto 0)));
		
			    for i in 0 to 7 loop
			        hw_unsigned := unsigned(in_PORTB(16*(i+1)-1 downto i*16));
			        hw_unsigned := shift_right(hw_unsigned, num_int);  				-- logical shift right
			        temp_out(i*16+15 downto i*16) := std_logic_vector(hw_unsigned);
			    end loop;  
				write_flag <= '1';
				
			when "----0010" => --AU
				for i in 0 to 3 loop 
					add_32_unsigned(
						in_PORTA(32*(i+1)-1 downto i*32), 
						in_PORTB(32*(i+1)-1 downto i*32), 
						temp_out(32*(i+1)-1 downto i*32)
						); 
				end loop;
				write_flag <= '1';
			when "----0011" => --CNTH  
				for i in 0 to 7 loop 
					hw_vector := in_PORTB(16*(i+1)-1 downto i*16);
					for j in 0 to 15 loop
						if hw_vector(j) = '1' then
							num_int := num_int + 1;
						end if;
					end loop;
					temp_out(16*(i+1)-1 downto i*16) := std_logic_vector(to_unsigned(num_int, 16));
				end loop;
				write_flag <= '1';
			when "----0100" => --AHS
				for i in 0 to 7 loop
					add_16(
					in_PORTA(16*(i+1)-1 downto i*16), 
					in_PORTB(16*(i+1)-1 downto i*16), 
					temp_out(16*(i+1)-1 downto i*16) 
					);	
				end loop;
				write_flag <= '1';
			when "----0101" => -- or
				temp_out := in_PORTA or in_PORTB;
				write_flag <= '1';
			when "----0110" =>  --BCW
				wd_vector := in_PORTB(MEMORY_REGISTER_LENGTH-1 downto MEMORY_REGISTER_LENGTH-32);
				for i in 0 to 7 loop
					temp_out(32*(i+1)-1 downto i*32) := wd_vector;
				end loop;
				write_flag <= '1';
				
			when "----0111" => --MAXWS 
				for i in 0 to 3 loop
					if signed(in_PORTA(32*(i+1)-1 downto i*32)) > signed(in_PORTB(32*(i+1)-1 downto i*32)) then
						wd_vector := in_PORTA(32*(i+1)-1 downto i*32);
					else 
						wd_vector := in_PORTB(32*(i+1)-1 downto i*32);
					end if;
					
					if signed(wd_vector) > signed(temp_out(32*(i+1)-1 downto i*32)) then
						temp_out := wd_vector;
					end if;
				end loop;
				write_flag <= '1';
			when "----1000" => 
			when "----1001" => 
			when "----1010" => 
			when "----1011" => 
			when "----1100" => 
			when "----1101" => 
			when "----1110" => 
			when "----1111" => 
			when others =>
				temp_out := (others => '-');
		end case;
	   	out_PORTD <= temp_out; 
	end procedure;
end package body;