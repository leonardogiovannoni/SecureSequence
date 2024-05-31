# VHDL Development Template Repository

This repository provides a template for developing VHDL projects. It includes a directory structure and example files to help you get started with VHDL development quickly and efficiently. The example of a full adder provided is for illustrative purposes and serves as a guide on how to structure your own VHDL projects.

## Directory Structure

- `./src`: This directory contains your VHDL source files.
  - `./src/full_adder.vhd`: An example VHDL file implementing a full adder. Replace this with your own VHDL files.
- `./testbench`: This directory contains your VHDL testbench files.
  - `./testbench/full_adder_tb.vhd`: An example testbench file for the full adder. Replace this with your own testbench files.
- `./justfile`: A configuration file for `just`, a handy way to save and run project-specific commands.
- `./vhdl_ls.toml`: Configuration file for VHDL Language Server, useful for setting up a VHDL development environment.

## Getting Started

To use this template, follow these steps:

1. **Clone the Repository:**
   ```sh
   git clone <repository_url>
   cd <repository_name>
   ```

2. **Replace Example Files:**
   - Replace `./src/full_adder.vhd` with your own VHDL source files.
   - Replace `./testbench/full_adder_tb.vhd` with your own testbench files.

3. **Set Up Development Environment:**
   - Ensure you have a GHDL and GTKWave installed on your system.
   - Install `just` to manage your project-specific commands.
   - Configure your editor with the VHDL Language Server using the `vhdl_ls.toml` file for improved VHDL development support.

4. **Run Your Testbenches:**
   - Use your VHDL simulator to compile and run the testbenches located in the `./testbench` directory.
   - For example, if using GHDL:
     ```sh
     ghdl -a ./src/full_adder.vhd
     ghdl -a ./testbench/full_adder_tb.vhd
     ghdl -e full_adder_tb
     ghdl -r full_adder_tb --vcd=full_adder_tb.vcd
     ```

## Additional Tools

- **Justfile:** Use the `justfile` to add project-specific commands for easier build and simulation management. Refer to [just documentation](https://github.com/casey/just) for more details.
- **VHDL Language Server:** Configure your development environment with `vhdl_ls.toml` for features like code completion, linting, and more. Refer to the [VHDL Language Server documentation](https://github.com/VHDL-LS) for setup instructions.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to enhance this template.

## License

This repository is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.

---

This template is designed to help you get started with VHDL development quickly. Replace the example files with your own and customize the `justfile` and `vhdl_ls.toml` as needed for your project requirements. Happy coding!