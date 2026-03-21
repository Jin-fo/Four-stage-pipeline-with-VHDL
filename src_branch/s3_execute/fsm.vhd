library ieee;
use ieee.std_logic_1164.all;
use work.numeric_var.all;

entity state_fsm is
    port (
		-- inputs 
		clk		  : in std_logic;
        ex_bctrl  : in  std_logic;
        fw_state   : in  std_logic_vector(1 downto 0);
        pc_sctrl   : in  std_logic;

        -- outputs
        fsm_state  : out std_logic_vector(1 downto 0);
        fsm_sctrl  : out std_logic
    );
end entity state_fsm;

architecture behavior of state_fsm is
begin

main : process(clk)
    variable var_state : std_logic_vector(1 downto 0);
    variable var_sctrl : std_logic;
begin			
    var_sctrl := '0';
		

		if ex_bctrl = '1' then  
        case fw_state is

            when "00" =>
                if pc_sctrl = '1' then
                    var_state := "01";
                    var_sctrl := '1';
                end if;

            when "01" =>
                var_sctrl := '1';
                if pc_sctrl = '1' then
                    var_state := "11";
                else
                    var_state := "00";
                end if;

            when "11" =>
                if pc_sctrl = '0' then
                    var_state := "01";
                    var_sctrl := '1';
                end if;

            when "10" =>
                var_sctrl := '1';
                if pc_sctrl = '1' then
                    var_state := "11";
                else
                    var_state := "00";
                end if;

            when others =>
                var_sctrl := '0';
        end case; 			   
    end if;

    -- always drive outputs
    fsm_state <= var_state;
    fsm_sctrl <= var_sctrl;

end process;

end architecture;