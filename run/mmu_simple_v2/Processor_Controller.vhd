library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity Processor_Controller is
    port (
        clk        : in  std_logic;
        rst_bar    : in  std_logic;
        enable     : in  std_logic;

        -- UART input
        rx         : in std_logic;
        loaded     : out std_logic;
        
        -- FSM CTRL 
        uart        : out std_logic;
        cpu         : out std_logic;

        -- debug
        reg_pos    : in  std_logic_vector(7 downto 0);
        reg_tog    : in  std_logic;
        reg_value  : out std_logic_vector(15 downto 0)
    );
end entity;

architecture structural of Processor_Controller is

    --------------------------------------------------------------------
    -- FSM CONTROL SIGNALS
    --------------------------------------------------------------------
    signal uart_en    : std_logic;
    signal cpu_en     : std_logic;
    signal load_done  : std_logic;
    
    signal uart_en_r    : std_logic;
    signal cpu_en_r     : std_logic;
    signal load_done_r  : std_logic;
    
    signal reset_busy : std_logic;
    
    --------------------------------------------------------------------
    -- USART OUTPUT SIGNALS
    --------------------------------------------------------------------
    signal  rx_data   : std_logic_vector(7 downto 0);
    signal rx_ready   : std_logic;
    --------------------------------------------------------------------
    -- ACCUMULATOR → CPU BRAM INTERFACE
    --------------------------------------------------------------------
    signal instr_addr : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal instr_data : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
    signal wr_enable  : std_logic;
    
begin

    ctrl_reg : process(clk)
    begin
        if rising_edge(clk) then
            load_done_r <= load_done;
            uart_en_r <= uart_en;
            cpu_en_r  <= cpu_en;
        end if;
    end process;
    
    loaded <= load_done;
    uart   <= uart_en;
    cpu    <= cpu_en;

    --------------------------------------------------------------------
    -- 1. FSM CONTROLLER
    --------------------------------------------------------------------
    CNTRL_FSM : entity work.control_FSM(behavior)
    port map (
        clk       => clk,
        rst_bar   => rst_bar,
        enable    => enable,
        load_done => load_done_r,
        rst_busy => reset_busy,

        uart_en   => uart_en,
        cpu_en    => cpu_en
    );
    
    USART : entity work.USART_Unit(structural)
    port map ( 
        clk       => clk,
        rst_bar   => rst_bar,
        enable    => uart_en_r,
        
        rx  => rx,

        rx_data     => rx_data,
        rx_ready    => rx_ready
    );


    --------------------------------------------------------------------
    -- 2. ACCUMULATOR (UART → 32-bit instruction stream)
    --------------------------------------------------------------------
    INSTRUC_LDR : entity work.instruction_loader(behavior)
    port map (
        clk        => clk,
        rst_bar  => rst_bar,

        rx_data    => rx_data,
        rx_ready   => rx_ready,
        bram_addr  => instr_addr,
        bram_data  => instr_data,
        bram_we    => wr_enable,
        
        load_done  => load_done
    );

    --------------------------------------------------------------------
    -- 3. CPU CORE (INCLUDES BRAM INSIDE)
    --------------------------------------------------------------------
    MMU_CPU : entity work.Multimedia_Processor_Unit(structural)
    port map (
        clk        => clk,
        reset_bar  => rst_bar,
        enable     => cpu_en_r,

        -- bootloader interface
        in_instruct => instr_data,
        addr_count => instr_addr,
        wr_enable  => wr_enable,

        -- runtime outputs
        reg_pos    => reg_pos,
        reg_tog    => reg_tog,
        reg_value  => reg_value,

        reset_busy => reset_busy
    );

end architecture;