library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.parsing_format.all;  -- import constants 
use work.load_immediate.all;
use work.saturate_fun.all;

entity Multimedia_ALU is 
    port (																													                    
		clk       	: in  std_logic;         
		enable    	: in  std_logic; 
		rst_bar   	: in  std_logic;  
		
		opcode    	: in  std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		
		-- segment of 16-bits registers from memory			  
		in_PORTA  	: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		in_PORTB  	: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		in_PORTC  	: in  std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		PORT_EN		: out std_logic_vector(2 downto 0);
		
		mem_address	: out std_logic_vector(MEMORY_ADDRESS_LENGTH-1 downto 0);
		out_PORTD	: out std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
		
		write_flag	: out std_logic; 
		fward_flag 	: out std_logic
    );
end entity;        

architecture behavior of Multimedia_ALU is 
	--move memory address pointer, load contain to repsective enabled ported
  	procedure direct_mem(
	  	signal mem_address : out std_logic_vector(MEMORY_ADDRESS_LENGTH-1 downto 0);
	    addr               : in  std_logic_vector(MEMORY_ADDRESS_LENGTH-1 downto 0);
		signal PORT_EN     : out std_logic_vector(2 downto 0);
	    en                 : in  std_logic_vector(2 downto 0)
	) is
	begin
		mem_address <= addr;
		PORT_EN     <= en;
	end procedure; 
	
  begin	 
    main : process(clk, rst_bar) 
																												      
    begin	   
        if rst_bar = '0' then  
		    PORT_EN 		<= "000";
            mem_address		<= (others => '-');
            out_PORTD		<= (others => '-');
            write_flag		<= '0';
            fward_flag		<= '0';

        elsif rising_edge(clk) then
            if enable = '1' then
                fward_flag <= '1';

                case opcode(INSTRUCTION_LENGTH-1 downto INSTRUCTION_LENGTH-2) is
                    when "00" | "01" => 	
					direct_mem(
						mem_address, opcode(LI_REGD_H-1 downto LI_REGD_L), 
						PORT_EN, "100"  
						);
					
	                    LD_to_mem(opcode, in_PORTA, write_flag, out_PORTD);

                    when "10" => 
					direct_mem(
						mem_address, opcode(MA_REG3_H-1 downto MA_REG3_L), 
						PORT_EN, "100"  
						);	
						
					direct_mem(
						mem_address, opcode(MA_REG2_H-1 downto MA_REG2_L), 
						PORT_EN, "010"  
						);	 
						
					direct_mem(
						mem_address, opcode(MA_REG1_H-1 downto MA_REG1_L), 
						PORT_EN, "001"  			
						);	  
						
					direct_mem(
						mem_address, opcode(MA_REGD_H-1 downto MA_REGD_L),
						PORT_EN, "000"
						);
					
					SF_main(
						opcode, 
						in_PORTA, 
						in_PORTB, 
						in_PORTC, 
						out_PORTD,
						write_flag
					);	
                    when "11" => 
					
                        

                    when others =>		
					   PORT_EN <= "000";
			            mem_address	<= (others => '0');
			            out_PORTD		<= (others => '0');
			            write_flag		<= '0';
			            fward_flag		<= '0';
                end case;

            else
				PORT_EN <= "000";
	            mem_address	<= (others => '-');
	            out_PORTD		<= (others => '-');
	            write_flag		<= '0';
	            fward_flag		<= '0';
            end if;
        end if;
    end process;  
end architecture;
