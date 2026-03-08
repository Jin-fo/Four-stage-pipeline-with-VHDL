library ieee;
use ieee.std_logic_1164.all;
use work.numeric_var.all;
use work.all;

entity Multimedia_Processor_Unit is	 
	port (		 	  
	--unit input
	clk 		: in std_logic;	  
	enable		: in std_logic;
	reset_bar 	: in std_logic;
	
	in_file     : in std_logic_vector(FILE_SIZE-1 downto 0);   
	--unit output  
	out_buffer 	: out std_logic_vector(BUFFER_SIZE-1 downto 0);
	out_file	: out std_logic_vector(REGISTER_SIZE-1 downto 0);  
	
    -- ======================
    -- IF stage (debug)
    -- ====================== 
    if_pc_i      : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    if_instruc_i : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    pred_pc_i    : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    id_pctrl_i   : out std_logic;

    iff_target_i : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    ifd_target_i : out std_logic_vector(COUNTER_LENGTH-1 downto 0);

    -- ======================
    -- IF/ID stage (debug)
    -- ======================
    id_pc_i       : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    id_instruc_i : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    -- ======================
    -- Decode stage (debug)
    -- ======================
    id_opcode_i  : out std_logic_vector(OPCODE_LENGTH-1 downto 0);

    id_rs3_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rs2_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rs1_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rd_ptr_i  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    id_immed_i   : out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
    read_sel_i   : out std_logic_vector(2 downto 0);

    id_wback_i   : out std_logic;
    id_branch_i  : out std_logic;
    id_jump_i    : out std_logic;

    -- ======================
    -- Branch Predictor (debug)
    -- ======================
    idw_target_i : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    idw_tctrl_i  : out std_logic;

    id_state_i   : out std_logic_vector(STATE_LENGTH-1 downto 0);
    id_brch_i     : out std_logic;

    -- ======================
    -- Register File (debug)
    -- ======================
    id_rs3_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    id_rs2_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    id_rs1_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);

    -- ======================
    -- ID/EX pipeline (debug)
    -- ======================
    ex_pc_i    	 : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    ex_opcode_i  : out std_logic_vector(OPCODE_LENGTH-1 downto 0);

    ex_rs3_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_rs2_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_rs1_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_immed_i   : out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    ex_rd_ptr_i  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rs3_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rs2_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rs1_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    ex_state_i   : out std_logic_vector(STATE_LENGTH-1 downto 0);
    ex_wback_i   : out std_logic;
    ex_pctrl_i   : out std_logic;
    ex_brch_i     : out std_logic;

    -- ======================
    -- Execute / Control (debug)
    -- ======================
    ex_rd_i      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);

    pc_sctrl_i   : out std_logic;
    flush_ctrl_i : out std_logic;

    -- ======================
    -- Write-back FSM (debug)
    -- ======================
    exw_state_i  : out std_logic_vector(1 downto 0);
    exw_sctrl_i  : out std_logic;

    -- ======================
    -- Write Back stage (debug)
    -- ======================
    wb_rd_i      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    wb_rd_ptr_i  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    wb_wback_i   : out std_logic
	);
end Multimedia_Processor_Unit;

architecture structural of Multimedia_Processor_Unit is	 
   	-- ======================
    -- Global / IF stage
    -- ====================== 
    signal if_pc        : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal if_instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    signal pred_pc     : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_pctrl    : std_logic;

    signal iff_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ifd_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);

    -- ======================
    -- IF/ID stage
    -- ======================
    signal id_pc        : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    -- ======================
    -- Decode stage
    -- ======================
    signal id_opcode   : std_logic_vector(OPCODE_LENGTH-1 downto 0);

    signal id_rs3_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rs2_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rs1_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rd_ptr   : std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    signal id_immed    : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    signal read_sel    : std_logic_vector(2 downto 0);

    signal id_wback    : std_logic;
    signal id_branch   : std_logic;
    signal id_jump     : std_logic;

    -- ======================
    -- Branch Predictor
    -- ======================
    signal idw_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal idw_tctrl   : std_logic;

    signal id_state    : std_logic_vector(STATE_LENGTH-1 downto 0);
    signal id_brch      : std_logic;

    -- ======================
    -- Register File
    -- ======================
    signal id_rs3      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal id_rs2      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal id_rs1      : std_logic_vector(REGISTER_LENGTH-1 downto 0);

    -- ======================
    -- ID/EX pipeline
    -- ======================
    signal ex_pc       : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ex_opcode  : std_logic_vector(OPCODE_LENGTH-1 downto 0);

    signal ex_rs3     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_rs2     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_rs1     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_immed   : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    signal ex_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rs3_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rs2_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rs1_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    signal ex_state   : std_logic_vector(STATE_LENGTH-1 downto 0);
    signal ex_wback   : std_logic;
    signal ex_pctrl   : std_logic;
    signal ex_brch     : std_logic;

    -- ======================
    -- Execute / MMU / ALU
    -- ======================
    signal ex_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);

    signal pc_sctrl   : std_logic;
    signal flush_ctrl : std_logic;

    -- ======================
    -- FSM write-back signals
    -- ======================	   
    signal exw_state  : std_logic_vector(1 downto 0);
    signal exw_sctrl  : std_logic;

    -- ======================
    -- Write Back stage
    -- ======================
    signal wb_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal wb_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal wb_wback   : std_logic; 	

