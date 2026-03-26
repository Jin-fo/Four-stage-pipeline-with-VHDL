library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.load_immediate.all;
use work.saturate_math.all;
use work.rest_instruction.all; 

entity mmu is 
	port ( 
	--inputs(data)
	ex_opcode	: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
	fw_rs3		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_rs2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_rs1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	ex_immed	: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	--inputs(branch)	 
	ex_pc		: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	ex_pctrl	: in std_logic;	  
	ex_bctrl		: in std_logic;
	
	--outputs(data)
	ex_rd		: out std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
	
	--outputs(branch)
	pc_sctrl	: out std_logic := '0';
	flush_ctrl	: out std_logic := '0'; 
	brch_pc		: out std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '0')
	);
end entity;

architecture behavior of mmu is	  
begin 
	main : process(   
		ex_opcode,
		fw_rs3, fw_rs2, fw_rs1, ex_immed)
		
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
				if ex_bctrl = '1' then 
					BRH_main(		--ref. procedure_package/rest_instruction.vhd
						ex_opcode,
						fw_rs2,
						fw_rs1,	
						
						var_ctrl
					); 
					
					
--					--seperate,,,.
					if (ex_pctrl = '1' and var_ctrl = '0') then		--should not branch, pc <= ex_pc + 1,	
						brch_pc	<= std_logic_vector(unsigned(ex_pc) + INCREMENT);		   		
					elsif (ex_pctrl = '0' and var_ctrl = '1') then	--should branch, pc <= ex_pc + immed
						brch_pc <= std_logic_vector(
							            resize(signed(ex_pc), COUNTER_LENGTH) +
							            resize(signed(ex_immed), COUNTER_LENGTH)
							        );										
					end if ; 
					
					flush_ctrl <= var_ctrl xor ex_pctrl;
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
			when others => --nop don't cares
		end case;
	end process;
end architecture;
