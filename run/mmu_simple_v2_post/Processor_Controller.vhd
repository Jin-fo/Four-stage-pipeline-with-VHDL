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
        

        -- debug
        reg_pos    : in  std_logic_vector(7 downto 0);
        reg_tog    : in  std_logic;
        reg_value  : out std_logic_vector(15 downto 0);

        reset_busy : out std_logic
    );
end entity;

architecture structural of Processor_Controller is

    --------------------------------------------------------------------
    -- FSM CONTROL SIGNALS
    --------------------------------------------------------------------
    signal cpu_reset  : std_logic;
    signal uart_en    : std_logic;
    signal cpu_en     : std_logic;
    signal load_done  : std_logic;
    
    --------------------------------------------------------------------
    -- USART OUTPUT SIGNALS
    --------------------------------------------------------------------
    signal  rx_data   : std_logic_vector(7 downto 0);
    signal rx_ready   : std_logic;
    --------------------------------------------------------------------
    -- ACCUMULATOR → CPU BRAM INTERFACE
    --------------------------------------------------------------------
    signal instr_data : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
    signal wr_enable  : std_logic;

begin

    --------------------------------------------------------------------
    -- 1. FSM CONTROLLER
    --------------------------------------------------------------------
    CNTRL_FSM : entity work.control_FSM(behavior)
    port map (
        clk       => clk,
        rst_bar   => rst_bar,
        enable    => enable,
        load_done => load_done,

        cpu_reset => cpu_reset,
        uart_en   => uart_en,
        cpu_en    => cpu_en
    );
    
    USART : entity work.USART_Unit(structural)
    port map ( 
        clk       => clk,
        reset_bar   => rst_bar,
        enable    => enable,
        
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
        reset_bar  => cpu_reset,

        rx_data    => rx_data,
        rx_ready   => rx_ready,

        data_out   => instr_data,
        valid      => wr_enable
    );

    --------------------------------------------------------------------
    -- 3. CPU CORE (INCLUDES BRAM INSIDE)
    --------------------------------------------------------------------
    MMU_CPU : entity work.Multimedia_Processor_Unit(structural)
    port map (
        clk        => clk,
        reset_bar  => cpu_reset,
        enable     => cpu_en,

        -- bootloader interface
        in_instruc => instr_data,
        wr_enable  => wr_enable,

        -- runtime outputs
        reg_pos    => reg_pos,
        reg_tog    => reg_tog,
        reg_value  => reg_value,

        reset_busy => reset_busy,

        -- internal PC / execution (inside CPU)
        load_done  => load_done
    );

end architecture;