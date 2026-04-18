library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity instruction_loader is
    port (
        clk        : in  std_logic;
        rst_bar  : in  std_logic;

        -- UART input
        rx_data    : in  std_logic_vector(7 downto 0);
        rx_ready   : in  std_logic;

        -- BRAM interface
        bram_addr  : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
        bram_data  : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
        bram_we    : out std_logic;

        -- optional debug
        load_done  : out std_logic
    );
end entity;

architecture behavior of instruction_loader is

    signal shift_reg  : std_logic_vector(31 downto 0) := (others => '0');
    signal byte_count : integer range 0 to 3 := 0;

    signal addr_reg   : unsigned(COUNTER_LENGTH-1 downto 0) := (others => '0');

    signal we_reg     : std_logic := '0';
    signal done_reg   : std_logic := '0';

begin

    process(clk)
        variable instruc_var : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
    begin
        if rising_edge(clk) then

            ----------------------------------------------------------------
            -- RESET
            ----------------------------------------------------------------
            if rst_bar = '0' then
                shift_reg  <= (others => '0');
                byte_count <= 0;
                addr_reg   <= (others => '0');
                we_reg     <= '0';
                done_reg   <= '0';

            else

                ----------------------------------------------------------------
                -- DEFAULT PULSE BEHAVIOR
                ----------------------------------------------------------------
                we_reg <= '0';

                ----------------------------------------------------------------
                -- UART BYTE ACCUMULATION
                ----------------------------------------------------------------
                if rx_ready = '1' then

                    shift_reg <= shift_reg(23 downto 0) & rx_data;

                    if byte_count = 3 then

                        ----------------------------------------------------------------
                        -- WRITE TO BRAM
                        ----------------------------------------------------------------
                        instruc_var := shift_reg(16 downto 0) & rx_data;
                        bram_data <= instruc_var;
                        bram_addr <= std_logic_vector(addr_reg);
                        we_reg    <= '1';

                        ----------------------------------------------------------------
                        -- ADDRESS + DONE LOGIC
                        ----------------------------------------------------------------
                        if addr_reg = to_unsigned(MAX_COUNT-1, COUNTER_LENGTH) or instruc_var = SPACE_INSTRUCTION then
                            done_reg <= '1';
                        else
                            addr_reg <= addr_reg + 1;
                        end if;

                        byte_count <= 0;

                    else
                        byte_count <= byte_count + 1;
                    end if;

                end if;

            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- OUTPUTS
    --------------------------------------------------------------------
    bram_we   <= we_reg;
    load_done <= done_reg;


end architecture;