library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.numeric_var.all;

entity instruction_file is
    Port ( 
        clk : in std_logic;
        reset_bar : in std_logic;
        
        pc_count : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
        addr_count : in std_logic_vector (COUNTER_LENGTH-1 downto 0);
        
        in_instruc : in std_logic_vector (INSTRUCTION_LENGTH-1 downto 0);
        wr_enable : in std_logic;
        
        out_instruc : out std_logic_vector (INSTRUCTION_LENGTH-1 downto 0);
        reset_busy   : out std_logic
    );
end entity;

architecture behavior of instruction_file is
    signal address_sig : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal write_en    : std_logic_vector(0 downto 0);
    signal reset_sig   : std_logic;
begin

    reset_sig <= not reset_bar;
    
    write : process(clk, reset_bar, addr_count, pc_count, in_instruc, wr_enable) is
    begin 
        if wr_enable = '1' then
            address_sig <= addr_count;
        else  
            address_sig <= pc_count;
        end if;
        
        write_en(0) <= wr_enable;
    end process;
    
    BLK_MEM : entity work.blk_mem_gen_0(blk_mem_gen_0_arch) -- instruction_file
        port map (
            clka  => clk,
            wea => write_en,
            addra => address_sig,
            dina  => in_instruc,
            douta => out_instruc,
            rsta  => reset_sig,
            rsta_busy => reset_busy
        );

end architecture;
