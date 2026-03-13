library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.numeric_var.all;

entity pc is
	port(				  
	clk			: in std_logic;	 
	enable		: in std_logic;
	reset_bar 	: in std_logic;
	
	pred_pc		: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	id_pctrl	: in std_logic;	  
	
	ex_pc 		: in std_logic_vector(COUNTER_LENGTH-1 downto 0); 
	flush_ctrl	: in std_logic;
	
	if_pc	: out std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '-')
	);
end pc;
 
architecture behavior of pc is
	signal pc_reg : unsigned(COUNTER_LENGTH-1 downto 0) := (others => '-');
	signal next_pc : unsigned(COUNTER_LENGTH-1 downto 0); 
	signal start_zero: std_logic := '1';  -- flag for first rising edge
begin  
	
	pc_register : process(clk, reset_bar)
	begin
	    if reset_bar = '0' then
	        pc_reg <= (others => '-');
	    elsif rising_edge(clk) then
	        if enable = '1' then
	            if start_zero = '1' then
	                pc_reg <= (others => '0');   -- output 0 on first rising edge
	                start_zero <= '0';           -- clear the first cycle flag
	            elsif flush_ctrl = '1' then
	                pc_reg <= unsigned(ex_pc) + INCREMENT + INCREMENT;  -- load ex_pc + 2
	            elsif id_pctrl = '1' then
	                pc_reg <= unsigned(pred_pc) + INCREMENT;            -- load pred_pc + 1
	            elsif pc_reg < MAX_COUNT-1 then
	                pc_reg <= pc_reg + INCREMENT; -- normal increment
	            end if;
	        end if;
	    end if;
	end process;
	
	------------------------------------------------------------------
	-- Combinational output: immediate response to control signals
	------------------------------------------------------------------
	pc_output : process(pc_reg, flush_ctrl, ex_pc, id_pctrl, pred_pc)
	begin
	    if flush_ctrl = '1' then
	        if_pc <= std_logic_vector(unsigned(ex_pc) + INCREMENT);
	    elsif id_pctrl = '1' then
	        if_pc <= pred_pc;
	    else
	        if_pc <= std_logic_vector(pc_reg);
	    end if;
	end process;
end architecture;