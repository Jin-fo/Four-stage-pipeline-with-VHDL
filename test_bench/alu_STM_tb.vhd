library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.all;

entity alu_STM_tb is 
end alu_STM_tb;

architecture test_bench of alu_STM_tb is 
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
		   
	-- Stimulus process
	stim_proc : process
	begin
----------------------------------------------------------------
-- saturate_math TEST w/o saturating
---------------------------------------------------------------- 
		in_immed <= x"DEAD";
		in_d_ptr <= b"00000";
		in_PORT3 <= x"00010002000300040005000600070008";
		in_PORT2 <= x"00080007000600050004000300020001";
		in_PORT1 <= (others => '0');

    --------------------------------------------------------------------
    -- TEST: Opcode 10-000
    --------------------------------------------------------------------
		opcode <= "100000"; 
		wait for period;
		assert out_PORTD = x"0000000E000000140000001200000008" 
		    report "Test failed: 100000, out_PORTD = x" & slv_to_hex(out_PORTD)
		    severity error; 

    --------------------------------------------------------------------
    -- TEST: Opcode 10-001 
    --------------------------------------------------------------------
    	opcode <= "100001"; 
    	wait for period;
    	assert out_PORTD = x"0000000800000012000000140000000E"
        	report "Test failed: 100001, out_PORTD = x" & slv_to_hex(out_PORTD)
        	severity error;

	--------------------------------------------------------------------
	-- TEST: Opcode 10-010
	--------------------------------------------------------------------
        opcode <= "100010"; 
        wait for period;
        assert out_PORTD = x"FFFFFFF2FFFFFFECFFFFFFEEFFFFFFF8"
            report "Test failed: 100010, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-011		
	--------------------------------------------------------------------
        opcode <= "100011"; 
        wait for period;
        assert out_PORTD = x"FFFFFFF8FFFFFFEEFFFFFFECFFFFFFF2"
            report "Test failed: 100011, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-100
	--------------------------------------------------------------------        
        opcode <= "100100"; 
        wait for period;
        assert out_PORTD = x"00000012002700140000000E00170008"
            report "Test failed: 100100, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-101
	--------------------------------------------------------------------        
        opcode <= "100101"; 
        wait for period;
        assert out_PORTD = x"000000080017000E0000001400270012"
            report "Test failed: 100101, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-110	
	--------------------------------------------------------------------
        opcode <= "100110"; 
        wait for period;
        assert out_PORTD = x"FFFFFFEDFFD8FFECFFFFFFF1FFE8FFF8"
            report "Test failed: 100110, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;	 
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-111	
	--------------------------------------------------------------------
        opcode <= "100111"; 
        wait for period;
        assert out_PORTD = x"FFFFFFF7FFE8FFF2FFFFFFEBFFD8FFEE"
            report "Test failed: 100111, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;																   

        report "TEST COMPLETED: saturate_math w/o saturating" severity warning;  
		
----------------------------------------------------------------
-- saturate_math TEST w/ overflow saturating
---------------------------------------------------------------- 
		in_immed <= x"DEAD";
		in_d_ptr <= b"00000";
		in_PORT3 <= x"700170027003700470057006F0077008";
		in_PORT2 <= x"700870077006700570047003F0027001";
		in_PORT1 <= x"7FFF00007FFF00007FFF00007FFF0000";

    --------------------------------------------------------------------
    -- TEST: Opcode 10-000
    --------------------------------------------------------------------
		opcode <= "100000"; 
		wait for period;
		assert out_PORTD = x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF" 
		    report "Test failed: 100000, out_PORTD = x" & slv_to_hex(out_PORTD)
		    severity error; 

    --------------------------------------------------------------------
    -- TEST: Opcode 10-001 
    --------------------------------------------------------------------
    	opcode <= "100001"; 
    	wait for period;
    	assert out_PORTD = x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"
        	report "Test failed: 100001, out_PORTD = x" & slv_to_hex(out_PORTD)
        	severity error;	
		--------------------------------------------------------------------			
	-- TEST: Opcode 10-100
	--------------------------------------------------------------------        
        opcode <= "100100"; 
        wait for period;
        assert out_PORTD = x"7FFFFFFFFFFFFFFF7FFFFFFFFFFFFFFF"
            report "Test failed: 100100, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-101
	--------------------------------------------------------------------        
        opcode <= "100101"; 
        wait for period;
        assert out_PORTD = x"7FFFFFFFFFFFFFFF7FFFFFFFFFFFFFFF"
            report "Test failed: 100101, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;			  
			
		report "TEST COMPLETED: saturate_math w/ overflow saturating" severity warning;		
----------------------------------------------------------------
-- saturate_math TEST w/ underflow saturating
----------------------------------------------------------------
	in_PORT1 <= x"80010000800100008001000080010000";
	--------------------------------------------------------------------
	-- TEST: Opcode 10-010
	--------------------------------------------------------------------  
        opcode <= "100010"; 
        wait for period;
        assert out_PORTD = x"80000000800000008000000080000000"
            report "Test failed: 100010, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-011		
	--------------------------------------------------------------------
        opcode <= "100011"; 
        wait for period;
        assert out_PORTD = x"80000000800000008000000080000000"
            report "Test failed: 100011, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-110	
	--------------------------------------------------------------------
        opcode <= "100110"; 
        wait for period;
        assert out_PORTD = x"80000000000000008000000000000000"
            report "Test failed: 100110, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;	 
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-111	
	--------------------------------------------------------------------
        opcode <= "100111"; 
        wait for period;
        assert out_PORTD = x"80000000000000008000000000000000"
            report "Test failed: 100111, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;																   

        report "TEST COMPLETED: saturate_math w/ underflow saturating" severity warning;
		wait;
	end process;				
end test_bench;

