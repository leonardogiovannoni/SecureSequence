library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SecureSeq is
    Port (
        clock : in STD_LOGIC;
        reset : in STD_LOGIC; -- Assume active-high reset
        num_in : in STD_LOGIC_VECTOR(7 downto 0);
        first : in STD_LOGIC;
        unlock : out STD_LOGIC;
        warning : out STD_LOGIC
    );
end SecureSeq;

architecture Behavioral of SecureSeq is
    type state_type is (WAIT, CHECK, UNLOCK, WARNING);
    signal state, next_state: state_type;
    signal sequence: array(0 to 4) of STD_LOGIC_VECTOR(7 downto 0) := (x"24", x"13", x"38", x"65", x"49"); -- The sequence to recognize
    signal count: INTEGER range 0 to 5 := 0;
    signal error_count: INTEGER range 0 to 3 := 0;
begin
    process(clock, reset)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                state <= WAIT;
                count <= 0;
                error_count <= 0;
                unlock <= '0';
                warning <= '0';
            else
                case state is
                    when WAIT =>
                        if first = '1' and num_in = sequence(0) then
                            state <= CHECK;
                            count <= count + 1;
                        else
                            state <= WARNING;
                        end if;
                    when CHECK =>
                        if count < 5 then
                            if num_in = sequence(count) then
                                if count = 4 then
                                    state <= UNLOCK;
                                else
                                    count <= count + 1;
                                end if;
                            else
                                state <= WARNING;
                            end if;
                        end if;
                    when UNLOCK =>
                        unlock <= '1';
                        -- Reset the state machine for the next sequence
                        state <= WAIT;
                        count <= 0;
                        unlock <= '0'; -- Reset unlock signal after one cycle
                    when WARNING =>
                        warning <= '1';
                        error_count <= error_count + 1;
                        if error_count >= 3 then
                            -- Keep warning high and cease function until reset
                        else
                            -- Prepare for the next sequence attempt
                            state <= WAIT;
                            count <= 0;
                            warning <= '0'; -- Reset warning signal after one cycle
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Additional logic to handle continuous warning signal when error_count >= 3
    -- This could involve a secondary process or adjustments within the main process
end Behavioral;

