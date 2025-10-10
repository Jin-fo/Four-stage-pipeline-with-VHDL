library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.parsing_format.all;
use work.all;

entity Multimedia_ALU_tb is 
end Multimedia_ALU_tb;

architecture behavior of Multimedia_ALU_tb is 

	signal clk       	: std_logic;         
	signal enable    	: std_logic; 
	signal rst_bar   	: std_logic;  
	
	signal opcode    	: std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
	
	-- segment of 16-bits registers from memory			  
	signal in_PORTA  	: std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
	signal in_PORTB  	: std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
	signal in_PORTC  	: std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
	signal PORT_EN		: std_logic_vector(2 downto 0);
	
	signal mem_address	: std_logic_vector(MEMORY_ADDRESS_LENGTH-1 downto 0);
	signal out_PORTD	: std_logic_vector(MEMORY_REGISTER_LENGTH-1 downto 0);
	
	signal write_flag	: std_logic; 
	signal fward_flag 	: std_logic;
	
	constant period: time := 20ns;	 
			
begin 
	
	UUT : entity Multimedia_ALU port map(
		clk => clk,
		enable => enable,
		rst_bar => rst_bar,
		opcode => opcode,
		in_PORTA => in_PORTA,
		in_PORTB => in_PORTB,
		in_PORTC => in_PORTC,
		
		PORT_EN	=> PORT_EN,
		mem_address => mem_address,
		out_PORTD => out_PORTD,
		
		write_flag => write_flag, 
		fward_flag => fward_flag);
		   
	clk_process : process
	begin
	    while true loop
	        clk <= '0';
	        wait for period/2;
	        clk <= '1';
	        wait for period/2;
	    end loop;
	end process;
	
	-- stimulus process
	stim_proc : process
	begin 
		enable  <= '0';
		rst_bar <= '1';
		wait for period;
		
	    enable  <= '1';
	    -- drive opcode and inputs
	    opcode   <= b"0001" & x"DEAD" & b"00000";  -- 25 bits
	    in_PORTA <= (others => '0');
	    
	
	    -- wait for result to settle on next rising edge
	    wait for period;
	
		assert out_PORTD(31 downto 16) = x"DEAD"
	    report "Test failed: low 16 bits /= DEAD"
	    severity error;
	
		
	
	    report "Test passed!" severity note;
	    wait;
	end process;				
	
end behavior;

