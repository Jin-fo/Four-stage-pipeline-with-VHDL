library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.all;

entity mmu_RSI_tb is 
end mmu_RSI_tb;

architecture test_bench of mmu_RSI_tb is 
	--inputs
	signal ex_opcode		: std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	signal ex_rs3		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal ex_rs2		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal ex_rs1		: std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	signal ex_immed		: std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	--fowarding
	signal ex_rs3_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_rs2_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_rs1_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	
	signal wb_rd		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal wb_rd_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0);  --for forwarding address comparision
	signal wb_wback		: std_logic; 
	
	--branching
	signal ex_pctrl		: std_logic; 
	signal ex_brch		: std_logic;
	signal pc_sctrl		: std_logic;
	signal flush_ctrl 	: std_logic;
	
	--outputs
	signal ex_rd		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	
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
	UUT : entity work.mmu 
		port map(
        ex_opcode      => ex_opcode,

        ex_rs3    	=> ex_rs3,
        ex_rs2    	=> ex_rs2,
        ex_rs1    	=> ex_rs1,
        ex_immed    => ex_immed,
		
		ex_rs3_ptr		=> ex_rs3_ptr,
		ex_rs2_ptr		=> ex_rs2_ptr,
		ex_rs1_ptr		=> ex_rs1_ptr,
		
		wb_rd 	  	=> wb_rd,
		wb_rd_ptr 	=> wb_rd_ptr,
		wb_wback 	=> wb_wback,
		
		ex_pctrl	=> ex_pctrl,
		ex_brch		=> ex_brch,
		pc_sctrl	=> pc_sctrl,
		flush_ctrl	=> flush_ctrl,
		
        ex_rd   	=> ex_rd
		);
		   
    -- Clock process

	
	-- Stimulus process
	stim_proc : process
	begin