begin				 
	P_C : entity work.pc(behavior)				  
		port map (	 
		--setup
		clk 		=> clk,	
		enable		=> enable,
		reset_bar 	=> reset_bar,
		
		--input
		pred_pc		=> pred_pc,
		id_pctrl	=> id_pctrl,
		ex_pc		=> ex_pc,
		flush_ctrl 	=> flush_ctrl,
		
		--output
		if_pc 		=> if_pc); 
		
	T_BUFF : entity work.target_buffer(behavior)
		port map ( 	
		--input
		if_pc		=> if_pc,	
		id_tctrl	=> idw_tctrl,
		id_pc  	  	=> id_pc,
		id_target 	=> idw_target,
		--output   
		iff_target 	=> iff_target,
		out_buffer	=> out_buffer);

	I_File : entity work.instruction_file(behavior)		
		port map (	  
		--input
		if_pc 		=> if_pc,
		in_file		=> in_file,	
		reset_bar	=> reset_bar, 
		
		--output
		if_instruc 	=> if_instruc);
		
	IF_ID : entity work.if_id(behavior)
		port map (	
		--setup
		clk			=> clk,	  
		enable		=> enable,
		reset_bar 	=> reset_bar,
		flush_ctrl  => flush_ctrl,
		
		--input				 
		if_pc		=> if_pc,
		if_instruc 	=> if_instruc,
		iff_target 	=> iff_target,
		
		--output	
		id_pc		=> id_pc,
		id_instruc  => id_instruc,
		ifd_target	=> ifd_target);
		
	D_CODE : entity work.decoder(behavior) 
		port map (		
		--input
		id_instruc  => id_instruc,
		
		--outputs
		id_opcode	=> id_opcode,
		id_rs3_ptr	=> id_rs3_ptr,
		id_rs2_ptr	=> id_rs2_ptr,
		id_rs1_ptr	=> id_rs1_ptr,
		id_rd_ptr	=> id_rd_ptr,
		id_immed	=> id_immed,
		
		read_sel   	=> read_sel,
		
		--controls
		id_wback	=> id_wback,
		id_branch	=> id_branch,
		id_jump		=> id_jump);
	
	B_PRED : entity work.predictor(behavior)
		port map (
		--input
		id_pc		=> id_pc,
		id_immed	=> id_immed,
		ifd_target  => ifd_target,
		id_jump		=> id_jump,
		id_branch   => id_branch,
		ex_pc		=> ex_pc,
		exw_state	=> exw_state,  
		exw_sctrl	=> exw_sctrl, 
		
		--output
		id_target	=> idw_target,
		id_tctrl	=> idw_tctrl,
		
		pred_pc		=> pred_pc,	  
		id_pctrl	=> id_pctrl,
		id_state	=> id_state,
		id_brch		=> id_brch);

	R_File : entity work.register_file(behavior)
		port map (
		--input	   
		read_sel 	=> read_sel,
		
		id_rs3_ptr 	=> id_rs3_ptr, 
		id_rs2_ptr	=> id_rs2_ptr, 
		id_rs1_ptr	=> id_rs1_ptr,
		
		--write back 
		wb_rd		=> wb_rd,	  
		wb_rd_ptr	=> wb_rd_ptr,
		wb_wback	=> wb_wback,	  
		
		--output			
		out_file 	=> out_file,
		id_rs3	 	=> id_rs3,
		id_rs2		=> id_rs2,
		id_rs1		=> id_rs1);
		
	ID_EX : entity work.id_ex(behavior)
		port map (	
		--setup
		clk 		=> clk,	 
		enable		=> enable,
		reset_bar 	=> reset_bar,
		
		--input
		id_pc		=> id_pc,
		id_opcode	=> id_opcode,
		
		id_rs3		=> id_rs3,
		id_rs2		=> id_rs2,
		id_rs1 		=> id_rs1,
		id_immed 	=> id_immed,
		
		id_rd_ptr	=> id_rd_ptr,
		id_rs3_ptr	=> id_rs3_ptr,			
		id_rs2_ptr	=> id_rs2_ptr,		  
		id_rs1_ptr	=> id_rs1_ptr, 
		id_state	=> id_state,
		
		id_wback	=> id_wback,
		id_pctrl	=> id_pctrl,
		id_brch		=> id_brch,
		
		--output 
		ex_pc		=> ex_pc,
		ex_opcode	=> ex_opcode,
		
		ex_rs3		=> ex_rs3,
		ex_rs2		=> ex_rs2,
		ex_rs1		=> ex_rs1,
		ex_immed   	=> ex_immed,
		
		ex_rd_ptr	=> ex_rd_ptr,
		ex_rs3_ptr  => ex_rs3_ptr,
		ex_rs2_ptr	=> ex_rs2_ptr,
		ex_rs1_ptr	=> ex_rs1_ptr,
		ex_state	=> ex_state,
		
		ex_wback	=> ex_wback,
		ex_pctrl	=> ex_pctrl,
		ex_brch		=> ex_brch); 
		
	MMU_ALU : entity work.mmu(behavior)
		port map ( 
		--inputs
		ex_opcode	=> ex_opcode,		
		
		ex_rs3 		=> ex_rs3,
		ex_rs2		=> ex_rs2,
		ex_rs1		=> ex_rs1,
		ex_immed	=> ex_immed,
		
		ex_rs3_ptr	=> ex_rs3_ptr,
		ex_rs2_ptr	=> ex_rs2_ptr,
		ex_rs1_ptr	=> ex_rs1_ptr,
		--write back
		wb_rd		=> wb_rd,
		wb_rd_ptr	=> wb_rd_ptr,
		wb_wback	=> wb_wback,
		
		--branch
		ex_pctrl	=> ex_pctrl,
		
		--output
		pc_sctrl	=> pc_sctrl,
		ex_brch		=> ex_brch,
		flush_ctrl 	=> flush_ctrl,
		ex_rd		=> ex_rd);
		
	S_FSM : entity work.state_fsm(behavior)
		port map (
		--input
		clk			=> clk,
		ex_brch		=> ex_brch,
		ex_state  	=> ex_state,
		
		--output
		pc_sctrl	=> pc_sctrl,		
		exw_state   => exw_state,
		exw_sctrl	=> exw_sctrl);
		
	EX_ID : entity work.ex_wb(behavior) 
		port map ( 	 
		--setup 
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
		wb_wback	=> wb_wback);		
    -- ======================
    -- Debug signal exposure
    -- ======================  
	
	if_pc_i       	<= if_pc;
	if_instruc_i	<= if_instruc;
	
	pred_pc_i     <= pred_pc;
	id_pctrl_i    <= id_pctrl;
	
	iff_target_i  <= iff_target;
	ifd_target_i  <= ifd_target;
	
	id_pc_i       <= id_pc;
	id_instruc_i <= id_instruc;
	
	id_opcode_i  <= id_opcode;
	
	id_rs3_ptr_i <= id_rs3_ptr;
	id_rs2_ptr_i <= id_rs2_ptr;
	id_rs1_ptr_i <= id_rs1_ptr;
	id_rd_ptr_i  <= id_rd_ptr;
	
	id_immed_i   <= id_immed;
	read_sel_i   <= read_sel;
	
	id_wback_i   <= id_wback;
	id_branch_i  <= id_branch;
	id_jump_i   <= id_jump;
	
	idw_target_i <= idw_target;
	idw_tctrl_i  <= idw_tctrl;
	
	id_state_i   <= id_state;
	id_brch_i     <= id_brch;
	
	id_rs3_i     <= id_rs3;
	id_rs2_i     <= id_rs2;
	id_rs1_i     <= id_rs1;
	
	ex_pc_i      <= ex_pc;
	ex_opcode_i <= ex_opcode;
	
	ex_rs3_i    <= ex_rs3;
	ex_rs2_i    <= ex_rs2;
	ex_rs1_i    <= ex_rs1;
	ex_immed_i  <= ex_immed;
	
	ex_rd_ptr_i <= ex_rd_ptr;
	ex_rs3_ptr_i <= ex_rs3_ptr;
	ex_rs2_ptr_i <= ex_rs2_ptr;
	ex_rs1_ptr_i <= ex_rs1_ptr;
	
	ex_state_i  <= ex_state;
	ex_wback_i  <= ex_wback;
	ex_pctrl_i  <= ex_pctrl;
	ex_brch_i    <= ex_brch;
	
	ex_rd_i     <= ex_rd;
	
	pc_sctrl_i  <= pc_sctrl;
	flush_ctrl_i<= flush_ctrl;
	
	exw_state_i <= exw_state;
	exw_sctrl_i <= exw_sctrl;
	
	wb_rd_i     <= wb_rd;
	wb_rd_ptr_i <= wb_rd_ptr;
	wb_wback_i  <= wb_wback;
end architecture;
