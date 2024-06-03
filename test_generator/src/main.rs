use std::{fmt::format, str::FromStr};

use serde::Deserialize;


static PREAMBOLE: &str = r#"
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SequenceRecognizer_tb IS
END SequenceRecognizer_tb;

ARCHITECTURE behavior OF SequenceRecognizer_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT SequenceRecognizer
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         number : IN  std_logic_vector(7 DOWNTO 0);
         first : IN  std_logic;
         unlock : OUT  std_logic;
         warning : OUT  std_logic
        );
    END COMPONENT;
    
    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal number : std_logic_vector(7 DOWNTO 0) := (others => '0');
    signal first : std_logic := '0';

    -- Outputs
    signal unlock : std_logic;
    signal warning : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: SequenceRecognizer PORT MAP (
          clk => clk,
          reset => reset,
          number => number,
          first => first,
          unlock => unlock,
          warning => warning
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
    reset <= '1';
    WAIT FOR CLK_PERIOD; 
"#;



#[derive(Debug, Clone, Copy)]
struct Input {
    reset: bool,
    number: u8,
    first: bool,
}

impl Input {
    fn emit(&self) -> String {
        format!(
            r#"
            reset <= '{}';
            number <= x"{}";
            first <= '{}';
            "#,
            if self.reset { '1' } else { '0' },
            format!("{:02x}", self.number),
            if self.first { '1' } else { '0' },
        )
    }
}

#[derive(Debug)]
struct Output {
    unlock: bool,
    warning: bool,
}

#[derive(Debug, Clone, Copy)]
struct Assert {
    unlock: bool,
    warning: bool,
}

#[derive(Debug, Clone, Copy)]
struct InputWithAsserts {
    input: Input,
    asserts: Option<Assert>,
}

impl InputWithAsserts {
    fn emit(&self) -> String {
        let input = self.input.emit();
        let asserts = match self.asserts {
            Some(asserts) => {
                format!(
                    r#"
                    assert unlock = '{}' report "Unlock error" severity error;
                    assert warning = '{}' report "Warning error" severity error;
                    "#,
                    if asserts.unlock { '1' } else { '0' },
                    if asserts.warning { '1' } else { '0' },
                )
            }
            None => "".to_string(),
        };
        format!(r#"
                {}
                wait for CLK_PERIOD;
                {}
                "#, input, asserts)
    }
}

#[derive(Debug)]
struct InputListWithAsserts {
    inputs: Vec<InputWithAsserts>,
}

impl InputListWithAsserts {
    fn emit(&self) -> String {
        let mut rv = self.inputs.iter().map(|input| input.emit()).collect::<Vec<String>>().join("\n");
        rv.push_str("\nwait;\n");
        rv
    }
}

fn emit_tb(input_list: InputListWithAsserts) -> String {
    format!("{}{}{}", PREAMBOLE, input_list.emit(), "end process;\nend behavior;\n")
}



#[derive(Debug, Deserialize)]
#[serde(untagged)]
enum NestedArray {
    Simple(u8, u8, u8),
    WithAsserts(u8, u8, u8, Vec<u8>),
}

#[derive(Debug, Deserialize)]
struct Data {
    arr: Vec<NestedArray>,
}

impl FromStr for InputListWithAsserts {
    type Err = serde_yaml::Error;

    fn from_str(data: &str) -> serde_yaml::Result<Self> {
        let parsed: Data = serde_yaml::from_str(data)?;
        let arr = parsed.arr;
        let mut v = Vec::new();
        for item in arr {
            match item {
                NestedArray::Simple(a, b, c) => {
                    v.push(InputWithAsserts {
                        input: Input {
                            reset: a != 0,
                            number: b,
                            first: c != 0,
                        },
                        asserts: None,
                    });
                }
                NestedArray::WithAsserts(a, b, c, asserts) => {
                    v.push(InputWithAsserts {
                        input: Input {
                            reset: a != 0,
                            number: b,
                            first: c != 0,
                        },
                        asserts: Some(Assert {
                            unlock: asserts[0] != 0,
                            warning: asserts[1] != 0,
                        }),
                    });
                }
            }
        }
        Ok(InputListWithAsserts { inputs: v })
    }
}





fn main() {
    let data = r#"
    arr:
        - [0, 36, 1, [0, 0]]
        - [0, 19, 0]
        - [0, 56, 0]
        - [0, 101, 0]
        - [0, 73, 0, [1, 0]]

        - [0, 255, 0, [0, 0]]
        - [0, 255, 0, [0, 0]]

        - [0, 36, 1]
        - [0, 19, 0]
        - [0, 55, 0]
        - [0, 101, 0]
        - [0, 73, 0, [0, 1]]

        - [0, 255, 0, [0, 0]]

        - [0, 36, 1]
        - [0, 19, 0]
        - [0, 56, 0]
        - [0, 101, 0]
        - [0, 73, 0, [1, 0]]

        - [0, 255, 0, [0, 0]]
    "#;

    let input_list = InputListWithAsserts::from_str(data).unwrap();
    let tb = emit_tb(input_list);
    println!("{}", tb);
}
