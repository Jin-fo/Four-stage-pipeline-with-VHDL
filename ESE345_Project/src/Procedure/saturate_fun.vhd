library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.parsing_format.all;

package saturate_fun is   
	
	procedure SF_main(
		signal opcode			: in  std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		signal in_PORTA		: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal in_PORTB		: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal in_PORTC		: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal out_PORTD		: out std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal write_flag		: out std_logic
	);
	
end package saturate_fun;

package body saturate_fun is 
	
	procedure multiple_16(
		val_a, val_b : in std_logic_vector(15 downto 0); -- 16 bits or half-int      
		ret 	: out std_logic_vector(31 downto 0) -- high 16 bits
	) is
		variable prod : signed(31 downto 0);
	begin
		prod := signed(val_a) * signed(val_b);
		ret := std_logic_vector(prod);
	end procedure;
	
	procedure multiple_32(
		val_a, val_b	: in std_logic_vector(31 downto 0);	-- 32 bits or half-long
		ret :out std_logic_vector(63 downto 0)
	) is 
		variable prod : signed(63 downto 0);
	begin		   
		prod := signed(val_a) * signed(val_b);
		ret := std_logic_vector(prod);
	end procedure;		
	
	procedure add_32(
		val_a, val_b : in std_logic_vector(31 downto 0);
		ret			: out std_logic_vector(31 downto 0)
	) is  
		variable a_33 : signed(32 downto 0);
		variable b_33 : signed(32 downto 0);
		variable sum : signed(32 downto 0);
	begin	 	
		a_33 := resize(signed(val_a), 33);
		b_33 := resize(signed(val_b), 33);
		
		sum := a_33 + b_33;
		
		if sum > MAX32 then
			ret := std_logic_vector(MAX32);	
		elsif sum < MIN32 then
			ret := std_logic_vector(MIN32);
		else 
			ret := std_logic_vector(sum(31 downto 0));
		end if;
	end procedure;
	
	procedure sub_32(
		val_a, val_b : in std_logic_vector(31 downto 0);
		ret			: out std_logic_vector(31 downto 0)
	) is   
		variable a_33 : signed(32 downto 0);
		variable b_33 : signed(32 downto 0);
		variable sum : signed(32 downto 0);
	begin	 	
		a_33 := resize(signed(val_a), 33);
		b_33 := resize(signed(val_b), 33);
		
		sum := a_33 + b_33;
		
		if sum < MIN32 then
			ret := std_logic_vector(MIN32);	
		elsif sum > MAX32 then
			ret := std_logic_vector(MAX32);
		else 
			ret := std_logic_vector(sum(31 downto 0));
		end if;
	end procedure;
	
	procedure add_64( 
		val_a, val_b : in std_logic_vector(63 downto 0);
		ret			: out std_logic_vector(63 downto 0)
	) is   		  
		variable a_65 : signed(64 downto 0);
		variable b_65 : signed(64 downto 0);
		variable sum : signed(64 downto 0);
	begin	 	
		a_65 := resize(signed(val_a), 65);
		b_65 := resize(signed(val_b), 65);
		
		sum := a_65 + b_65;
		
		if sum > MAX64 then
			ret := std_logic_vector(MAX64);
		elsif sum < MIN64 then
			ret := std_logic_vector(MIN64);
		else 
			ret := std_logic_vector(sum(63 downto 0));
		end if;
	end procedure;
	
	procedure sub_64( 
		val_a, val_b : in std_logic_vector(63 downto 0);
		ret			: out std_logic_vector(63 downto 0)
	) is
		variable a_65 : signed(64 downto 0);
		variable b_65 : signed(64 downto 0);
		variable sum : signed(64 downto 0);
	begin	 	
		a_65 := resize(signed(val_a), 65);
		b_65 := resize(signed(val_b), 65);
		
		sum := a_65 - b_65;
		
		if sum < MIN64 then
			ret := std_logic_vector(MIN64);
		elsif sum > MAX64 then
			ret := std_logic_vector(MAX64);
		else 
			ret := std_logic_vector(sum(63 downto 0));
		end if;
	end procedure;

	procedure SF_main(
		signal opcode			: in  std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		signal in_PORTA		: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal in_PORTB		: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal in_PORTC		: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal out_PORTD		: out std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		signal write_flag 	: out std_logic
	) is		
		variable A_16, B_16	: std_logic_vector(15 downto 0); 
		variable A_32, B_32	: std_logic_vector(31 downto 0); 
		variable A_64, B_64	: std_logic_vector(63 downto 0);
		variable ret_32		: std_logic_vector(31 downto 0);
		variable ret_64		: std_logic_vector(63 downto 0); 
		variable temp_out		: std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
	begin 
		
		case opcode(MA_LISAHL_H-1 downto MA_LISAHL_L) is 
			when "000" => 
				for i in 3 downto 0 loop   --low 16-bit ma
					A_16 := in_PORTA(16*(i*2+1)-1 downto 16*(i*2));
					B_16 := in_PORTB(16*(i*2+1)-1 downto 16*(i*2));
					multiple_16(A_16, B_16, ret_32); --A_16 * B_16 = ret_32
					
					A_32 :=	in_PORTC(16*(i*2+2)-1 downto 16*(i*2));
					B_32 := ret_32;
					add_32(A_32, B_32, ret_32);	 
					
					temp_out(16*(i*2+2)-1 downto 16*(i*2)) := ret_32;
					write_flag <= '1';
				 end loop;
			when "001" => 
				for i in 3 downto 0 loop   --high 16-bit ma
					A_16 := in_PORTA(16*(i*2+2)-1 downto 16*(i*2+1));
					B_16 := in_PORTB(16*(i*2+2)-1 downto 16*(i*2+1));
					multiple_16(A_16, B_16, ret_32);
					
					A_32 :=	in_PORTC(16*(i*2+2)-1 downto 16*(i*2));
					B_32 := ret_32;
					add_32(A_32, B_32, ret_32);	
					
					temp_out(16*(i*2+2)-1 downto 16*(i*2)) := ret_32;
					write_flag <= '1';
				 end loop;
			
			when "010" =>
				for i in 3 downto 0 loop   --low 16-bit ms
					A_16 := in_PORTA(16*(i*2+1)-1 downto 16*(i*2));
					B_16 := in_PORTB(16*(i*2+1)-1 downto 16*(i*2));
					multiple_16(A_16, B_16, ret_32); --A_16 * B_16 = ret_32
					
					A_32 :=	in_PORTC(16*(i*2+2)-1 downto 16*(i*2));
					B_32 := ret_32;
					sub_32(ret_32, B_32, ret_32);
					
					temp_out(16*(i*2+2)-1 downto 16*(i*2)) := ret_32;
					write_flag <= '1';
				end loop;
			when "011" => 
				for i in 3 downto 0 loop   --high 16-bit ms 
					A_16 := in_PORTA(16*(i*4+2)-1 downto 16*(i*2+1));
					B_16 := in_PORTB(16*(i*4+2)-1 downto 16*(i*2+1));
					multiple_16(A_16, B_16, ret_32);
					
					A_32 :=	in_PORTC(16*(i*2+2)-1 downto 16*(i*2));
					B_32 := ret_32;
					sub_32(ret_32, B_32, ret_32); 
					
					temp_out(16*(i*2+2)-1 downto 16*(i*2)) := ret_32;
					write_flag <= '1';
				end loop;	
			when "100" =>
				for i in 1 downto 0 loop   --low 32-bit ma 
					A_32 := in_PORTA(16*(i*4+2)-1 downto 16*(i*4));
					B_32 := in_PORTA(16*(i*4+2)-1 downto 16*(i*4));
					multiple_32(A_32, B_32, ret_64);
					
					B_64 := ret_64;
					A_64 :=	in_PORTC(16*(i*4+4)-1 downto 16*(i*4));
					add_64(A_64, B_64, ret_64);	   
					
					temp_out(16*(i*4+4)-1 downto 16*(i*4)) := ret_64;
					write_flag <= '1';
				end loop;	
			when "101" =>
				for i in 1 downto 0 loop   --high 32-bit ma 
					A_32 := in_PORTA(16*(i*4+2)-1 downto 16*(i*4));
					B_32 := in_PORTA(16*(i*4+2)-1 downto 16*(i*4));
					multiple_32(A_32, B_32, ret_64);
					
					B_64 := ret_64;
					A_64 :=	in_PORTC(16*(i*4+4)-1 downto 16*(i*4));
					add_64(A_64, B_64, ret_64);	  
					
					temp_out(16*(i*4+4)-1 downto 16*(i*4)) := ret_64;
					write_flag <= '1';
				end loop;	
			when "110" =>  
				for i in 1 downto 0 loop   --low 32-bit ms 
					A_32 := in_PORTA(16*(i*4+2)-1 downto 16*(i*4));
					B_32 := in_PORTA(16*(i*4+2)-1 downto 16*(i*4));
					multiple_32(A_32, B_32, ret_64);
					
					B_64 :=	ret_64;
					A_64 :=	in_PORTC(16*(i*4+4)-1 downto 16*(i*4));
					sub_64(A_64, B_64, ret_64);		
					
					temp_out(16*(i*4+4)-1 downto 16*(i*4)) := ret_64;
					write_flag <= '1';
				end loop;	
			when "111" =>
				for i in 1 downto 0 loop   --high 32-bit ms 
					A_32 := in_PORTA(16*(i*4+2)-1 downto 16*(i*4));
					B_32 := in_PORTA(16*(i*4+2)-1 downto 16*(i*4));
					multiple_32(A_32, B_32, ret_64);
					
					B_64 := ret_64;
					A_64 :=	in_PORTC(16*(i*4+4)-1 downto 16*(i*4));
					sub_64(A_64, B_64, ret_64);	 	 
					
					temp_out(16*(i*4+4)-1 downto 16*(i*4)) := ret_64;
					write_flag <= '1';
			end loop;
			when others =>
				write_flag <= '0';
				temp_out := (others => '-');
		end case;
		
		out_PORTD <= temp_out;
		
	end procedure;
end package body saturate_fun;