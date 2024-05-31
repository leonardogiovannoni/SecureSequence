library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SEQRecognizer is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        input_number : in unsigned(7 downto 0);
        input_reset : in std_logic;
        input_first : in std_logic;
        unlock      : out std_logic;
        warning     : out std_logic
    );
end SEQRecognizer;

architecture Behavioral of SEQRecognizer is
    type state_type is (IDLE, CHECKING);
    signal state          : state_type := IDLE;
    signal current_index  : integer range 0 to 4 := 0;
    signal failures       : integer range 0 to 3 := 0;
    type seq_type is array (0 to 4) of unsigned(7 downto 0);
    constant SEQ     : seq_type := (
        x"24", -- 36
        x"13", -- 19
        x"38", -- 56
        x"65", -- 101
        x"49"  -- 73
    );
begin

    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            current_index <= 0;
            failures <= 0;
            unlock <= '0';
            warning <= '0';
        elsif rising_edge(clk) then
            if input_reset = '1' then
                state <= IDLE;
                current_index <= 0;
                failures <= 0;
                unlock <= '0';
                warning <= '0';
            else
                case state is
                    when IDLE =>
                        if input_first = '1' then
                            if input_number = SEQ(0) then
                                current_index <= 1;
                                unlock <= '0';
                                warning <= '0';
                                state <= CHECKING;
                            else
                                failures <= failures + 1;
                                warning <= '1';
                            end if;
                        end if;
                    when CHECKING =>
                        if failures >= 3 then
                            unlock <= '0';
                            warning <= '1';
                        else
                            if input_first = '1' then
                                failures <= failures + 1;
                                warning <= '1';
                                state <= IDLE;
                            elsif input_number = SEQ(current_index) then
                                if current_index = 4 then
                                    unlock <= '1';
                                    warning <= '0';
                                    current_index <= 0;
                                    state <= IDLE;
                                else
                                    current_index <= current_index + 1;
                                    unlock <= '0';
                                    warning <= '0';
                                end if;
                            else
                                failures <= failures + 1;
                                warning <= '1';
                                current_index <= 0;
                                state <= IDLE;
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process;

end Behavioral;

