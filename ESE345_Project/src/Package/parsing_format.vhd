library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package parsing_format is 				
	--max/min decimal values		
	constant MAX32 : signed(31 downto 0) := to_signed(2**31 - 1, 32);
	constant MIN32 : signed(31 downto 0) := to_signed(-2**31, 32);	
	constant MAX64 : signed(63 downto 0) := to_signed(2**63 -1, 64);
	constant MIN64 : signed(63 downto 0) := to_signed(-2**63, 64);	
	
	constant MAX16			: signed(15 downto 0) := to_signed(2**15 - 1, 16); 
	constant MIN16			: signed(15 downto 0) := to_signed(-2**15, 16);
	constant MAX32_unsigned : unsigned(31 downto 0) := (others => '1');
	
	
	--Register Deminision
	constant INSTRUCTION_LENGTH 	 : integer := 25;  --25-bit instruction
	constant MEMORY_REGISTER_LENGTH	 : integer := 128; --128-bit register
	
	constant MEMORY_ADDRESS_LENGTH   : integer := 5;   --32 register, 5-bit address
	constant MAX_VALUE_LENGTH		 : integer := 16;  
	
	constant MEMORY_INDEX_LENGTH 	 : integer := 3;   -- log2(MEMORY_REGISTER_LENGTH / MAX_VALUE_LENGTH)
											
	--Load_immediate parsed-instruction length variable
	constant LI_TYPE 	: integer := 1;	  -- 0-  
	
	constant LI_INDEX 	: integer := MEMORY_INDEX_LENGTH;   
	constant LI_VALUE 	: integer := MAX_VALUE_LENGTH; 
	constant LI_REGD	: integer := MEMORY_ADDRESS_LENGTH;	 
	
	--Multiply_add parsed-instruction length variable
	constant MA_TYPE	: integer := 2;	  -- 10
	constant MA_LISAHL	: integer := 3;	  

	constant MA_REG3	: integer := MEMORY_ADDRESS_LENGTH;
	constant MA_REG2	: integer := MEMORY_ADDRESS_LENGTH;
	constant MA_REG1	: integer := MEMORY_ADDRESS_LENGTH; 
	constant MA_REGD	: integer := MEMORY_ADDRESS_LENGTH;	 
	
	--Opcode_rest parsed-instruction length variable
	constant OR_TYPE	: integer := 2;	  -- 11
	constant OR_CODE	: integer := 8;	  
	
	constant OR_REG2	: integer := MEMORY_ADDRESS_LENGTH;
	constant OR_REG1	: integer := MEMORY_ADDRESS_LENGTH;
	constant OR_REGD	: integer := MEMORY_ADDRESS_LENGTH;
	
	--Load_Immediate bit position of each bit
	constant LI_INDEX_H : integer := INSTRUCTION_LENGTH - LI_TYPE;
	constant LI_INDEX_L : integer := LI_INDEX_H - LI_INDEX;	  
	constant LI_VALUE_H	: integer := LI_INDEX_L; 
	constant LI_VALUE_L : integer := LI_VALUE_H - LI_VALUE;
	constant LI_REGD_H	: integer := LI_VALUE_L;
	constant LI_REGD_L	: integer := 0;		  
	--Multiply_add bit position of each bit

	constant MA_LISAHL_H: integer := INSTRUCTION_LENGTH - MA_TYPE;
	constant MA_LISAHL_L: integer := MA_LISAHL_H - MA_LISAHL;
	constant MA_REG3_H 	: integer := MA_LISAHL_L;
	constant MA_REG3_L	: integer := MA_REG3_H - MA_REG3;
	constant MA_REG2_H	: integer := MA_REG3_L;
	constant MA_REG2_L	: integer := MA_REG2_H - MA_REG2;
	constant MA_REG1_H	: integer := MA_REG2_L;
	constant MA_REG1_L	: integer := MA_REG1_H - MA_REG1;
	constant MA_REGD_H	: integer := MA_REG1_L;
	constant MA_REGD_L	: integer := 0;
	--Opcode_rest bit position of each bit

	constant OR_CODE_H	: integer := INSTRUCTION_LENGTH - OR_TYPE;
	constant OR_CODE_L	: integer := OR_CODE_H - OR_CODE;
	constant OR_REG2_H	: integer := OR_CODE_L;
	constant OR_REG2_L	: integer := OR_REG2_H - OR_REG2;
	constant OR_REG1_H	: integer := OR_REG2_L;
	constant OR_REG1_L	: integer := OR_REG1_H - OR_REG1;
	constant OR_REGD_H	: integer := OR_REG1_L;
	constant OR_REGD_L	: integer := 0;
	
end package;
