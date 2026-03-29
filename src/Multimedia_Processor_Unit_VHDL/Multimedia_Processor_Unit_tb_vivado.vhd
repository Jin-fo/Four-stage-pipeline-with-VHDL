library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.numeric_var.all;

entity Multimedia_Processor_Unit_tb is
end Multimedia_Processor_Unit_tb;

architecture test_bench of Multimedia_Processor_Unit_tb is

    ------------------------------------------------------------------
    -- DUT signals
    ------------------------------------------------------------------
    signal clk       : std_logic := '0';
    signal enable    : std_logic := '0';
    signal reset_bar : std_logic := '0';

    signal in_file  : std_logic_vector(INSTRUCTION_SIZE-1 downto 0) := (others => '0');
    signal out_file : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');

    signal pc_count   : std_logic_vector(COUNTER_LENGTH-1 downto 0);

begin

    ------------------------------------------------------------------
    -- DUT instantiation
    ------------------------------------------------------------------
    UUT : entity work.Multimedia_Processor_Unit
        port map(
            clk       => clk,
            enable    => enable,
            reset_bar => reset_bar,

            in_file   => in_file,

            out_file => out_file,

            pc_count_tb   => pc_count,
            if_instruc_tb => open,
            id_instruc_tb => open,

            id_opcode_tb   => open,
            ex_opcode_tb   => open,

            id_rs3_tb      => open,
            id_rs2_tb      => open,
            id_rs1_tb      => open,

            ex_rs3_tb      => open,
            ex_rs2_tb      => open,
            ex_rs1_tb      => open,
            ex_rd_tb       => open,

            id_immed_tb    => open,
            ex_immed_tb    => open,

            id_rs3_ptr_tb  => open,
            id_rs2_ptr_tb  => open,
            id_rs1_ptr_tb  => open,
            id_rd_ptr_tb   => open,

            id_wback_tb    => open,

            ex_rs3_ptr_tb  => open,
            ex_rs2_ptr_tb  => open,
            ex_rs1_ptr_tb  => open,
            ex_rd_ptr_tb   => open,

            ex_wback_tb    => open,

            wb_rd_tb       => open,
            wb_rd_ptr_tb   => open,
            wb_wback_tb    => open
        );

    ------------------------------------------------------------------
    -- Clock generation
    ------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for PERIOD/2;
            clk <= '1';
            wait for PERIOD/2;
        end loop;
    end process;

    ------------------------------------------------------------------
    -- Reset + Enable
    ------------------------------------------------------------------
    init_process : process
    begin
        enable    <= '0';
        reset_bar <= '0';

        wait for PERIOD * 2;

        reset_bar <= '1';
        enable    <= '1';

        wait;
    end process;

    ------------------------------------------------------------------
    -- Load instruction memory from .mem (hex)
    ------------------------------------------------------------------
    load_mem : process
        file mem_file : text open read_mode is "instruction_file.mem";
        variable L     : line;
        variable word  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
        variable mem   : std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
        variable idx   : integer := 0;
    begin
        mem := (others => '0');

        while not endfile(mem_file) loop
            readline(mem_file, L);

            -- Read hex instruction
            read(L, word);

            mem(idx + INSTRUCTION_LENGTH - 1 downto idx) := word;
            idx := idx + INSTRUCTION_LENGTH;
        end loop;

        in_file <= mem;
        wait;
    end process;

    dump_mem : process
        file mem_out : text;
        variable L   : line;
        variable reg : std_logic_vector(REGISTER_SIZE-1 downto 0);
    begin
        loop
            wait until rising_edge(clk);
    
            -- Reopen in write_mode every cycle to clear previous contents
            file_open(mem_out, "register_file.mem", write_mode);
    
            reg := out_file;
            for i in 0 to (REGISTER_SIZE/REGISTER_LENGTH)-1 loop
                L := new string'("");
                write(L, reg((i+1)*REGISTER_LENGTH-1 downto i*REGISTER_LENGTH));
                writeline(mem_out, L);
            end loop;
    
            file_close(mem_out);  -- flush and close so contents are visible on disk
    
        end loop;
    end process;

end architecture;