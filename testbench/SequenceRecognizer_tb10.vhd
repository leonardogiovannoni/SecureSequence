
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.env.stop;

ENTITY SequenceRecognizer_tb10 IS
END SequenceRecognizer_tb10;

ARCHITECTURE behavior OF SequenceRecognizer_tb10 IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT SequenceRecognizer
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            first : IN STD_LOGIC;
            unlock : OUT STD_LOGIC;
            warning : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL number : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL first : STD_LOGIC := '0';

    -- Outputs
    SIGNAL unlock : STD_LOGIC;
    SIGNAL warning : STD_LOGIC;

    -- Clock period definition
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : SequenceRecognizer PORT MAP(
        clk => clk,
        reset => reset,
        number => number,
        first => first,
        unlock => unlock,
        warning => warning
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN		
    reset <= '1';
    WAIT FOR CLK_PERIOD; 
	reset <= '0';
	number <= x"24";
	first <= '1';
	WAIT FOR CLK_PERIOD;
	ASSERT unlock = '0' REPORT "Unlock error" SEVERITY error;
	ASSERT warning = '0' REPORT "Warning error" SEVERITY error;
	number <= x"13";
	first <= '0';
	WAIT FOR CLK_PERIOD;
	number <= x"38";
	WAIT FOR CLK_PERIOD;
	number <= x"65";
	WAIT FOR CLK_PERIOD;
	number <= x"49";
	WAIT FOR CLK_PERIOD;
	ASSERT unlock = '1' REPORT "Unlock error" SEVERITY error;
	ASSERT warning = '0' REPORT "Warning error" SEVERITY error;
	number <= x"ff";
	WAIT FOR CLK_PERIOD;
	ASSERT unlock = '0' REPORT "Unlock error" SEVERITY error;
	ASSERT warning = '0' REPORT "Warning error" SEVERITY error;
	WAIT FOR CLK_PERIOD;
	ASSERT unlock = '0' REPORT "Unlock error" SEVERITY error;
	ASSERT warning = '0' REPORT "Warning error" SEVERITY error;
	number <= x"24";
	first <= '1';
	WAIT FOR CLK_PERIOD;
	number <= x"13";
	first <= '0';
	WAIT FOR CLK_PERIOD;
	number <= x"37";
	WAIT FOR CLK_PERIOD;
	number <= x"65";
	WAIT FOR CLK_PERIOD;
	number <= x"49";
	WAIT FOR CLK_PERIOD;
	ASSERT unlock = '0' REPORT "Unlock error" SEVERITY error;
	ASSERT warning = '1' REPORT "Warning error" SEVERITY error;
	number <= x"ff";
	WAIT FOR CLK_PERIOD;
	ASSERT unlock = '0' REPORT "Unlock error" SEVERITY error;
	ASSERT warning = '0' REPORT "Warning error" SEVERITY error;
	number <= x"24";
	first <= '1';
	WAIT FOR CLK_PERIOD;
	number <= x"13";
	first <= '0';
	WAIT FOR CLK_PERIOD;
	number <= x"38";
	WAIT FOR CLK_PERIOD;
	number <= x"65";
	WAIT FOR CLK_PERIOD;
	number <= x"49";
	WAIT FOR CLK_PERIOD;
	ASSERT unlock = '1' REPORT "Unlock error" SEVERITY error;
	ASSERT warning = '0' REPORT "Warning error" SEVERITY error;
	number <= x"ff";
	WAIT FOR CLK_PERIOD;
	ASSERT unlock = '0' REPORT "Unlock error" SEVERITY error;
	ASSERT warning = '0' REPORT "Warning error" SEVERITY error;

STOP;
END process;
END behavior;