----------------------------------------------------------------
-- rest_instruction TEST 
---------------------------------------------------------------- 
	--------------------------------------------------------------------
    -- TEST: ex_opcode 110001
    --------------------------------------------------------------------
	ex_brch <= '0';
	ex_opcode <= "110001";	  	 
	ex_immed <= x"0004"; 
	ex_rs2 <=(others => '-');
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert ex_rd = x"0700070007000700070007000F000700"
	report "TEST FAIL: 110001, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 110010, stauturated
    --------------------------------------------------------------------
	ex_opcode <= "110010";	 
	ex_rs2 <= x"80010004800100037FFF00027FFF0001";
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert ex_rd = x"F009700BF0077008F0037005FFFFFFFF"
	report "TEST FAIL: 110010, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
		
	--------------------------------------------------------------------
    -- TEST: ex_opcode 110011
    --------------------------------------------------------------------
	ex_opcode <= "110011";	   
	ex_rs2 <= (others => '-');
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert ex_rd = x"00040006000500050004000500050004"
	report "TEST FAIL: 110011, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 110100
    --------------------------------------------------------------------
	ex_opcode <= "110100";	
	ex_rs2 <= x"80010004800100037FFF7FF27FFFFFF1";
	ex_rs1 <= x"700870077006800570047003F0027001";
	wait for period;
	assert ex_rd = x"F009700BF00780087FFF7FFF70016FF2"
	report "TEST FAIL: 110100, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 110101
    --------------------------------------------------------------------
	ex_opcode <= "110101";
	ex_rs2 <= x"0000000000000000FFFFFFFFFFFFFFFF";
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert ex_rd = x"7008700770067005FFFFFFFFFFFFFFFF"
	report "TEST FAIL: 110101, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 110110
    --------------------------------------------------------------------
	ex_opcode <= "110110";		   
	ex_rs2 <= (others => '-');	 
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert ex_rd = x"70087007700870077008700770087007"
	report "TEST FAIL: 110110, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 110111
    --------------------------------------------------------------------
	ex_opcode <= "110111";	
	ex_rs2 <= x"80010004800100037FFF00027FFF0001";
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;	
	assert ex_rd = x"70087007700670057FFF00027FFF0001"
	report "TEST FAIL: 110111, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 111000
    --------------------------------------------------------------------
	ex_opcode <= "111000";
	ex_rs2 <= x"80010004800100037FFF00027FFF0001";
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;		
	assert ex_rd = x"800100048001000370047003F0027001"
	report "TEST FAIL: 111000, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 111001
    --------------------------------------------------------------------
	ex_opcode <= "111001";	   
	ex_rs2 <= x"80010004800100037FFF7FF27FFFFFF1";
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert ex_rd = x"0001C01C0001500F37FB5FD66FFA6FF1"
	report "TEST FAIL: 111001, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 111010
    --------------------------------------------------------------------
	ex_opcode <= "111010";	   
	ex_immed <= x"0014"; 
	ex_rs2 <= (others => '-');
	ex_rs1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert ex_rd = x"000000500000003C0000002800000014"
	report "TEST FAIL: 111010, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 111011
    --------------------------------------------------------------------
	ex_opcode <= "111011";	
	ex_rs2 <= x"0000000000000000FFFFFFFFFFFFFFFF";
	ex_rs1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert ex_rd = x"00000000000000007FFF00027FFF0001"
	report "TEST FAIL: 111011, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 111100
    --------------------------------------------------------------------   
	ex_opcode <= "111100";		   
	ex_rs2 <= (others => '-');
	ex_rs1 <= x"070870071006700570047003F0027001";
	wait for period;
	assert ex_rd = x"00000005000000030000000100000000"
	report "TEST FAIL: 111100, ex_rd =" & slv_to_hex(ex_rd)
	severity error;												   
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 111101
    --------------------------------------------------------------------   
	ex_opcode <= "111101";	   
	ex_rs2 <= x"FFFFFF10FFFFFFF00000000100000000";
	ex_rs1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert ex_rd = x"00048001000380013FFF80017FFF0001"
	report "TEST FAIL: 111101, ex_rd =" & slv_to_hex(ex_rd)
	severity error;			 

	--------------------------------------------------------------------
    -- TEST: ex_opcode 111110
    --------------------------------------------------------------------   
	ex_opcode <= "111110";	 
	ex_rs2 <= x"80010004800100037FFF00027FFF0001";
	ex_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert ex_rd = x"0FF88FFD0FFA8FFE0FFA8FFF00000000"
	report "TEST FAIL: 111110, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 111111
    --------------------------------------------------------------------   
	ex_opcode <= "111111";	
	ex_rs2 <= x"80010004800100057FFF00067FFF8F01";
	ex_rs1 <= x"70080007780600037004FFF3F0027001";
	wait for period;
	assert ex_rd = x"8000FFFD800000020FFB00137FFF8000"
	report "TEST FAIL: 111111, ex_rd =" & slv_to_hex(ex_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: ex_opcode 110000
    --------------------------------------------------------------------
	ex_opcode <= "110000";	   
	ex_rs2 <= (others => '-');
	ex_rs1 <= (others => '-');
	wait for period;		 
	assert ex_rd = x"8000FFFD800000020FFB00137FFF8000"
	report "TEST FAIL: 111111, ex_rd =" & slv_to_hex(ex_rd)
	severity error;		  
 ----------------------------------------------------------------
        -- BRH INSTRUCTION TESTS (MMU LEVEL)
 ----------------------------------------------------------------
	----------------------------------------------------------------
    -- BRH TEST 1: BEQ (000), rs2 = rs1 ? branch taken
    ----------------------------------------------------------------
    ex_brch <= '1';
	ex_opcode <= "111000"; -- top bits "11", subtype "111", func "000"
    ex_rs1    <= x"00000000000000000000000000000011";
    ex_rs2    <= x"00000000000000000000000000000011";
    ex_pctrl  <= '1';      -- predicted taken

    wait for PERIOD;

    assert pc_sctrl = '1'
        report "BRH BEQ failed: pc_sctrl should be 1"
        severity error;

    assert flush_ctrl = '0'
        report "BRH BEQ failed: flush_ctrl should be 0 (prediction correct)"
        severity error;

    ----------------------------------------------------------------
    -- BRH TEST 2: BNE (001), rs2 ? rs1 ? branch taken
    ----------------------------------------------------------------
    ex_opcode <= "111001";
    ex_rs1    <= x"00000000000000000000000000000001";
    ex_rs2    <= x"00000000000000000000000000000010";
    ex_pctrl  <= '0';      -- predicted NOT taken

    wait for PERIOD;

    assert pc_sctrl = '1'
        report "BRH BNE failed: pc_sctrl should be 1"
        severity error;

    assert flush_ctrl = '1'
        report "BRH BNE failed: flush expected due to misprediction"
        severity error;

    ----------------------------------------------------------------
    -- BRH TEST 3: BGT (010), rs2 > rs1 ? branch taken
    ----------------------------------------------------------------
    ex_opcode <= "111010";
    ex_rs1    <= x"00000000000000000000000000000001";
    ex_rs2    <= x"00000000000000000000000000000001";
    ex_pctrl  <= '1';

    wait for PERIOD;

    assert pc_sctrl = '0'
        report "BRH BGT failed: pc_sctrl should be 0"
        severity error;

    assert flush_ctrl = '1'
        report "BRH BGT failed: flush expected"
        severity error;

    ----------------------------------------------------------------
    -- BRH TEST 4: BLT (011), rs2 < rs1 ? branch taken
    ----------------------------------------------------------------
    ex_opcode <= "111011";
    ex_rs1    <= x"00000000000000000000000000000005";
    ex_rs2    <= x"00000000000000000000000000000001";
    ex_pctrl  <= '0';

    wait for PERIOD;

    assert pc_sctrl = '1'
        report "BRH BLT failed: pc_sctrl should be 1"
        severity error;

    assert flush_ctrl = '1'
        report "BRH BLT failed: flush expected"
        severity error;

    ----------------------------------------------------------------
    -- BRH TEST 5: JMP (100), unconditional
    ----------------------------------------------------------------
    ex_opcode <= "111100";
    ex_pctrl  <= '1';

    wait for PERIOD;

    assert pc_sctrl = '1'
        report "BRH JMP failed: pc_sctrl should be 1"
        severity error;

    assert flush_ctrl = '0'
        report "BRH JMP failed: no flush expected"
        severity error;
	
    report "TEST COMPLETED: rest of the instruction" severity warning;
	end process;
end test_bench; 