library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

use work.numeric_var.all;
use work.all;

entity Multimedia_Processor_Unit_tb is
end Multimedia_Processor_Unit_tb;

architecture test_bench of Multimedia_Processor_Unit_tb is

    -- ======================
    -- DUT interface
    -- ======================
    signal clk       : std_logic := '0';
    signal enable    : std_logic := '0';
    signal reset_bar : std_logic := '0';

    signal in_file   : std_logic_vector(FILE_SIZE-1 downto 0) := (others => '0');
        -- Debug signals
    signal out_buffer : std_logic_vector(BUFFER_SIZE-1 downto 0) := (others => '0'); 
	signal out_file  : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');

    constant PERIOD : time := 10 ns;

    -- ======================
    -- IF stage (debug)
    -- ======================
    signal if_pc        : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal if_instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    signal pred_pc     : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_pctrl    : std_logic;

    signal iff_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ifd_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);

    -- ======================
    -- IF / ID
    -- ======================
    signal id_pc        : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    -- ======================
    -- Decode
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
    -- ID / EX
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
    -- Execute / Control
    -- ======================
    signal ex_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal pc_sctrl   : std_logic;
    signal flush_ctrl : std_logic;

    -- ======================
    -- FSM write-back
    -- ======================
    signal exw_state  : std_logic_vector(1 downto 0);
    signal exw_sctrl  : std_logic;

    -- ======================
    -- Write Back
    -- ======================
    signal wb_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal wb_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal wb_wback   : std_logic;
    
    -- ======================
    -- Helper function
    -- ======================
    function slv_to_str(v : std_logic_vector) return string is
        variable s : string(1 to v'length);
    begin
        for i in v'range loop
            case v(i) is
                when '0' => s(v'length - i) := '0';
                when '1' => s(v'length - i) := '1';
                when others => s(v'length - i) := 'X';
            end case;
        end loop;
        return s;
    end function;

begin

    -- ======================
    -- DUT
    -- ======================
    UUT : entity work.Multimedia_Processor_Unit
        port map (
            clk       => clk,
            enable    => enable,
            reset_bar => reset_bar,
            in_file   => in_file,
			out_buffer => out_buffer,
            out_file  => out_file,

            -- IF
            if_pc_i        => if_pc,
            if_instruc_i  => if_instruc,
            pred_pc_i     => pred_pc,
            id_pctrl_i    => id_pctrl,
            iff_target_i  => iff_target,
            ifd_target_i  => ifd_target,

            -- IF / ID
            id_pc_i       => id_pc,
            id_instruc_i => id_instruc,

            -- Decode
            id_opcode_i  => id_opcode,
            id_rs3_ptr_i => id_rs3_ptr,
            id_rs2_ptr_i => id_rs2_ptr,
            id_rs1_ptr_i => id_rs1_ptr,
            id_rd_ptr_i  => id_rd_ptr,
            id_immed_i   => id_immed,
            read_sel_i   => read_sel,
            id_wback_i   => id_wback,
            id_branch_i  => id_branch,
            id_jump_i    => id_jump,

            -- Predictor
            idw_target_i => idw_target,
            idw_tctrl_i  => idw_tctrl,
            id_state_i   => id_state,
            id_brch_i     => id_brch,

            -- Reg file
            id_rs3_i     => id_rs3,
            id_rs2_i     => id_rs2,
            id_rs1_i     => id_rs1,

            -- ID / EX
            ex_pc_i      => ex_pc,
            ex_opcode_i => ex_opcode,
            ex_rs3_i    => ex_rs3,
            ex_rs2_i    => ex_rs2,
            ex_rs1_i    => ex_rs1,
            ex_immed_i  => ex_immed,
            ex_rd_ptr_i => ex_rd_ptr,
            ex_rs3_ptr_i=> ex_rs3_ptr,
            ex_rs2_ptr_i=> ex_rs2_ptr,
            ex_rs1_ptr_i=> ex_rs1_ptr,
            ex_state_i  => ex_state,
            ex_wback_i  => ex_wback,
            ex_pctrl_i  => ex_pctrl,
            ex_brch_i    => ex_brch,

            -- Execute
            ex_rd_i     => ex_rd,
            pc_sctrl_i  => pc_sctrl,
            flush_ctrl_i=> flush_ctrl,

            -- WB FSM
            exw_state_i => exw_state,
            exw_sctrl_i => exw_sctrl,

            -- Write back
            wb_rd_i     => wb_rd,
            wb_rd_ptr_i => wb_rd_ptr,
            wb_wback_i  => wb_wback
        );

    -- ======================
    -- Clock
    -- ======================
    clk_process : process
    begin
        clk <= '0'; wait for PERIOD/2;
        clk <= '1'; wait for PERIOD/2;
    end process;
	
    -- ======================
    -- Reset / Enable
    -- ======================
    init : process
    begin
        enable    <= '0';
        reset_bar <= '0';
        wait for PERIOD/2;

        reset_bar <= '1';
        enable    <= '1';
        wait;
    end process;

    -- ======================
    -- Instruction loader
    -- ======================
    Load_Instructions : process
        file f_in  : text open read_mode is "instruction_file.txt";
        variable L     : line;
        variable str   : string(1 to INSTRUCTION_LENGTH);
        variable chunk : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
        variable mem   : std_logic_vector(FILE_SIZE-1 downto 0);
        variable idx   : integer := 0;
    begin
        mem := (others => '0');

        while not endfile(f_in) loop
            readline(f_in, L);
            read(L, str);

            for i in 1 to INSTRUCTION_LENGTH loop
                if str(i) = '0' then
                    chunk(INSTRUCTION_LENGTH - i) := '0';
                elsif str(i) = '1' then
                    chunk(INSTRUCTION_LENGTH - i) := '1';
                else
                    chunk(INSTRUCTION_LENGTH - i) := 'X';
                end if;
            end loop;

            mem(idx + INSTRUCTION_LENGTH - 1 downto idx) := chunk;
            idx := idx + INSTRUCTION_LENGTH;
        end loop;

        in_file <= mem;
        wait;
    end process;

    -- ======================
    -- Register file dump
    -- ======================
    Write_Back : process
        file f_out : text;
        variable L       : line;
        variable regword : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    begin
        file_open(f_out, "src/internal_result/register_file.txt", write_mode);
        file_close(f_out);

        wait until rising_edge(clk);

        while true loop			
			wait until rising_edge(clk);
            file_open(f_out, "src/internal_result/register_file.txt", write_mode);

            for i in 0 to (REGISTER_SIZE / REGISTER_LENGTH) - 1 loop
                regword :=
                    out_file(((i+1)*REGISTER_LENGTH)-1 downto i*REGISTER_LENGTH);
                write(L, slv_to_str(regword));
                writeline(f_out, L);
            end loop;

            file_close(f_out);
        end loop;
    end process;
	
	write_buffer_proc : process
        variable line_buf : line;
        variable bit_index : integer := 0;
        variable valid_bit : std_logic;
        variable target_value : std_logic_vector(COUNTER_LENGTH-1 downto 0);
        file output_file : text;
    begin 
		file_open(output_file, "src/internal_result/buffer_file.txt", write_mode);
        file_close(output_file);

        wait until rising_edge(clk);
		
		while true loop
			wait until rising_edge(clk);
			file_open(output_file, "src/internal_result/buffer_file.txt", write_mode);
	        bit_index := 0;
	        for i in 0 to (2**(COUNTER_LENGTH)-1) loop
	            valid_bit := out_buffer(bit_index);
	            target_value := out_buffer(bit_index + COUNTER_LENGTH downto bit_index + 1);
	            
	            write(line_buf, std_logic'image(valid_bit)(2 to 3));
	            write(line_buf, slv_to_str(target_value));
	            
	            writeline(output_file, line_buf);
	            bit_index := bit_index + (1 + COUNTER_LENGTH);
	        end loop;
        
        	file_close(output_file);
		end loop;
        
    end process write_buffer_proc;
	
end architecture;
