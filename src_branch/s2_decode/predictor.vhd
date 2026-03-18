library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;

entity predictor is 
    port(    
        id_pc       : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        id_immed    : in  std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
        ifd_target  : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        
        id_jump     : in  std_logic;
        id_branch   : in  std_logic; 
        
        -- state writeback
        ex_pc       : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        exw_state   : in  std_logic_vector(1 downto 0);
        exw_sctrl   : in  std_logic; 
        
        -- target correction
        id_target   : out std_logic_vector(COUNTER_LENGTH-1 downto 0); 
        id_tctrl    : out std_logic := '0';
        
        -- prediction output
        pred_pc     : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
        id_pctrl    : out std_logic;	  
        id_state    : out std_logic_vector(1 downto 0); 
        id_brch     : out std_logic
    );								  					   
end entity;

architecture behavior of predictor is  

    type entry is record
        valid : std_logic;
        state : std_logic_vector(1 downto 0);
    end record;

    type state_array is array(0 to 2**(COUNTER_LENGTH)-1) of entry;

    signal TSB : state_array := (others => (valid => '0', state => "00"));
   	signal tsb_update : std_logic := '0';
begin

	----------------------------------------------------------------
	-- Process 1 : Target Calculation + Correction
	----------------------------------------------------------------
	target_proc : process(id_pc, id_jump, id_branch)
	    variable var_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
	begin
	    if (rising_edge(id_jump) or rising_edge(id_branch)) then
	
	        var_target := std_logic_vector(
	            resize(signed(id_pc), COUNTER_LENGTH) +
	            resize(signed(id_immed), COUNTER_LENGTH)
	        );
	
	        id_target <= var_target;
	
	        if var_target = ifd_target then
	            id_tctrl <= '0';
			else 	 
				id_tctrl <= '1';
	        end if;
		else 
			id_target <= (others => '-');
	   		id_tctrl  <= '0';
	    end if;
	
	end process;
	
	----------------------------------------------------------------
	-- Process 2 : State Lookup + Prediction
	----------------------------------------------------------------
	state_pred_proc : process(id_pc, id_jump, id_branch)
	    variable i      : integer range 0 to 2**(COUNTER_LENGTH)-1;
	    variable state  : std_logic_vector(1 downto 0);
	    variable pctrl  : std_logic;
	    variable target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
	begin
	
	    if (rising_edge(id_jump) or rising_edge(id_branch)) then
	
	        -- Compute target for prediction
	        target := std_logic_vector(
	            resize(signed(id_pc), COUNTER_LENGTH) +
	            resize(signed(id_immed), COUNTER_LENGTH)
	        );
	
	        -- State lookup
	        i := to_integer(unsigned(id_pc));
	        if TSB(i).valid = '1' then
	            state := TSB(i).state;
	        else
	            state := "10";  -- Default state
	        end if;
	
	        -- Forward state from EX stage if needed
	        --if (i = to_integer(unsigned(ex_pc))) and (state /= exw_state) then
	            --state := exw_state;
	        --end if;
	
	        -- Decode state to control
	        --pctrl := '0';
	        if state = "10" or state = "11" then
	            pctrl := '1';
			else 
				pctrl := '0';
	        end if;
	
	        -- Jumps are always taken
	        if id_jump = '1' then
	            pctrl := '1';
	        end if;
			-- Apply outputs   
			
			if pctrl = '1' then
	            pred_pc <= target;	
			else 
				pred_pc <= (others => '-');
	        end if;	
			
			id_pctrl <= pctrl;
	        id_state <= state;
	        id_brch  <= '1';
		else 	
			-- Default outputs
		    pred_pc  <= (others => '-');
		    id_pctrl <= '0';
		    id_state <= "00";
		    id_brch  <= '0';
			
	    end if;
	
	end process;
	
	
	----------------------------------------------------------------
	-- Process 3 : State Writeback (Combinational)
	----------------------------------------------------------------
	state_wb_proc : process(ex_pc, exw_state, exw_sctrl)
	    variable j : integer range 0 to 2**(COUNTER_LENGTH)-1;
	begin
	    j := to_integer(unsigned(ex_pc));
	    if exw_sctrl = '1' then
	        TSB(j).valid <= '1';
	        TSB(j).state <= exw_state;
	    end if;
	end process;

end architecture;