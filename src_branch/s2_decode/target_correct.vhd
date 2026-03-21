library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;

entity target_correct is 
    port(   
	--inputs(branch)
    id_pc       : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
    id_immed    : in  std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
    ifd_target  : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
    id_bctrl	: in std_logic;	
	
    --outputs(branch)
    id_target   : out std_logic_vector(COUNTER_LENGTH-1 downto 0); 
    id_tctrl    : out std_logic
    );								  					   
end entity;																		   

architecture behavior of target_correct is  
begin
	----------------------------------------------------------------
	-- Process 1 : Target Calculation + Correction
	----------------------------------------------------------------
	target_proc : process(id_bctrl, id_immed)
	    variable var_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
	begin
	    if (id_bctrl = '1') then
	
			var_target := std_logic_vector(
			    signed(id_pc) + resize(signed(id_immed), COUNTER_LENGTH)
			);			   	
			
	        if var_target /= ifd_target then
	            id_tctrl <= '1'; 
			else 	 
				id_tctrl <= '0'; 
	        end if;	  
			id_target <= var_target;
		else 
			id_target <= (others=> '-');
	   		id_tctrl  <= '0';
	    end if;
	
	end process;	  
end architecture;