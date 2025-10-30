library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.all;

entity mmu_RSI_tb is 
end mmu_RSI_tb;

architecture test_bench of mmu_RSI_tb is 
	-- Control FLAG
    signal write_flag  : std_logic := '0';

    -- Inputs to ALU
    signal opcode      : std_logic_vector(OPCODE_LENGTH-1 downto 0);
    signal in_PORT3    : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal in_PORT2    : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal in_PORT1    : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal in_immed    : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
    signal in_d_ptr    : std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    -- Outputs ALU
    signal out_PORTD   : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal out_d_ptr   : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal wback_flag  : std_logic;
	
	constant period: time := 20ns;	 
    --------------------------------------------------------------------
    -- Helper: Convert std_logic_vector ? hex string (portable)
    --------------------------------------------------------------------
    function slv_to_hex(slv : std_logic_vector) return string is
 		variable num_nibbles : integer := (slv'length + 3) / 4;
        	variable padded_slv  : std_logic_vector(num_nibbles * 4 - 1 downto 0);
        	variable result      : string(1 to num_nibbles);
        	variable nibble_val  : integer;
	begin
			-- Pad MSBs with zeros if not multiple of 4 bits
			padded_slv := (others => '0');
			padded_slv(slv'length - 1 downto 0) := slv;
		
			for i in 0 to num_nibbles - 1 loop
		   	nibble_val := to_integer(unsigned(padded_slv((i+1)*4 - 1 downto i*4)));
				case nibble_val is
				when 0  => result(num_nibbles - i) := '0';
				when 1  => result(num_nibbles - i) := '1';
				when 2  => result(num_nibbles - i) := '2';
				when 3  => result(num_nibbles - i) := '3';
				when 4  => result(num_nibbles - i) := '4';
				when 5  => result(num_nibbles - i) := '5';
				when 6  => result(num_nibbles - i) := '6';
				when 7  => result(num_nibbles - i) := '7';
				when 8  => result(num_nibbles - i) := '8';
				when 9  => result(num_nibbles - i) := '9';
				when 10 => result(num_nibbles - i) := 'A';
				when 11 => result(num_nibbles - i) := 'B';
				when 12 => result(num_nibbles - i) := 'C';
				when 13 => result(num_nibbles - i) := 'D';
				when 14 => result(num_nibbles - i) := 'E';
				when 15 => result(num_nibbles - i) := 'F';
				when others => result(num_nibbles - i) := 'X';
			end case;
		end loop;
		return result;
	end function;
    --------------------------------------------------------------------

begin  
	UUT : entity work.MMU_ALU 
		port map(
			opcode      => opcode,
			in_PORT3    => in_PORT3,
			in_PORT2    => in_PORT2,
			in_PORT1    => in_PORT1,
			in_immed    => in_immed,
			in_d_ptr    => in_d_ptr,
			
			out_PORTD   => out_PORTD,
			out_d_ptr   => out_d_ptr,
			wback_flag  => wback_flag
		);
		   
    -- Clock process

	
	-- Stimulus process
	stim_proc : process
	begin
----------------------------------------------------------------
-- rest_instruction TEST 
---------------------------------------------------------------- 
	in_d_ptr <= b"00000";

	--------------------------------------------------------------------
    -- TEST: Opcode 110001
    --------------------------------------------------------------------
	opcode <= "110001";	  	 
	in_immed <= x"0004"; 
	in_PORT2 <=(others => '-');
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"0700070007000700070007000F000700"
	report "TEST FAIL: 110001, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	--------------------------------------------------------------------
    -- TEST: Opcode 110010, stauturated
    --------------------------------------------------------------------
	opcode <= "110010";	 
	in_PORT2 <= x"80010004800100037FFF00027FFF0001";
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"F009700BF0077008F0037005FFFFFFFF"
	report "TEST FAIL: 110010, wback =" & slv_to_hex(out_PORTD)
	severity error;	
		
	--------------------------------------------------------------------
    -- TEST: Opcode 110011
    --------------------------------------------------------------------
	opcode <= "110011";	   
	in_PORT2 <= (others => '-');
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"00040006000500050004000500050004"
	report "TEST FAIL: 110011, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110100
    --------------------------------------------------------------------
	opcode <= "110100";	
	in_PORT2 <= x"80010004800100037FFF00027FFF0001";
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"F009700BF00770087FFF700570017002"
	report "TEST FAIL: 110100, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110101
    --------------------------------------------------------------------
	opcode <= "110101";
	in_PORT2 <= x"0000000000000000FFFFFFFFFFFFFFFF";
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"7008700770067005FFFFFFFFFFFFFFFF"
	report "TEST FAIL: 110101, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110110
    --------------------------------------------------------------------
	opcode <= "110110";		   
	in_PORT2 <= (others => '-');	 
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"70087007700870077008700770087007"
	report "TEST FAIL: 110110, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110111
    --------------------------------------------------------------------
	opcode <= "110111";	
	in_PORT2 <= x"80010004800100037FFF00027FFF0001";
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;	
	assert out_PORTD = x"70087007700670057FFF00027FFF0001"
	report "TEST FAIL: 110111, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111000
    --------------------------------------------------------------------
	opcode <= "111000";
	in_PORT2 <= x"80010004800100037FFF00027FFF0001";
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;		
	assert out_PORTD = x"800100048001000370047003F0027001"
	report "TEST FAIL: 111000, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111001
    --------------------------------------------------------------------
	opcode <= "111001";	   
	in_PORT2 <= x"80010004800100037FFF00027FFF0001";
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"0001C01C0001500F0000E00600007001"
	report "TEST FAIL: 111001, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111010
    --------------------------------------------------------------------
	opcode <= "111010";	   
	in_immed <= x"0014"; 
	in_PORT2 <= (others => '-');
	in_PORT1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert out_PORTD = x"000000500000003C0000002800000014"
	report "TEST FAIL: 111010, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111011
    --------------------------------------------------------------------
	opcode <= "111011";	
	in_PORT2 <= x"0000000000000000FFFFFFFFFFFFFFFF";
	in_PORT1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert out_PORTD = x"00000000000000007FFF00027FFF0001"
	report "TEST FAIL: 111011, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111100
    --------------------------------------------------------------------   
	opcode <= "111100";		   
	in_PORT2 <= (others => '-');
	in_PORT1 <= x"070870071006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"00000005000000030000000100000000"
	report "TEST FAIL: 111100, wback =" & slv_to_hex(out_PORTD)
	severity error;												   
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111101
    --------------------------------------------------------------------   
	opcode <= "111101";	  
	in_immed <= x"0014"; 
	in_PORT2 <= (others => '-');
	in_PORT1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert out_PORTD = x"1000480010003800F00027FFF00017FF"
	report "TEST FAIL: 111101, wback =" & slv_to_hex(out_PORTD)
	severity error;			 

	--------------------------------------------------------------------
    -- TEST: Opcode 111110
    --------------------------------------------------------------------   
	opcode <= "111110";	 
	in_PORT2 <= x"80010004800100037FFF00027FFF0001";
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"0FF88FFD0FFA8FFE0FFA8FFF00000000"
	report "TEST FAIL: 111110, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111111
    --------------------------------------------------------------------   
	opcode <= "111111";	
	in_PORT2 <= x"80010004800100037FFF00027FFF0001";
	in_PORT1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_PORTD = x"80008FFD80008FFE0FFB8FFF7FFF9000"
	report "TEST FAIL: 111111, wback =" & slv_to_hex(out_PORTD)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110000
    --------------------------------------------------------------------
	opcode <= "110000";	   
	in_PORT2 <= (others => '-');
	in_PORT1 <= (others => '-');
	wait for period;	  
	assert wback_flag = '0'
	report "TEST FAIL: 110000, wback =" & std_logic'image(wback_flag)
	severity error;	
	
    report "TEST COMPLETED: rest of the instruction" severity warning;
	end process;
end test_bench; 
