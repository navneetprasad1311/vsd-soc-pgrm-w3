# Labs on Static Timing Analysis

## Table of Contents

1. [Installation of OpenSTA](#installation-of-opensta)
2. [Running OpenSTA](#running-opensta)
3. [Timing Analysis of example1.v](#timing-analysis-of-example1v)
4. [Timing Analysis of VSDBabySoC](#timing-analysis-of-vsdbabysoc)
5. [PVT Corner Analysis of VSDBabySoC](#pvt-corner-analysis-of-vsdbabysoc)
6. [Summary: Static Timing Analysis (STA)](#summary-static-timing-analysis-sta)

---

## Installation of OpenSTA

This is done through cloning the OpenSTA github repo and running it through a docker container by using the following commands,

Prerequisites,
`docker` , `git`

```bash
sudo apt install docker.io git
```

To install OpenSTA,

```bash
git clone https://github.com/parallaxsw/OpenSTA.git
cd OpenSTA
docker build --file Dockerfile.ubuntu22.04 --tag opensta .
```

This ensures that the latest version of OpenSTA is installed with all the required dependencies.

---

## Running OpenSTA

Since OpenSTA is installed inside the docker container, it must be run with the below command

```bash
docker run -i -v /home/navneet:/home/navneet opensta
```

> [!Note]
> - `-v /home/navneet:/home/navneet` ensures the container sees the same directory structure as your host.
> - Inside the container, you can run your TCL script with the same absolute paths
> - No changes to the TCL script or netlist paths are needed.

![dockerinit](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/dockerinit.png)

---

## Timing Analysis of `example1.v`

This is done to gain familiarity with the OpenSTA tool, its command structure, and the overall workflow for performing static timing analysis.

### Using In-line Commands

Once inside the OpenSTA shell (% prompt), you can perform a basic static timing analysis using the following inline commands:

```bash
# Instructs OpenSTA to read and load the Liberty file "nangate45_slow.lib.gz".
read_liberty /home/navneet/Documents/Verilog/OpenSTA/examples/nangate45_slow.lib.gz
```
```bash
# Intructs OpenSTA to read and load the Verilog file (gate level verilog netlist) "example1.v"
read_verilog /home/navneet/Documents/Verilog/OpenSTA/examples/example1.v
```
```bash
# Using "top," which stands for the main module, links the Verilog code with the Liberty timing cells.
link_design top
```
```bash
# Create a 10ns clock named 'clk' for clk1, clk2, and clk3 inputs 
create_clock -name clk -period 10 {clk1 clk2 clk3}
```
```bash
# Set 0ns input delay for inputs in1 and in2 relative to clock 'clk'
set_input_delay -clock clk 0 {in1 in2}
```
```bash
# Report of the timing checks for the design 
report_checks 
```

This approach is handy for quick experimentation or debugging without the need to create a full TCL script.

![examplesta](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/examplesta.png)

By default, `report-checks` reports only max path delays, that is the Setup time delays. \
To see min path delays (Hold Time delays) use `report-checks -min` \
To see both use `report-checks -min_max`.

![examplestamin](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/examplestamin.png)

<details>
    <summary>Reports (Min/Max)</summary>

    report_checks -path_delay min
    Startpoint: in1 (input port clocked by clk)
    Endpoint: r1 (rising edge-triggered flip-flop clocked by clk)
    Path Group: clk
    Path Type: min

    Delay    Time   Description
    ---------------------------------------------------------
    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00 ^ input external delay
    0.00    0.00 ^ in1 (in)
    0.00    0.00 ^ r1/D (DFF_X1)
            0.00   data arrival time

    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00   clock reconvergence pessimism
            0.00 ^ r1/CK (DFF_X1)
    0.01    0.01   library hold time
            0.01   data required time
    ---------------------------------------------------------
            0.01   data required time
            -0.00   data arrival time
    ---------------------------------------------------------
            -0.01   slack (VIOLATED)

    report_checks 
    Startpoint: r2 (rising edge-triggered flip-flop clocked by clk)
    Endpoint: r3 (rising edge-triggered flip-flop clocked by clk)
    Path Group: clk
    Path Type: max

    Delay    Time   Description
    ---------------------------------------------------------
    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00 ^ r2/CK (DFF_X1)
    0.23    0.23 v r2/Q (DFF_X1)
    0.08    0.31 v u1/Z (BUF_X1)
    0.10    0.41 v u2/ZN (AND2_X1)
    0.00    0.41 v r3/D (DFF_X1)
            0.41   data arrival time

    10.00   10.00   clock clk (rise edge)
    0.00   10.00   clock network delay (ideal)
    0.00   10.00   clock reconvergence pessimism
            10.00 ^ r3/CK (DFF_X1)
    -0.16    9.84   library setup time
            9.84   data required time
    ---------------------------------------------------------
            9.84   data required time
            -0.41   data arrival time
    ---------------------------------------------------------
            9.43   slack (MET)

</details>

---

*SPEF-Based Timing Analysis* :

```bash
read_liberty /home/navneet/Documents/Verilog/OpenSTA/examples/nangate45_slow.lib.gz
read_verilog /home/navneet/Documents/Verilog/OpenSTA/examples/example1.v
link_design top
read_spef /home/navneet/Documents/Verilog/OpenSTA/examples/example1.dspef
create_clock -name clk -period 10 {clk1 clk2 clk3}
set_input_delay -clock clk 0 {in1 in2}
report_checks
```

![spefreportsta](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/spefreportsta.png)

<details>
    <summary>Reports (Max)</summary>
    
    report_checks
    Startpoint: r2 (rising edge-triggered flip-flop clocked by clk)
    Endpoint: r3 (rising edge-triggered flip-flop clocked by clk)
    Path Group: clk
    Path Type: max

    Delay    Time   Description
    ---------------------------------------------------------
    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00 ^ r2/CK (DFF_X1)
    2.58    2.58 ^ r2/Q (DFF_X1)
    2.58    5.16 ^ u1/Z (BUF_X1)
    2.75    7.91 ^ u2/ZN (AND2_X1)
    0.00    7.92 ^ r3/D (DFF_X1)
            7.92   data arrival time

    10.00   10.00   clock clk (rise edge)
    0.00   10.00   clock network delay (ideal)
    0.00   10.00   clock reconvergence pessimism
            10.00 ^ r3/CK (DFF_X1)
    -0.57    9.43   library setup time
            9.43   data required time
    ---------------------------------------------------------
            9.43   data required time
            -7.92   data arrival time
    ---------------------------------------------------------
            1.52   slack (MET)
</details>

> [!Note]
> A SPEF file contains parasitic information (resistance and capacitance) for the interconnects in a design. \
By reading it, OpenSTA can include real interconnect delays in timing analysis instead of relying only on ideal or estimated values.

---

### Using TCL (Tool Command Language)

You can automate the timing flow by placing these commands in a `.tcl` script and running it within the OpenSTA shell.

<details>
    <summary> min_max_delays.tcl </summary>
    
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
</details>

![exampletcl](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/exampletcl.png)

---

This `.tcl` file can be run using the following command,

```bash
docker run -i -v /home/navneet:/home/navneet opensta /home/navneet/min_max_delays.tcl
```

> [!Note]
> `/home/navneet/min_max_delays.tcl` is the path where your `.tcl` file is stored.

---

![workflow1](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/workflow1.png)

---

<details>
    <summary>TCL-workflow Report (Min/Max)</summary>
    
    Startpoint: in1 (input port clocked by clk)
    Endpoint: r1 (rising edge-triggered flip-flop clocked by clk)
    Path Group: clk
    Path Type: min

    Delay    Time   Description
    ---------------------------------------------------------
    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00 v input external delay
    0.00    0.00 v in1 (in)
    0.00    0.00 v r1/D (DFF_X1)
            0.00   data arrival time

    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00   clock reconvergence pessimism
            0.00 ^ r1/CK (DFF_X1)
    0.00    0.00   library hold time
            0.00   data required time
    ---------------------------------------------------------
            0.00   data required time
            -0.00   data arrival time
    ---------------------------------------------------------
            0.00   slack (VIOLATED)


    Startpoint: r2 (rising edge-triggered flip-flop clocked by clk)
    Endpoint: r3 (rising edge-triggered flip-flop clocked by clk)
    Path Group: clk
    Path Type: max

    Delay    Time   Description
    ---------------------------------------------------------
    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00 ^ r2/CK (DFF_X1)
    0.23    0.23 v r2/Q (DFF_X1)
    0.08    0.31 v u1/Z (BUF_X1)
    0.10    0.41 v u2/ZN (AND2_X1)
    0.00    0.41 v r3/D (DFF_X1)
            0.41   data arrival time

    10.00   10.00   clock clk (rise edge)
    0.00   10.00   clock network delay (ideal)
    0.00   10.00   clock reconvergence pessimism
            10.00 ^ r3/CK (DFF_X1)
    -0.16    9.84   library setup time
            9.84   data required time
    ---------------------------------------------------------
            9.84   data required time
            -0.41   data arrival time
    ---------------------------------------------------------
            9.43   slack (MET)
</details>

---

### STA Path Analysis

1. Min Path (Hold) — in1 → r1  
   - Slack: -0.01 (VIOLATED)  
   - Cause: Data path too short; data arrives too early.  
   - Fix: Add small buffer/delay or define realistic input delay.

2. Max Path (Setup) — r2 → r3  
   - Slack: +9.43 (MET)  
   - Path is well within timing; no setup issues.

![timinggraph](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/timinggraph.png)

*Bare bones timing graph made using the data from `report_checks` using python, to know more [click here](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/TiminggraphsREADME.md)*

---

## Timing Analysis of `VSDBabySoC`

The below given `.tcl` file is used automate this process.

**vsdbabysoc_min_max_delays.tcl**:

<pre>
# Load Liberty Libraries (standard cell + IPs)
read_liberty -min /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/sky130_fd_sc_hd__tt_025C_1v80.lib 
read_liberty -max /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_liberty -min /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsdpll.lib
read_liberty -max /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsdpll.lib

read_liberty -min /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsddac.lib
read_liberty -max /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsddac.lib

# Read Synthesized Netlist
read_verilog /home/navneet/Documents/Verilog/Labs/vsdbabysoc_synth.v

# Link the Top-Level Design
link_design vsdbabysoc

# Apply SDC Constraints
read_sdc /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/sdc/vsdbabysoc_synthesis.sdc

# Generate Timing Report
report_checks
</pre>

Few errors were observed while running this `.tcl` file they are,

|  **Error**                            | **Cause**                                        | **Fix**                               |
| ------------------------------------- | ------------------------------------------------ | ------------------------------------- |
| `syntax error line 74 in avsdpll.lib` | `//` comments are not supported in Liberty files | Replace with `/* … */` block comments |
| `default_fanout_load is 0.0`          | Benign warning                                   | Can be safely ignored                 |


![workflow2](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/workflow2.png)

---

**Full Report**

<details>
    <summary>Reports (Min/Max)</summary>
    Startpoint: _9501_ (rising edge-triggered flip-flop clocked by clk)
    Endpoint: _10343_ (rising edge-triggered flip-flop clocked by clk)
    Path Group: clk
    Path Type: min

    Delay    Time   Description
    ---------------------------------------------------------
    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00 ^ _9501_/CLK (sky130_fd_sc_hd__dfxtp_1)
    0.27    0.27 ^ _9501_/Q (sky130_fd_sc_hd__dfxtp_1)
    0.00    0.27 ^ _10343_/D (sky130_fd_sc_hd__dfxtp_1)
            0.27   data arrival time

    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00   clock reconvergence pessimism
            0.00 ^ _10343_/CLK (sky130_fd_sc_hd__dfxtp_1)
    -0.03   -0.03   library hold time
            -0.03   data required time
    ---------------------------------------------------------
            -0.03   data required time
            -0.27   data arrival time
    ---------------------------------------------------------
            0.31   slack (MET)


    Startpoint: _10458_ (rising edge-triggered flip-flop clocked by clk)
    Endpoint: _10023_ (rising edge-triggered flip-flop clocked by clk)
    Path Group: clk
    Path Type: max

    Delay    Time   Description
    ---------------------------------------------------------
    0.00    0.00   clock clk (rise edge)
    0.00    0.00   clock network delay (ideal)
    0.00    0.00 ^ _10458_/CLK (sky130_fd_sc_hd__dfxtp_1)
    4.13    4.13 ^ _10458_/Q (sky130_fd_sc_hd__dfxtp_1)
    5.06    9.19 v _8129_/Y (sky130_fd_sc_hd__clkinv_1)
    0.57    9.76 ^ _8607_/Y (sky130_fd_sc_hd__o211ai_1)
    0.00    9.76 ^ _10023_/D (sky130_fd_sc_hd__dfxtp_1)
            9.76   data arrival time

    11.00   11.00   clock clk (rise edge)
    0.00   11.00   clock network delay (ideal)
    0.00   11.00   clock reconvergence pessimism
            11.00 ^ _10023_/CLK (sky130_fd_sc_hd__dfxtp_1)
    -0.14   10.86   library setup time
            10.86   data required time
    ---------------------------------------------------------
            10.86   data required time
            -9.76   data arrival time
    ---------------------------------------------------------
            1.11   slack (MET)

</details>

### STA Path Analysis

1. Min Path (Hold) — _9501_ → _10343_  
   - Slack: 0.31 (MET)  
   - Data arrival: 0.27, Required: -0.03  
   - Path is hold-safe; data arrives well within the hold window.  

2. Max Path (Setup) — _10458_ → _10023_  
   - Slack: 1.11 (MET)  
   - Data arrival: 9.76, Required: 10.86  
   - Path meets setup timing with comfortable margin.  

Both hold and setup paths are timing-safe. Hold path is fast but no violation occurs, and setup path has sufficient margin for reliable operation.

![timinggraphsoc](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/timinggraphsoc.png)

*Timing graph generated from `reports_check`, to know more [click here](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/TiminggraphsREADME.md)*

---

### Advanced Analysis through OpenSTA

```bash
report_checks -digits 4 -fields [list capacitance slew input_pins fanout]
```

![advtim](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/advtim.png)

Provides a detailed report showing:  

- **Capacitance**: Load present at each node  
- **Slew**: Rate of signal transitions  
- **Input Pins**: Pins connected at each stage  
- **Fanout**: Number of outputs driven by each node  

Helpful for pinpointing slow transitions or overloaded signals that may lead to critical path timing issues.

---

```bash
report_power
```

![powerrpt](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/powerrpt.png)

Displays the overall power consumption of the design, including a detailed breakdown:  

- **Dynamic Power**: From signal switching activity  
- **Static (Leakage) Power**: From transistors that remain always on  

Useful for assessing the power-performance trade-offs after achieving timing closure.

---

## PVT Corner Analysis of `VSDBabySoC`

**PVT Corner Analysis** is a critical step in verifying the timing of digital designs. PVT stands for **Process, Voltage, and Temperature**, and a “corner” represents a specific combination of these factors that can affect circuit performance. This analysis ensures that the design operates correctly under all possible manufacturing and environmental variations.

**Process corners** model the variations in manufacturing, typically categorized as Fast-Fast (FF), Typical-Typical (TT), and Slow-Slow (SS). These corners account for the fastest and slowest devices that can be produced in the fabrication process.  

**Voltage corners** account for variations in supply voltage, such as low, nominal, and high voltage scenarios. Fluctuations in voltage directly impact the speed of logic gates and can cause timing violations if not properly analyzed.  

**Temperature corners** simulate operating conditions at different temperatures, commonly low, nominal, and high (e.g., 0°C, 25°C, 125°C). Temperature affects transistor mobility, which influences the speed of the circuit.  

During **post-synthesis timing analysis**, the synthesized netlist is checked for setup and hold violations at each PVT corner. This identifies **worst-case and best-case timing paths**, ensuring that the design remains reliable and robust in real silicon under all expected conditions.  

In summary, PVT corner analysis helps designers **predict timing failures**, optimize the design for robustness, and guarantee functional correctness across all process, voltage, and temperature variations.

Static Timing Analysis (STA) is conducted across all PVT corners to ensure the design meets its timing requirements. 

For sub-40nm technology nodes, the **worst-case max paths** (setup-critical) typically occur under:  
- `ss_LowTemp_LowVolt` 
- `ss_HighTemp_LowVolt`  
These represent the slowest corners.

The **worst-case min paths** (hold-critical) generally occur under:  
- `ff_LowTemp_HighVolt`  
- `ff_HighTemp_HighVolt`  
These represent the fastest corners.

The following TCL script can be executed to perform STA for all available PVT corners using the Sky130 timing libraries. The timing libraries can be downloaded from:

[skywaterPDK Library Repo](https://github.com/efabless/skywater-pdk-libs-sky130_fd_sc_hd/tree/master/timing)

This script below can be used to perform Static Timing Analysis (STA) across all PVT corners for which the Sky130 Liberty files are provided,

**sta_across_pvt.tcl**

<pre>
set list_of_lib_files(1) "sky130_fd_sc_hd__tt_025C_1v80.lib"
set list_of_lib_files(2) "sky130_fd_sc_hd__ff_100C_1v65.lib"
set list_of_lib_files(3) "sky130_fd_sc_hd__ff_100C_1v95.lib"
set list_of_lib_files(4) "sky130_fd_sc_hd__ff_n40C_1v56.lib"
set list_of_lib_files(5) "sky130_fd_sc_hd__ff_n40C_1v65.lib"
set list_of_lib_files(6) "sky130_fd_sc_hd__ff_n40C_1v76.lib"
set list_of_lib_files(7) "sky130_fd_sc_hd__ss_100C_1v40.lib"
set list_of_lib_files(8) "sky130_fd_sc_hd__ss_100C_1v60.lib"
set list_of_lib_files(9) "sky130_fd_sc_hd__ss_n40C_1v28.lib"
set list_of_lib_files(10) "sky130_fd_sc_hd__ss_n40C_1v35.lib"
set list_of_lib_files(11) "sky130_fd_sc_hd__ss_n40C_1v40.lib"
set list_of_lib_files(12) "sky130_fd_sc_hd__ss_n40C_1v44.lib"
set list_of_lib_files(13) "sky130_fd_sc_hd__ss_n40C_1v76.lib"

read_liberty /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsdpll.lib
read_liberty /home/navneet/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsddac.lib

for {set i 1} {$i <= [array size list_of_lib_files]} {incr i} {
read_liberty /home/navneet/Documents/Verilog/skywater-pdk-libs-sky130_fd_sc_hd/timing/$list_of_lib_files($i)
read_verilog /home/navneet/Documents/Verilog/Labs/vsdbabysoc_synth.v
link_design vsdbabysoc
current_designa
read_sdc /home/navneet/Documents/Verilog/Labs/vsdbabysoc_synthesis.sdc
check_setup -verbose
report_checks -path_delay min_max -fields {nets cap slew input_pins fanout} -digits {4} > /home/navneet/OpenSTA/out/min_max_$list_of_lib_files($i).txt

exec echo "$list_of_lib_files($i)" >> /home/navneet/OpenSTA/out/sta_worst_max_slack.txt
report_worst_slack -max -digits {4} >> /home/navneet/OpenSTA/out/sta_worst_max_slack.txt

exec echo "$list_of_lib_files($i)" >> /home/navneet/OpenSTA/out/sta_worst_min_slack.txt
report_worst_slack -min -digits {4} >> /home/navneet/OpenSTA/out/sta_worst_min_slack.txt

exec echo "$list_of_lib_files($i)" >> /home/navneet/OpenSTA/out/sta_tns.txt
report_tns -digits {4} >> /home/navneet/OpenSTA/out/sta_tns.txt

exec echo "$list_of_lib_files($i)" >> /home/navneet/OpenSTA/out/sta_wns.txt
report_wns -digits {4} >> /home/navneet/OpenSTA/out/sta_wns.txt
}
</pre>

Make sure the output directory `/home/navneet/OpenSTA/out/` exists before running Static Timing Analysis.

![workflow3](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/workflow3.png)

![files](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/files.png)

The following timing summary table was collected by running STA across 13 PVT corners using OpenSTA.

Metrics such as Worst Hold Slack, Worst Setup Slack, WNS, and TNS were extracted from the output reports.


| PVT Corner                        | TNS Max     | WNS Max  | Worst Slack Max | Worst Slack Min |
| --------------------------------- | ----------- | -------- | --------------- | --------------- |
| sky130_fd_sc_hd__tt_025C_1v80.lib | 0.0000      | 0.0000   | 1.1060          | 0.3096          |
| sky130_fd_sc_hd__ff_100C_1v65.lib | 0.0000      | 0.0000   | 2.4466          | 0.2491          |
| sky130_fd_sc_hd__ff_100C_1v95.lib | 0.0000      | 0.0000   | 3.8366          | 0.1960          |
| sky130_fd_sc_hd__ff_n40C_1v56.lib | 0.0000      | 0.0000   | 1.1270          | 0.2915          |
| sky130_fd_sc_hd__ff_n40C_1v65.lib | 0.0000      | 0.0000   | 2.1219          | 0.2551          |
| sky130_fd_sc_hd__ff_n40C_1v76.lib | 0.0000      | 0.0000   | 2.9919          | 0.2243          |
| sky130_fd_sc_hd__ss_100C_1v40.lib | -7521.4248  | -13.0402 | -13.0402        | 0.9053          |
| sky130_fd_sc_hd__ss_100C_1v60.lib | -2909.8362  | -6.2777  | -6.2777         | 0.6420          |
| sky130_fd_sc_hd__ss_n40C_1v28.lib | -36775.8398 | -52.9031 | -52.9031        | 1.8296          |
| sky130_fd_sc_hd__ss_n40C_1v35.lib | -23278.9902 | -33.1984 | -33.1984        | 1.3475          |
| sky130_fd_sc_hd__ss_n40C_1v40.lib | -17170.5898 | -24.6564 | -24.6564        | 1.1249          |
| sky130_fd_sc_hd__ss_n40C_1v44.lib | -13600.6846 | -19.9610 | -19.9610        | 0.9909          |
| sky130_fd_sc_hd__ss_n40C_1v76.lib | -1905.4320  | -3.9606  | -3.9606         | 0.5038          |

---

**Worst Min Slack**

![worstminslack](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/worstminslack.png)
*Worst Min Slack – The smallest positive slack observed across all timing paths.*

---

**Worst Max Slack**

![worstmaxslack](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/worstmaxslack.png)
*Worst Max Slack – The largest positive slack observed across all timing paths.*

---

**Worst Negative Slack**

![worstnegativeslack](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/worstnegativeslack.png)
*Worst Negative Slack – The most critical timing violation (largest negative slack) in the design.*

---

**Total Negative Slack**

![totalnegativeslack](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part3/Images/totalnegativeslack.png)
*Total Negative Slack – The sum of all negative slacks across all paths, indicating overall timing violations.*

---
 
## Summary: Static Timing Analysis (STA)

- OpenSTA is installed via Docker and GitHub for a consistent environment.
- Load Liberty files, netlists, and SDC constraints; define clocks and input delays.
- Use report_checks to get setup (max) and hold (min) path timings.
- SPEF files include parasitic delays for accurate STA.
- TCL scripts automate min/max timing reports for the design.
- STA identifies critical paths: min path (hold) and max path (setup) with slack analysis.
- Metrics: WNS (worst negative slack), TNS (total negative slack), worst slack max/min.
- PVT corner analysis ensures timing correctness across process, voltage, and temperature variations.

---
