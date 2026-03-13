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
	ex_opcode	: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	fw_rs3		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_rs2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_rs1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	ex_immed	: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	--branching	   
	ex_pctrl	: in std_logic;	  
	ex_brch		: in std_logic;
	
	--outputs	
	pc_sctrl	: out std_logic;
	flush_ctrl	: out std_logic;			 
	ex_rd		: out std_logic_vector(REGISTER_LENGTH-1 downto 0)
	);
end entity;

architecture behavior of mmu is	  
begin 
	main : process( 
		ex_opcode,
		fw_rs3, fw_rs2, fw_rs1, ex_immed,
		ex_pctrl, ex_brch)
		
		variable var_ctrl : std_logic;
	begin		 
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