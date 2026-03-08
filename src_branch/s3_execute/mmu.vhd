library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.load_immediate.all;
use work.saturate_math.all;
use work.rest_instruction.all; 

entity mmu is 
	port ( 
	--inputs
	ex_opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	ex_rs3		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	ex_rs2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	ex_rs1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	ex_immed	: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	--fowarding
	ex_rs3_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_rs2_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_rs1_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	
	wb_rd		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	wb_rd_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);  --for forwarding address comparision
	wb_wback	: in std_logic;
	
	--branching	   
	ex_pctrl	: in std_logic;	  
	ex_brch		: in std_logic;
	pc_sctrl	: out std_logic := '0';
	flush_ctrl	: out std_logic := '0';
	
	--outputs				 
	ex_rd		: out std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-')
	);
end entity;

architecture behavior of mmu is	  
begin 
	main : process( 
		ex_opcode,
		ex_rs3, ex_rs2, ex_rs1, ex_immed,
		ex_rs3_ptr, ex_rs2_ptr, ex_rs1_ptr,
		wb_rd, wb_rd_ptr, wb_wback,
		ex_pctrl)
		
		variable fw_rs3 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
		variable fw_rs2 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
		variable fw_rs1 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
		variable var_ctrl : std_logic := '0';
	begin		 
		-- no forward pre-set
	    fw_rs3 := ex_rs3;
	    fw_rs2 := ex_rs2;
	    fw_rs1 := ex_rs1;
	
	    -- Apply forwarding if needed
	    if wb_wback = '1' then
	        if wb_rd_ptr = ex_rs3_ptr then fw_rs3 := wb_rd; end if;
	        if wb_rd_ptr = ex_rs2_ptr then fw_rs2 := wb_rd; end if;
	        if wb_rd_ptr = ex_rs1_ptr then fw_rs1 := wb_rd; end if;
	    end if;

		case ex_opcode(OPCODE_LENGTH-1 downto OPCODE_LENGTH-2) is 
			when "00" | "01" =>
				LDI_memory(		 	--ref. procedure_package/load_immediate.vhd
					ex_opcode, 
					fw_rs3, 
					ex_immed,     
					
					ex_rd 
				);
			
			when "10" =>
				STM_main(			--ref. procedure_package/saturate_math.vhd
					ex_opcode, 
					fw_rs3, 
					fw_rs2, 
					fw_rs1,  	
					
					ex_rd 
				);
			
			when "11" =>  			 
				if ex_brch = '1' then 
					BRH_main(		--ref. procedure_package/rest_instruction.vhd
						ex_opcode,
						fw_rs2,
						fw_rs1,	
						
						var_ctrl
					); 
					if var_ctrl = ex_pctrl then 	
						flush_ctrl <= '0';
					else
						flush_ctrl <= '1';
					end if ; 
					pc_sctrl <= var_ctrl;
					
				else 
					RSI_main(			--ref. procedure_package/rest_instruction.vhd	
						ex_opcode, 
						fw_rs2, 
						fw_rs1,
						ex_immed,	
						
						ex_rd 
					);	
					flush_ctrl <= '0';
					pc_sctrl <= '0';
				end if;
			when others => 
				null;
		end case;
	end process;
end architecture;