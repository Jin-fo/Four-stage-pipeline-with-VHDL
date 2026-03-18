library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.numeric_var.all;

entity register_file is
	port(		   
	read_sel	: in std_logic_vector(2 downto 0);
	
	id_rs3_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	id_rs2_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	id_rs1_ptr  : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	
	wb_rd		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	wb_rd_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);  --for forwarding address comparision
	wb_wback	: in std_logic;	
	
	out_file	: out std_logic_vector(REGISTER_SIZE-1 downto 0);
	
	id_rs3		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	id_rs2		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	id_rs1		: out std_logic_vector(REGISTER_LENGTH-1 downto 0)	 
	);
end entity;

architecture behavior of register_file is  
	signal REG_FILE	: std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
begin		
		
	register_file : process(read_sel, id_rs3_ptr, id_rs2_ptr, id_rs1_ptr, wb_wback)		
		variable var_rs3 	: std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
		variable var_rs2 	: std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
		variable var_rs1 	: std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
	begin			   
	    -----------------------------------------------------------------
        -- Read register values
        -----------------------------------------------------------------
		if read_sel(2) = '1' then
		var_rs3 := REG_FILE(
			(to_integer(unsigned(id_rs3_ptr))+1)*(REGISTER_LENGTH)-1
			downto 
			to_integer(unsigned(id_rs3_ptr))*(REGISTER_LENGTH)); 
		end if;
		if read_sel(1) = '1' then
		var_rs2 := REG_FILE(
			(to_integer(unsigned(id_rs2_ptr))+1)*(REGISTER_LENGTH)-1 
			downto 
			to_integer(unsigned(id_rs2_ptr))*(REGISTER_LENGTH));
		end if;
		if read_sel(0) = '1' then
		var_rs1 := REG_FILE(
			(to_integer(unsigned(id_rs1_ptr))+1)*(REGISTER_LENGTH)-1 
			downto 
			to_integer(unsigned(id_rs1_ptr))*(REGISTER_LENGTH)); 
		end if;		  
		
        -------------------------------------------------------------------
        -- FORWARDING
        -------------------------------------------------------------------
        if wb_wback = '1' then
            if wb_rd_ptr = id_rs3_ptr then
                var_rs3 := wb_rd;
            end if;
            if wb_rd_ptr = id_rs2_ptr then
                var_rs2 := wb_rd;
            end if;
            if wb_rd_ptr = id_rs1_ptr then
                var_rs1 := wb_rd;
            end if;	
			REG_FILE(
                (to_integer(unsigned(wb_rd_ptr))+1)*REGISTER_LENGTH - 1 downto
				to_integer(unsigned(wb_rd_ptr))*REGISTER_LENGTH) <= wb_rd;	
        end if;		
		
        -----------------------------------------------------------------
        -- Drive outputs
        -----------------------------------------------------------------
		id_rs3 <= var_rs3;
		id_rs2 <= var_rs2;
		id_rs1 <= var_rs1;
		
		out_file <= REG_FILE;
	end process;   
end architecture;