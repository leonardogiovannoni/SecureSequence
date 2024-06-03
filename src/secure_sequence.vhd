LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY SequenceRecognizer IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        number : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- 8-bit input number
        first : IN STD_LOGIC; -- Boolean flag for first number
        unlock : OUT STD_LOGIC; -- Unlock output
        warning : OUT STD_LOGIC -- Warning output
    );
END SequenceRecognizer;

ARCHITECTURE Behavioral OF SequenceRecognizer IS
    TYPE State_Type IS (WaitingForFirst, WaitingForNext, ErrorState);
    SIGNAL current_state : State_Type;
    SIGNAL next_index : INTEGER RANGE 0 TO 4;
    SIGNAL error : STD_LOGIC;
    SIGNAL error_count : INTEGER RANGE 0 TO 100; -- Arbitrarily large enough range

    TYPE Array_Type IS ARRAY(0 TO 4) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT CORRECT_SEQUENCE : Array_Type := (
        x"24", x"13", x"38", x"65", x"49"
    );
BEGIN
    -- State transition and output logic
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= WaitingForFirst;
            next_index <= 0;
            error <= '0';
            error_count <= 0;
            unlock <= '0';
            warning <= '0';
        ELSIF rising_edge(clk) THEN
            CASE current_state IS
                WHEN WaitingForFirst =>
                    IF first = '1' THEN
                        IF CORRECT_SEQUENCE(0) /= number THEN
                            error <= '1';
                        END IF;
                        next_index <= 1;
                        current_state <= WaitingForNext;
                    END IF;
                    unlock <= '0';
                    warning <= '0';

                WHEN WaitingForNext =>
                    IF first = '1' THEN
                        current_state <= ErrorState;
                        warning <= '1';
                    ELSE
                        IF CORRECT_SEQUENCE(next_index) /= number THEN
                            error <= '1';
                        END IF;
                        IF next_index = 4 THEN
                            next_index <= 0;
                            IF error = '1' THEN
                                error_count <= error_count + 1;
                            END IF;
                            IF error = '1' AND error_count >= 2 THEN
                                current_state <= ErrorState;
                            ELSE
                                current_state <= WaitingForFirst;
                            END IF;
                            IF error = '0' THEN
                                unlock <= '1';
                                warning <= '0';
                            ELSE
                                unlock <= '0';
                                warning <= '1';
                            END IF;
                            error <= '0';
                        ELSE
                            next_index <= next_index + 1;
                        END IF;
                        
                    END IF;

                WHEN ErrorState =>
                    unlock <= '0';
                    warning <= '1';

            END CASE;
        END IF;
    END PROCESS;
END Behavioral;