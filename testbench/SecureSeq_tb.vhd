library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SecureSeq_tb is
end SecureSeq_tb;

architecture Behavioral of SecureSeq_tb is
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal input_number : unsigned(7 downto 0);
    signal input_reset  : std_logic := '0';
    signal input_first  : std_logic := '0';
    signal unlock       : std_logic;
    signal warning      : std_logic;

    constant CLK_PERIOD : time := 10 ns;

    -- Instantiate the Unit Under Test (UUT)
    component SEQRecognizer is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            input_number : in unsigned(7 downto 0);
            input_reset : in std_logic;
            input_first : in std_logic;
            unlock      : out std_logic;
            warning     : out std_logic
        );
    end component;

begin
    -- Instantiate the UUT
    uut: SEQRecognizer
        port map (
            clk         => clk,
            rst         => rst,
            input_number => input_number,
            input_reset => input_reset,
            input_first => input_first,
            unlock      => unlock,
            warning     => warning
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        rst <= '1';
        input_number <= (others => '0');
        input_reset <= '0';
        input_first <= '0';
        wait for CLK_PERIOD;

        rst <= '0';
        wait for CLK_PERIOD;

        -- Correct sequence
        input_first <= '1';
        input_number <= x"24";
        wait for CLK_PERIOD;
        input_first <= '0';
        input_number <= x"13";
        wait for CLK_PERIOD;
        input_number <= x"38";
        wait for CLK_PERIOD;
        input_number <= x"65";
        wait for CLK_PERIOD;
        input_number <= x"49";
        wait for CLK_PERIOD;
        
        -- Check unlock signal
        wait for CLK_PERIOD / 2;
        assert unlock = '1' report "Unlock signal failed for correct sequence" severity error;
        assert warning = '0' report "Warning signal incorrectly set for correct sequence" severity error;
        wait for CLK_PERIOD / 2;

        -- Incorrect sequence
        input_first <= '1';
        input_number <= x"24";
        wait for CLK_PERIOD;
        input_first <= '0';
        input_number <= x"12"; -- incorrect number
        wait for CLK_PERIOD;
        input_number <= x"38";
        wait for CLK_PERIOD;
        input_number <= x"65";
        wait for CLK_PERIOD;
        input_number <= x"49";
        wait for CLK_PERIOD;

        -- Check warning signal
        wait for CLK_PERIOD / 2;
        assert unlock = '0' report "Unlock signal incorrectly set for incorrect sequence" severity error;
        assert warning = '1' report "Warning signal failed for incorrect sequence" severity error;
        wait for CLK_PERIOD / 2;

        -- Reset sequence
        input_reset <= '1';
        wait for CLK_PERIOD;
        input_reset <= '0';

        -- Additional tests for consecutive failures
        for i in 0 to 2 loop
            input_first <= '1';
            input_number <= x"24";
            wait for CLK_PERIOD;
            input_first <= '0';
            input_number <= x"12"; -- incorrect number
            wait for CLK_PERIOD;
            input_number <= x"38";
            wait for CLK_PERIOD;
            input_number <= x"65";
            wait for CLK_PERIOD;
            input_number <= x"49";
            wait for CLK_PERIOD;

            -- Check warning signal after each failure
            wait for CLK_PERIOD / 2;
            assert unlock = '0' report "Unlock signal incorrectly set for consecutive failures" severity error;
            assert warning = '1' report "Warning signal failed for consecutive failures" severity error;
            wait for CLK_PERIOD / 2;
        end loop;

        -- Wait a bit to observe persistent warning signal
        wait for 5 * CLK_PERIOD;

        -- Reset sequence
        input_reset <= '1';
        wait for CLK_PERIOD;
        input_reset <= '0';
        wait for 5 * CLK_PERIOD;

        -- Check reset functionality
        assert unlock = '0' report "Unlock signal incorrectly set after reset" severity error;
        assert warning = '0' report "Warning signal incorrectly set after reset" severity error;

        -- Correct sequence again
        input_first <= '1';
        input_number <= x"24";
        wait for CLK_PERIOD;
        input_first <= '0';
        input_number <= x"13";
        wait for CLK_PERIOD;
        input_number <= x"38";
        wait for CLK_PERIOD;
        input_number <= x"65";
        wait for CLK_PERIOD;
        input_number <= x"49";
        wait for CLK_PERIOD;

        -- Check unlock signal
        wait for CLK_PERIOD / 2;
        assert unlock = '1' report "Unlock signal failed for correct sequence after reset" severity error;
        assert warning = '0' report "Warning signal incorrectly set for correct sequence after reset" severity error;
        wait for CLK_PERIOD / 2;

        -- Finish simulation
        wait;
    end process;

end Behavioral;
