library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity Multimedia_Processor_Unit is	 
	port (		 	  
	--unit input
	clk 		: in std_logic;	  
	enable		: in std_logic;
	reset_bar 	: in std_logic;
	
	-- Unified BRAM interface (muxed externally between loader and CPU)
	bram_data   : in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
	bram_addr   : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	bram_we     : in std_logic;
	reset_busy  : out std_logic;
	
	reg_pos    : in std_logic_vector(7 downto 0); 
	reg_tog    : in std_logic;
	reg_value  : out std_Logic_vector(15 downto 0);
	reg_seven  : out std_logic_vector(6 downto 0);
	led_ctrl   : out std_logic_vector(3 downto 0)
	);
end Multimedia_Processor_Unit;

architecture structural of Multimedia_Processor_Unit is	 
    -- This will be initialized by the FPGA tool from a .mem/.coe file 

	signal if_instruc 	: std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
	signal id_instruc 	: std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);	
	
	signal id_opcode 	  	: std_logic_vector(OPCODE_LENGTH-1 downto 0);	 
	signal ex_opcode 	  	: std_logic_vector(OPCODE_LENGTH-1 downto 0);	
	
	signal read_sel         : std_logic_vector(2 downto 0);
	signal id_rs3			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal id_rs2			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal id_rs1			: std_logic_vector(REGISTER_LENGTH-1 downto 0);	
	
	signal ex_rs3			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal ex_rs2			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal ex_rs1			: std_logic_vector(REGISTER_LENGTH-1 downto 0);	
	signal ex_rd			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	
	signal fw_rs3			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal fw_rs2			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal fw_rs1			: std_logic_vector(REGISTER_LENGTH-1 downto 0);	
	

	signal id_immed		: std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
	signal ex_immed		: std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
	
	signal id_rs3_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal id_rs2_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal id_rs1_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal id_rd_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	
	signal id_wback		: std_logic;
	
	signal ex_rs3_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_rs2_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_rs1_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_rd_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	
	signal ex_wback		: std_logic;
	
	signal wb_rd		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal wb_rd_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0);		 
	signal wb_wback		: std_logic;
	
    function binary_to_hex(x : std_logic_vector(3 downto 0))
           return std_logic_vector is
           variable seg : std_logic_vector(6 downto 0);
        begin 
            case x is
                when "0000" => seg := "1000000"; -- 0
                when "0001" => seg := "1111001"; -- 1
                when "0010" => seg := "0100100"; -- 2
                when "0011" => seg := "0110000"; -- 3
                when "0100" => seg := "0011001"; -- 4
                when "0101" => seg := "0010010"; -- 5
                when "0110" => seg := "0000010"; -- 6
                when "0111" => seg := "1111000"; -- 7
                when "1000" => seg := "0000000"; -- 8
                when "1001" => seg := "0010000"; -- 9
                when "1010" => seg := "0001000"; -- A
                when "1011" => seg := "0000011"; -- B
                when "1100" => seg := "1000110"; -- C
                when "1101" => seg := "0100001"; -- D
                when "1110" => seg := "0000110"; -- E
                when "1111" => seg := "0001110"; -- F
                when others => seg := "1111111"; -- blank
            end case;
            return seg;
        end;
        
    signal digit_sel   : std_logic := '0';
    
