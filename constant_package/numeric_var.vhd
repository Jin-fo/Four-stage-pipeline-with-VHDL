library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package numeric_var is
	
--------INSTRUCTION_FIELD_CONSTANT-------------------------------------------------
	constant IMMEDIATE_LENGTH			: integer := 16;
	constant INDEX_LENGTH				: integer := 3;
	constant OPCODE_LENGTH				: integer := 6;	
	constant INSTRUCTION_LENGTH			: integer := 25;
	
--------REGISTER_FILE_CONSTANT-------------------------------------------------	
	constant VALUE16					: integer := 16;
	constant ADDRESS_LENGTH				: integer := 5;		 
	constant REGISTER_LENGTH			: integer := 128;  

--------INSTRUCTION_LENGTH_CONSTANT-------------------------------------------------
	--constant LDI_TYPE					: integer := 1; 	
	--constant LDI_INDEX					: integer := INDEX_LENGTH;
	--constant LDI_VALUE					: integer := IMMEDIATE_LENGTH;
	--constant LDI_REGD					: integer := ADDRESS_LENGTH;
	
	--constant STM_TYPE					: integer := 2; 
	--constant STM_LISAHL					: integer := 3;
	--constant STM_REG3					: integer := ADDRESS_LENGTH;
	--constant STM_REG2					: integer := ADDRESS_LENGTH;
	--constant STM_REG1					: integer := ADDRESS_LENGTH;
	--constant STM_REGD					: integer := ADDRESS_LENGTH;
	
	--constant RSI_NULL					: integer := 2;
	--constant RSI_TYPE					: integer := 8;
	--constant RSI_REG2					: integer := ADDRESS_LENGTH;
	--constant RSI_REG1					: integer := ADDRESS_LENGTH;
	--constant RSI_REGD					: integer := ADDRESS_LENGTH;
end package;