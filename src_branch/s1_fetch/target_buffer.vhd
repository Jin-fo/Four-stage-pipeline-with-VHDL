library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all; 

entity target_buffer is 
	port (   
		if_pc           : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
		
		id_tctrl        : in std_logic;
		id_pc           : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
		id_target       : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
		
		iff_target      : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
		out_buffer	  : out std_logic_vector(BUFFER_SIZE-1 downto 0)
	); 
end entity;

architecture behavior of target_buffer is       
    type entry is record
        valid  : std_logic;
        target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    end record;
    
    -- Branch Target Buffer(BTB): direct-mapped
    type BTB_array is array(0 to 2**(COUNTER_LENGTH)-1) of entry;
    signal BTB : BTB_array := (others => (
        valid  => '0',
        target => (others => '0')
    ));   
begin       
    
	main : process(if_pc) is
	    variable i : integer range 0 to 2**(COUNTER_LENGTH)-1; 
	    variable j : integer range 0 to 2**(COUNTER_LENGTH)-1;  
	    variable var_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
	begin    
	    
	    -- Reads target buffer
	    i := to_integer(unsigned(if_pc));
	    if BTB(i).valid = '1' then 
	        var_target := BTB(i).target;
	    else 
	        var_target := (others => '0');
	    end if;  
	    
	    -- Write/update and forward target buffer
	    if id_tctrl = '1' then   
	        j := to_integer(unsigned(id_pc));
	        BTB(j).target <= id_target;
	        BTB(j).valid <= '1';     
	        
	        if i = j then 
	            var_target := id_target;
	        end if;	
	    end if;  
	    
	    iff_target <= var_target; 
	end process; 
	
	debug : process(BTB) is
	    variable bit_index : integer := 0;
	begin
	    bit_index := 0;
	    for i in 0 to (2**(COUNTER_LENGTH)-1) loop
	        out_buffer(bit_index) <= BTB(i).valid;
	        out_buffer(bit_index + COUNTER_LENGTH downto bit_index + 1)                                                                                                                                   <= BTB(i).target;
	        bit_index := bit_index + (1 + COUNTER_LENGTH);
	    end loop;
	end process debug;
	
end architecture;