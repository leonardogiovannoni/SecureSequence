use std::{fmt::format, str::FromStr};
use serde::Deserialize;
use clap::Parser;


fn preamble(name: &str) -> String {
    format!(r#"
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.env.stop;

ENTITY {} IS
END {};

ARCHITECTURE behavior OF {} IS

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
"#, name, name, name)
}





#[derive(Debug, Clone, Copy)]
struct Input {
    reset: bool,
    number: u8,
    first: bool,
}

impl Input {
    fn emit_reset(&self) -> String {
        format!("\treset <= '{}';", if self.reset { '1' } else { '0' })
    }

    fn emit_number(&self) -> String {
        format!("\tnumber <= x\"{}\";", format!("{:02x}", self.number))
    }

    fn emit_first(&self) -> String {
        format!("\tfirst <= '{}';", if self.first { '1' } else { '0' })
    }

    fn emit(&self) -> String {
        format!(
            "{}\n{}\n{}\n",
            self.emit_reset(),
            self.emit_number(),
            self.emit_first()
        ) 
    }

    fn emit_diff(&self, prev: &Input) -> String {
        let mut rv = String::new();
        if self.reset != prev.reset {
            rv.push_str(&self.emit_reset());
            rv.push_str("\n");
        }
        if self.number != prev.number {
            rv.push_str(&self.emit_number());
            rv.push_str("\n");
        }
         if self.first != prev.first {
            rv.push_str(&self.emit_first());
            rv.push_str("\n");
        }
        rv
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
        self.emit_base(|| self.input.emit())
    }

    fn emit_diff(&self, prev: &InputWithAsserts) -> String {
        self.emit_base(|| self.input.emit_diff(&prev.input))
    }
    

    fn emit_base(&self, f: impl FnOnce() -> String) -> String {
        let mut rv = String::new();
        rv.push_str(&f());
        rv.push_str("\tWAIT FOR CLK_PERIOD;\n");
        if let Some(asserts) = self.asserts {
            rv.push_str(&format!("\tASSERT unlock = '{}' REPORT \"Unlock error\" SEVERITY error;\n", if asserts.unlock { '1' } else { '0' }));
            rv.push_str(&format!("\tASSERT warning = '{}' REPORT \"Warning error\" SEVERITY error;\n", if asserts.warning { '1' } else { '0' }));
        }
        rv
    } 
}

#[derive(Debug)]
struct InputListWithAsserts {
    inputs: Vec<InputWithAsserts>,
}

impl InputListWithAsserts {
    fn emit(&self) -> String {
        let (_, mut rv) =
            self.inputs
                .iter()
                .fold((None, String::new()), |(prev, mut acc), input| {
                   if let Some(prev) = prev {
                        acc.push_str(&input.emit_diff(prev));
                    } else {
                        acc.push_str(&input.emit());
                    }
                    (Some(input), acc)
                });
        rv.push_str("\nSTOP;\n");
        rv
    }
}

fn emit_tb(input_list: InputListWithAsserts, name: &str) -> String {
    format!(
        "{}{}{}",
        preamble(name),
        input_list.emit(),
        "END process;\nEND behavior;\n"
    )
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



#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    #[clap(short, long)]
    dir: String,

    #[clap(short, long)]
    out_dir: String,
    
}



fn main() {
    let args = Args::parse();
    
    let out_dir = std::path::Path::new(&args.out_dir);
    for entry in std::fs::read_dir(args.dir).unwrap() {
        let entry = entry.unwrap();
        let path = entry.path();
        if let Some(ext) = path.extension() {
            if ext == "yaml" {
                let name = path.file_stem().unwrap().to_str().unwrap();
                let data = std::fs::read_to_string(path.clone()).unwrap();
                let input_list = InputListWithAsserts::from_str(&data).unwrap();
                let tb = emit_tb(input_list, name);
                let file_name = out_dir.join(format!("{}.vhd", name));
                std::fs::write(file_name, tb).unwrap();
            }
        }
    }    
}