library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity state_fsm is
    port (
        clk     	: in  std_logic;
        ex_brch  	: in  std_logic;
        ex_state	: in  std_logic_vector(1 downto 0);
        pc_sctrl	: in  std_logic;

        exw_state	: out std_logic_vector(1 downto 0) := (others => '-');
        exw_sctrl	: out std_logic := '0'
    );
end entity;

architecture behavior of state_fsm is
begin

    main : process(clk)
    begin
		if rising_edge(clk) then 
			exw_state <= (others => '-');
			exw_sctrl <= '0';
		end if;		   
		
        if falling_edge(clk) then
            exw_sctrl   <= '0';
            exw_state <= ex_state;

            if ex_brch = '1' then  
                case ex_state is
                    when "00" =>
                        if pc_sctrl = '1' then
                            exw_state <= "01";
							exw_sctrl  <= '1';
                        end if;

                    when "01" =>
                        if pc_sctrl = '1' then
                            exw_state <= "11";
                        else
                            exw_state <= "00";
                        end if;			 
						exw_sctrl   <= '1';
                    when "11" =>
                        if pc_sctrl = '0' then
                            exw_state <= "01";
							exw_sctrl   <= '1';
                        end if;

                    when "10" =>
                        if pc_sctrl = '1' then
                            exw_state <= "11";
                        else
                            exw_state <= "00";
                        end if;	   
						exw_sctrl   <= '1';
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

end architecture;