begin		
    process(clk)
        variable ref_rate : unsigned(20 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            ref_rate := ref_rate + 1;
            digit_sel <= ref_rate(1);
        end if;
    end process;
    
    process(digit_sel, reg_pos)
        variable reg_pos_lo : std_logic_vector(3 downto 0);
        variable reg_pos_hi : std_logic_vector(3 downto 0);
    begin
        reg_pos_lo := reg_pos(3 downto 0);
        reg_pos_hi := reg_pos(7 downto 4);
        if digit_sel = '0' then
            led_ctrl <= "1110"; -- enable digit 0
            reg_seven <= binary_to_hex(reg_pos_lo);
        elsif digit_sel = '1' then
            led_ctrl <= "1101"; -- enable digit 1
            reg_seven <= binary_to_hex(reg_pos_hi);
        end if;
    end process;
    
	-- P_C : entity work.pc(behavior)				  
	-- 	port map (	 
	-- 	--control
	-- 	clk 		=> clk,	
	-- 	enable		=> enable,
	-- 	reset_bar 	=> reset_bar,
	-- 	--output
	-- 	pc_count 	=> pc_count
	-- 	); 

	I_FILE : entity work.instruction_file(behavior)
		port map (
			clk         => clk,
			reset_bar   => reset_bar,
			in_addr    =>  bram_addr,
			in_instruc  => bram_data,
			wr_enable   => bram_we,
			out_instruc => if_instruc,
			reset_busy  => reset_busy
		);

    IF_ID : entity work.if_id(behavior)
        port map (	
        --control
        clk			=> clk,	  
        enable		=> enable,
        reset_bar 	=> reset_bar,
        --input
        if_instruc 	=> if_instruc, 
        --output
        id_instruc  => id_instruc);
		
	D_CODE : entity work.decoder(behavior) 
		port map (		
		--input
		instruc  => id_instruc,
		
		--outputs(data)
		opcode	=> id_opcode,
		rs3_ptr	=> id_rs3_ptr,
		rs2_ptr	=> id_rs2_ptr,
		rs1_ptr	=> id_rs1_ptr,
		rd_ptr	=> id_rd_ptr,
		immed	=> id_immed,
		read_sel   	=> read_sel,
		
		--controls(data)
		wback	=> id_wback);	

	R_File : entity work.register_file(behavior)
		port map (
		--inputs(data)	
		clk 		=> clk,
        read_sel 	=> read_sel,
		id_rs3_ptr 	=> id_rs3_ptr, 
		id_rs2_ptr	=> id_rs2_ptr, 
		id_rs1_ptr	=> id_rs1_ptr,
		
		--wback(data)  
		wb_rd		=> wb_rd,	  
		wb_rd_ptr	=> wb_rd_ptr,
		wb_wback	=> wb_wback,	  
		
		--outputs(data)			
		id_rs3	 	=> id_rs3,
		id_rs2		=> id_rs2,
		id_rs1		=> id_rs1,
		reg_pos     => reg_pos,
		reg_tog     => reg_tog,
		reg_value   => reg_value);
		
	ID_EX : entity work.id_ex(behavior)
		port map (	
		--control
		clk 		=> clk,	 
		enable		=> enable,
		reset_bar 	=> reset_bar,
		
		--input
		id_opcode	=> id_opcode,
		
		id_rs3		=> id_rs3,
		id_rs2		=> id_rs2,
		id_rs1 		=> id_rs1,
		id_immed 	=> id_immed,
		
		id_rs3_ptr	=> id_rs3_ptr,			
		id_rs2_ptr	=> id_rs2_ptr,		  
		id_rs1_ptr	=> id_rs1_ptr, 
		id_rd_ptr	=> id_rd_ptr, 
		
		id_wback	=> id_wback,
		
		--output
		ex_opcode	=> ex_opcode,
		
		ex_rs3		=> ex_rs3,
		ex_rs2		=> ex_rs2,
		ex_rs1		=> ex_rs1,
		ex_immed   	=> ex_immed,
		
		ex_rs3_ptr  => ex_rs3_ptr,
		ex_rs2_ptr	=> ex_rs2_ptr,
		ex_rs1_ptr	=> ex_rs1_ptr,
		ex_rd_ptr	=> ex_rd_ptr,
		
		ex_wback	=> ex_wback); 
	
	FOR_WARD : entity work.forward(behavior)
		port map (	   
		--inputs(data)
		ex_rs3 		=> ex_rs3,
		ex_rs2		=> ex_rs2,
		ex_rs1		=> ex_rs1, 
		
		ex_rs3_ptr	=> ex_rs3_ptr,
		ex_rs2_ptr	=> ex_rs2_ptr,
		ex_rs1_ptr	=> ex_rs1_ptr,	
		
	   --forward(data)
		wb_rd		=> wb_rd,
		wb_rd_ptr	=> wb_rd_ptr,
		wb_wback	=> wb_wback,
		
		--outputs(data)
		fw_rs3 		=> fw_rs3,
		fw_rs2		=> fw_rs2,
		fw_rs1		=> fw_rs1); 	
		
	MMU_ALU : entity work.mmu(behavior)
		port map ( 
		--inputs
		opcode		=> ex_opcode,		
		
		fw_rs3 		=> fw_rs3,
		fw_rs2		=> fw_rs2,
		fw_rs1		=> fw_rs1,
		in_immed	=> ex_immed,
		
		--output
		out_rd		=> ex_rd);	
		
	EX_WB : entity work.ex_wb(behavior) 
		port map ( 	 
		--control
		clk 		=> clk,
		enable		=> enable,
		reset_bar 	=> reset_bar,  
		--input 
		ex_rd		=> ex_rd,
		ex_rd_ptr	=> ex_rd_ptr, 
		ex_wback	=> ex_wback,
		
		--output 		
		wb_rd		=> wb_rd,
		wb_rd_ptr	=> wb_rd_ptr,
		wback		=> wb_wback);	
		
    --pc_count_tb    <= pc_count;
--	if_instruc_tb  <= if_instruc;
--	id_instruc_tb  <= id_instruc;
	
--	id_opcode_tb   <= id_opcode;
--	ex_opcode_tb   <= ex_opcode;
	
--	id_rs3_tb      <= id_rs3;
--	id_rs2_tb      <= id_rs2;
--	id_rs1_tb      <= id_rs1;
	
--	ex_rs3_tb      <= ex_rs3;
--	ex_rs2_tb      <= ex_rs2;
--	ex_rs1_tb      <= ex_rs1;
--	ex_rd_tb       <= ex_rd;
	
--	id_immed_tb    <= id_immed;
--	ex_immed_tb    <= ex_immed;
	
--	id_rs3_ptr_tb  <= id_rs3_ptr;
--	id_rs2_ptr_tb  <= id_rs2_ptr;
--	id_rs1_ptr_tb  <= id_rs1_ptr;
--	id_rd_ptr_tb   <= id_rd_ptr;
	
--	id_wback_tb    <= id_wback;
	
--	ex_rs3_ptr_tb  <= ex_rs3_ptr;
--	ex_rs2_ptr_tb  <= ex_rs2_ptr;
--	ex_rs1_ptr_tb  <= ex_rs1_ptr;
--	ex_rd_ptr_tb   <= ex_rd_ptr;
	
--	ex_wback_tb    <= ex_wback;
	
--	wb_rd_tb       <= wb_rd;
--	wb_rd_ptr_tb   <= wb_rd_ptr;
--	wb_wback_tb    <= wb_wback;	

end architecture;
