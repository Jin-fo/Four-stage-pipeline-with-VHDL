library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity pc_select is
    port(
        -- inputs
        pc_reg     : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);

        pred_pc    : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        id_pctrl   : in  std_logic;

        brch_pc    : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        flush_ctrl : in  std_logic;

        -- outputs
        next_pc    : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
        if_pc      : out std_logic_vector(COUNTER_LENGTH-1 downto 0)
    );
end entity;

architecture behavior of pc_select is
begin

	process(pc_reg, pred_pc, id_pctrl, brch_pc, flush_ctrl)
    	variable var_next : unsigned(COUNTER_LENGTH-1 downto 0);
	begin
	    -- priority: flush > predict > sequential
	    if flush_ctrl = '1' then
	        var_next := unsigned(brch_pc) + INCREMENT;
	        if_pc    <= brch_pc;
	
	    elsif id_pctrl = '1' then
	        var_next := unsigned(pred_pc) + INCREMENT;
	        if_pc    <= pred_pc;  
		else 
			-- default: sequential
	    	var_next := unsigned(pc_reg) + INCREMENT;
	    	if_pc    <= pc_reg;
	    end if;
	
	    next_pc <= std_logic_vector(var_next);
	
	end process;

end architecture;