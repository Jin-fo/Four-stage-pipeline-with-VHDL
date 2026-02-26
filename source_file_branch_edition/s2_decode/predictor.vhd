library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;

entity predictor is 
    port(    
        id_pc      	: in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        id_immed   	: in  std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
        ifd_target  : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        
        id_jump    	: in  std_logic;
        id_branch  	: in  std_logic; 
		
		        -- state writeback from fsm
        ex_pc      	: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
        exw_state   : in std_logic_vector(1 downto 0);
		exw_sctrl   : in std_logic; 
		
        -- target writeback correction 
		id_target  	: out std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '-'); 
		id_tctrl  	: out std_logic := '0'; 
		
		-- prediction output			 
        pred_pc   	: out std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '-');
        id_pctrl  	: out std_logic := '0';	  
		id_state   	: out std_logic_vector(1 downto 0) := (others => '-'); 
		id_brch	   	: out std_logic := '0'
    );								  					   
end entity;

architecture behavior of predictor is  

    type entry is record
        valid : std_logic;
        state : std_logic_vector(1 downto 0);
    end record;

    type state_array is array(0 to 2**(COUNTER_LENGTH)-1) of entry;

    -- Target State Buffer (direct-mapped)
    signal TSB    : state_array := (others => (valid => '0', state => "11"));
begin

    main : process(id_pc, id_immed, ifd_target, id_jump, id_branch, exw_sctrl, ex_pc, exw_state)
        variable i, j       : integer range 0 to 2**(COUNTER_LENGTH)-1;
        variable state    : std_logic_vector(1 downto 0) := "11";
        variable var_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
        variable var_pctrl  : std_logic := '1';
    begin  	  
	-- Default outputs
        id_tctrl  <= '0';
        id_target <= (others => '-');
        id_pctrl  <= '0'; 
        pred_pc   <= (others => '-');
        id_brch   <= '0';
        id_state  <= "00";
        
        if (id_jump = '1') or (id_branch = '1') then 
            ----------------------------------------------------------------
            -- Target calculation
            ----------------------------------------------------------------
            var_target := std_logic_vector(
                resize(signed(id_pc), COUNTER_LENGTH) +
                resize(signed(id_immed), COUNTER_LENGTH)
            );
            
			----------------------------------------------------------------
			-- Target correction
			----------------------------------------------------------------
			id_target <= var_target;  -- Always output the calculated target
			
			if var_target = ifd_target then
			    id_tctrl  <= '0';
			else
			    id_tctrl  <= '1';
			end if;
            
            ----------------------------------------------------------------
            -- State lookup
            ----------------------------------------------------------------
            i := to_integer(unsigned(id_pc));
            if TSB(i).valid = '1' then
                state := TSB(i).state;
            else
                state := "11";  -- Default strongly taken
            end if;

            ----------------------------------------------------------------
            -- State decode
            ----------------------------------------------------------------
            if state = "00" or state = "01" then
                var_pctrl := '0';
            else  -- state = "10" or "11"
                var_pctrl := '1';
            end if;
            
            id_state <= state;
            
            ----------------------------------------------------------------
            -- Trivial prediction (jumps always taken)
            ----------------------------------------------------------------
            if id_jump = '1' then
                var_pctrl := '1';
            end if;
            
            ----------------------------------------------------------------
            -- Prediction output
            ----------------------------------------------------------------
            if var_pctrl = '1' then
                pred_pc <= var_target;
            else
                pred_pc <= id_pc;
            end if;

            id_pctrl <= var_pctrl;
            id_brch  <= '1';
        end if;
    end process;

end architecture;
