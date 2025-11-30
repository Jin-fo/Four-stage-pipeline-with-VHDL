library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.decoder.all;

entity register_file is
	port(		   
	clk 		: in std_logic;
	instruc		: in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
	
	wb_rd		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	wb_rd_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);  --for forwarding address comparision
	in_wback	: in std_logic;	
	
	out_file	: out std_logic_vector(REGISTER_SIZE-1 downto 0);
	opcode 		: out std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	in_rs3		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	in_rs2		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	in_rs1		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	
	in_immed	: out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0) ;
	
	rs3_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	rs2_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	rs1_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);  
	rd_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	out_wback	: out std_logic	:= '0'	 
	);
end entity;

architecture behavior of register_file is  
	signal REG_FILE	: std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
begin		
		
	register_file : process(instruc, in_wback)		
		variable var_rs3_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');
		variable var_rs2_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');
		variable var_rs1_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');
	
		variable var_rs3 	: std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
		variable var_rs2 	: std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
		variable var_rs1 	: std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
		variable read_select	: std_logic_vector(2 downto 0) := (others => '0');
	begin			   
		-----------------------------------------------------------------
        -- 1. Decode instruction
        ----------------------------------------------------------------- 
		decoder_main(
			instruc, 
		
			opcode, 
			var_rs3_ptr,
			var_rs2_ptr,
			var_rs1_ptr,
			in_immed,
			rd_ptr,
			out_wback,
			read_select); 	 
		
	    -----------------------------------------------------------------
        -- Read register values
        -----------------------------------------------------------------
		if read_select(2) = '1' then
		var_rs3 := REG_FILE(
			(to_integer(unsigned(var_rs3_ptr))+1)*(REGISTER_LENGTH)-1
			downto 
			to_integer(unsigned(var_rs3_ptr))*(REGISTER_LENGTH)); 
		end if;
		if read_select(1) = '1' then
		var_rs2 := REG_FILE(
			(to_integer(unsigned(var_rs2_ptr))+1)*(REGISTER_LENGTH)-1 
			downto 
			to_integer(unsigned(var_rs2_ptr))*(REGISTER_LENGTH));
		end if;
		if read_select(0) = '1' then
		var_rs1 := REG_FILE(
			(to_integer(unsigned(var_rs1_ptr))+1)*(REGISTER_LENGTH)-1 
			downto 
			to_integer(unsigned(var_rs1_ptr))*(REGISTER_LENGTH)); 
		end if;		  
		
        -------------------------------------------------------------------
        -- FORWARDING (COMBINATIONAL)
        -------------------------------------------------------------------
        if in_wback = '1' then
            if wb_rd_ptr = var_rs3_ptr then
                var_rs3 := wb_rd;
            end if;
            if wb_rd_ptr = var_rs2_ptr then
                var_rs2 := wb_rd;
            end if;
            if wb_rd_ptr = var_rs1_ptr then
                var_rs1 := wb_rd;
            end if;	
			REG_FILE(
                (to_integer(unsigned(wb_rd_ptr))+1)*REGISTER_LENGTH - 1 downto
				to_integer(unsigned(wb_rd_ptr))*REGISTER_LENGTH) <= wb_rd;	
        end if;		
		
        -----------------------------------------------------------------
        -- Drive outputs
        -----------------------------------------------------------------
		in_rs3 <= var_rs3;
		in_rs2 <= var_rs2;
		in_rs1 <= var_rs1;
		
		rs3_ptr <= var_rs3_ptr;
		rs2_ptr <= var_rs2_ptr;
		rs1_ptr	<= var_rs1_ptr;	
		
		out_file <= REG_FILE;
	end process;   
end architecture;
																	 