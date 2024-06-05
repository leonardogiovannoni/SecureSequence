SRC_DIR := "src"
TESTBENCH_DIR := "testbench"
BUILD_DIR := "build"
DUMP_DIR := "dump"
TEST_GEN_DIR := "test_generator"
TEST_DIR := "test"


analyze test:
    #!/bin/bash
    cd {{SRC_DIR}}
    ghdl -a --ieee=synopsys -fexplicit --std=08 --workdir=../{{BUILD_DIR}} *.vhd
    cd ..
    cd {{TESTBENCH_DIR}}
    ghdl -a --ieee=synopsys -fexplicit --std=08 --workdir=../{{BUILD_DIR}} {{test}}
    cd ..

elaborate test:
    #!/bin/bash
    cd {{TESTBENCH_DIR}}
    # iter (bash) over each file in the directory
    dump_dir={{BUILD_DIR}}/{{DUMP_DIR}}
    tb_name=$(basename {{test}} .vhd)
    ghdl -e --ieee=synopsys -fexplicit --std=08 --workdir=../{{BUILD_DIR}}  $tb_name
    cd ..





run test: 
    #!/bin/bash
    cd {{TESTBENCH_DIR}}
    dump_dir=../{{BUILD_DIR}}/{{DUMP_DIR}}
    tb_name=$(basename {{test}} .vhd)
    vcd_name="$tb_name".vcd
    vcd_file="$dump_dir/$vcd_name"
    ghdl -r --ieee=synopsys -fexplicit --std=08 --workdir=../{{BUILD_DIR}} $tb_name --vcd=$vcd_file
    cd ..


generate_test:
    #!/bin/bash
    mkdir -p {{TESTBENCH_DIR}}
    cd {{TEST_GEN_DIR}}
    cargo run --release -- --dir ../test/ --out-dir ../{{TESTBENCH_DIR}} 
    cd ..



start_gtkwave:
    #!/bin/bash
    gtkwave {{BUILD_DIR}}/{{DUMP_DIR}}/*.vcd

test:
    #!/bin/bash
    # for each file in testbench directory
    just clean
    for file in {{TESTBENCH_DIR}}/*.vhd; do
        just analyze $(basename $file)
        just elaborate $(basename $file .vhd)
        echo "Running test: $(basename $file .vhd)"
        just run $(basename $file .vhd)
        just clean
    done
    just clean
    



clean:
    #!/bin/bash
    rm -rf {{BUILD_DIR}}
    mkdir -p {{BUILD_DIR}}/{{DUMP_DIR}}
