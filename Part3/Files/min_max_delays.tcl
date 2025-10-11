# Load liberty files for max and min analysis
read_liberty -max /home/navneet/Documents/Verilog/OpenSTA/examples/nangate45_slow.lib.gz
read_liberty -min /home/navneet/Documents/Verilog/OpenSTA/examples/nangate45_fast.lib.gz

# Read the gate-level Verilog netlist
read_verilog /home/navneet/Documents/Verilog/OpenSTA/examples/example1.v

# Link the top-level design
link_design top

# Define clocks and input delays
create_clock -name clk -period 10 {clk1 clk2 clk3}
set_input_delay -clock clk 0 {in1 in2}

# Generate a full min/max timing report
report_checks -path_delay min_max
