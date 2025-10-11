read_liberty -min /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/sky130_fd_sc_hd__tt_025C_1v80.lib 
read_liberty -max /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty -min /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsdpll.lib
read_liberty -max /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsdpll.lib
read_liberty -min /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsddac.lib
read_liberty -max /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsddac.lib
read_verilog /home/navneet/Documents/Verilog/Labs/vsdbabysoc_synth.v
link_design vsdbabysoc
read_sdc /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/sdc/vsdbabysoc_synthesis.sdc
report_checks -path_delay min_max
