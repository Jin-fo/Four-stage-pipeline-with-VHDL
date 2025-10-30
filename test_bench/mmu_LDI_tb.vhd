library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.all;

entity mmu_LDI_tb is 
end mmu_LDI_tb;

architecture test_bench of mmu_LDI_tb is 
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
	
	-- stimulus process
	stim_proc : process
	begin
--------------------------------------------------------------------
-- load_immediate TEST w/ indexing
--------------------------------------------------------------------	    
		in_immed <= x"DEAD";
		in_d_ptr <= b"00000";
	    in_PORT3 <= (others => '0'); 
	--------------------------------------------------------------------
	-- TEST: opcode = 0--000
	--------------------------------------------------------------------
        opcode <= std_logic_vector(to_unsigned(0, OPCODE_LENGTH));
        wait for period;
        assert out_PORTD(15 downto 0) = x"DEAD"
		report "Test failed: 000000, out_PORTD = x" & slv_to_hex(out_PORTD)
		    severity error;

	--------------------------------------------------------------------
	-- TEST: opcode = 0--001
	--------------------------------------------------------------------
        opcode <= std_logic_vector(to_unsigned(1, OPCODE_LENGTH));
        wait for period;
        assert out_PORTD(31 downto 16) = x"DEAD"
            report "Test failed: 000001, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;

	--------------------------------------------------------------------
	-- TEST: opcode = 0--110
	--------------------------------------------------------------------
        opcode <= std_logic_vector(to_unsigned(6, OPCODE_LENGTH));
        wait for period;
        assert out_PORTD(111 downto 96) = x"DEAD"
            report "Test failed: 100110, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;	 
			
	--------------------------------------------------------------------
	-- TEST: opcode = 0--111
	--------------------------------------------------------------------
        opcode <= std_logic_vector(to_unsigned(7, OPCODE_LENGTH));
        wait for period;
        assert out_PORTD(127 downto 112) = x"DEAD"
            report "Test failed: 100111, out_PORTD = x" & slv_to_hex(out_PORTD)
            severity error;	 
			
        report "TEST COMPLETED: load_immediate w/ indexing" severity warning;
	end process;				
end test_bench;


