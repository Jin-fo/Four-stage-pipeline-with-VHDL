library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all; 

entity target_buffer is 
	port (   
	clk				: std_logic;
	--input
	if_pc           : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	
	--wback(branch)
	id_tctrl        : in std_logic;
	id_pc           : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	id_target       : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	
	--outputs(branch) 
	iff_target      : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
	
	--outputs(debug)
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
	
	signal wb_j	: integer range 0 to 2**(COUNTER_LENGTH)-1;
begin       
    
	read : process(if_pc) is
	    variable i : integer range 0 to 2**(COUNTER_LENGTH)-1;   
	    variable var_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
	begin    
	    
	    -- Reads target buffer
	    i := to_integer(unsigned(if_pc));
	    if BTB(i).valid = '1' then 
	        var_target := BTB(i).target;
	    else 
	        var_target := (others => '0');
	    end if;    	  
		-- forward target buffer
		if if_pc = id_pc then
			var_target := id_target;
	    end if;	 
	    
	    iff_target <= var_target; 
	end process; 
	
	write : process(clk, id_tctrl, id_pc, id_target)	 
		variable j : integer range 0 to 2**(COUNTER_LENGTH)-1;   
	begin
		-- Write/update target buffer
	    if falling_edge(clk) and id_tctrl = '1' then   
	        j := to_integer(unsigned(id_pc));
	        BTB(j).target <= id_target;
	        BTB(j).valid <= '1';     
	    end if;  
	end process;
	
	debug : process(id_tctrl, BTB) is
	    variable bit_index : integer := 0;
	begin		
		if id_tctrl = '1' then
		    bit_index := 0;
		    for i in 0 to (2**(COUNTER_LENGTH)-1) loop
		        out_buffer(bit_index) <= BTB(i).valid;
		        out_buffer(bit_index + COUNTER_LENGTH downto bit_index + 1)                                                                                                                                   <= BTB(i).target;
		        bit_index := bit_index + (1 + COUNTER_LENGTH);
		    end loop;
		end if;
	end process debug;
	
end architecture;