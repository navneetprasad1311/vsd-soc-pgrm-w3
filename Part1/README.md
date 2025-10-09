# Post Synthesis GLS  

After synthesis, the design is verified through Gate-Level Simulation (GLS) to ensure that the synthesized netlist behaves identically to the RTL design. This step validates that the synthesis process has not introduced any functional mismatches or timing issues.

While this topic was covered concisely in *Week 2* [Post-synthesis Simulation of VSDBabySoC](https://github.com/navneetprasad1311/vsd-soc-pgrm-w2/blob/main/Part2/README.md#post-synthesis-simulation-of-vsdbabysoc), this week we’ll take a deeper look at it, going through each step carefully.

---

## Table of Contents

1. [Key Aspects of Gate-Level Simulation (GLS)](#key-aspects-of-gate-level-simulation-gls)
2. [Synthesis of VSDBabySoC](#synthesis-of-vsdbabysoc)
3. [Functional Verification: Pre-Synthesis vs. Post-Synthesis Simulation](#functional-verification-pre-synthesis-vs-post-synthesis-simulation)
4. [Summary](#summary)

---

## Key Aspects of Gate-Level Simulation (GLS)

1. **Functional Verification** – Confirms synthesized netlist matches RTL behavior.  
2. **Gate-Level Netlist** – Uses standard cells instead of RTL constructs.  
3. **Timing Check** – Verifies delays, setup/hold times, and race conditions.  
4. **Reset Validation** – Ensures proper initialization from unknown states.  
5. **Clock Propagation** – Confirms correct clock/reset distribution.  
6. **Testbench Reuse** – RTL testbench used with minor adjustments.  
7. **Waveform Analysis** – Compare GLS and RTL outputs in tools like GTKWave.  
8. **Final Sanity Check** – Ensures design is ready for place-and-route.

---

## Synthesis of VSDBabySoC 

Synthesis requires the header files essential for the `rvmyth` module: `sp_verilog.vh`, `sandpiper.vh`, and `sandpiper_gen.vh`.

- **`sp_verilog.vh`** – Contains core Verilog macros and parameter definitions.  
- **`sandpiper.vh`** – Defines integration-specific settings used by SandPiper.  
- **`sandpiper_gen.vh`** – Includes tool-generated parameters and configuration values.  

These files must be present in the working directory to ensure an error-free synthesis process.  
This can be done using the following commands:

```bash
cd ~/Documents/Verilog/Labs/VSDBabySoC
cp -r src/include/sp_verilog.vh .
cp -r src/include/sandpiper.vh .
cp -r src/include/sandpiper_gen.vh .
```

Now inside the `../VSDBabySoC` folder, run `yosys` to perform synthesis.

```bash
yosys
```

![yosys](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/yosys.png)

---

Within `yosys`, run the commands below to import the essential Verilog files.

```bash
read_verilog src/module/vsdbabysoc.v 
read_verilog -I ~/Documents/Verilog/Labs/VSDBabySoC/src/include/ ~/Documents/Verilog/Labs/VSDBabySoC/src/module/rvmyth.v
read_verilog -I ~/Documents/Verilog/Labs/VSDBabySoC/src/include/ ~/Documents/Verilog/Labs/VSDBabySoC/src/module/clk_gate.v
```

![readvyosys](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/readvyosys.png)

---

Then, the liberty files,

```bash
read_liberty -lib ~/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsdpll.lib 
read_liberty -lib ~/Documents/Verilog/Labs/VSDBabySoC/src/lib/avsddac.lib 
read_liberty -lib ~/Documents/Verilog/Labs/VSDBabySoC/src/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```

![readlibyosys](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/readlibyosys.png)

---

Synthesize `vsdbabysoc`, specifying it as the top module,


```bash
synth -top vsdbabysoc
```

Synthesis must result in the stats being printed with all the cells and submodules listed as shown below.

![synthyosys](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/synthyosys.png)

---

Convert D Flip-Flops into equivalent Standard Cell instances by,

```bash
dfflibmap -liberty ~/Documents/Verilog/Labs/VSDBabySoC/src/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```

![dffyosys](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/dffyosys.png)

---

Perform Optimization and Technology mapping using the following commands,

```bash
opt
abc -liberty ~/Documents/Verilog/Labs/VSDBabySoC/src/lib/sky130_fd_sc_hd__tt_025C_1v80.lib -script +strash;scorr;ifraig;retime;{D};strash;dch,-f;map,-M,1,{D}
```

- Command Overview

| Command        | Purpose                                                                     |
| -------------- | --------------------------------------------------------------------------- |
| `strash`       | Structural hashing — converts logic network to an AIG (And-Inverter Graph). |
| `scorr`        | Sequential redundancy removal — detects equivalent registers.               |
| `ifraig`       | Combinational equivalence simplification.                                   |
| `retime`       | Moves flip-flops for timing optimization.                                   |
| `{D}`          | Placeholder or marker for design partition (used internally by Yosys/ABC).  |
| `strash`       | Re-run structural hashing after retiming.                                   |
| `dch,-f`       | Performs combinational optimization (don’t-care-based).                     |
| `map,-M,1,{D}` | Maps the logic to gates in the provided `.lib` standard cell library.       |


ABC in Yosys performs logic optimization and technology mapping, reducing gate count and preparing the design for efficient synthesis and gate-level simulation as shown below.

![abcyosys](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/abcyosys.png)

---

Then, carry out the final optimization and clean-up steps with:

```bash
flatten
setundef -zero
clean -purge
rename -enumerate
```

> [!Note]
> flatten          : Remove hierarchy, make a flat netlist \
> setundef -zero   : Replace undefined signals with 0 \
> clean -purge     : Delete unused/duplicate logic \
> rename -enumerate: Systematically rename nets and cells

The outcome of the optimization should resemble the demonstration below.

![optimyosys](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/optimyosys.png)

---

To view the statistics of the synthesized design, run:

```bash
stat
```

![statyosy](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/statyosys.png)

Complete statistics given below: 

<details> 
    <summary> Statistics </summary>

    === vsdbabysoc ===

        +----------Local Count, excluding submodules.
        | 
     4740 wires
     6214 wire bits
     4740 public wires
     6214 public wire bits
        7 ports
        7 port bits
     5924 cells
        8   $scopeinfo
        1   avsddac
        1   avsdpll
       10   sky130_fd_sc_hd__a2111oi_0
        1   sky130_fd_sc_hd__a211o_2
       26   sky130_fd_sc_hd__a211oi_1
        4   sky130_fd_sc_hd__a21boi_0
        1   sky130_fd_sc_hd__a21o_2
      667   sky130_fd_sc_hd__a21oi_1
        1   sky130_fd_sc_hd__a221o_2
      167   sky130_fd_sc_hd__a221oi_1
        3   sky130_fd_sc_hd__a22o_2
      119   sky130_fd_sc_hd__a22oi_1
        4   sky130_fd_sc_hd__a311oi_1
        1   sky130_fd_sc_hd__a31o_2
      346   sky130_fd_sc_hd__a31oi_1
        2   sky130_fd_sc_hd__a32oi_1
       21   sky130_fd_sc_hd__a41oi_1
       11   sky130_fd_sc_hd__and2_2
        1   sky130_fd_sc_hd__and3_2
      597   sky130_fd_sc_hd__clkinv_1
     1144   sky130_fd_sc_hd__dfxtp_1
        1   sky130_fd_sc_hd__lpflow_inputiso0p_1
       13   sky130_fd_sc_hd__mux2i_1
      848   sky130_fd_sc_hd__nand2_1
      249   sky130_fd_sc_hd__nand3_1
        1   sky130_fd_sc_hd__nand3b_1
       44   sky130_fd_sc_hd__nand4_1
      404   sky130_fd_sc_hd__nor2_1
       34   sky130_fd_sc_hd__nor3_1
        2   sky130_fd_sc_hd__nor4_1
        1   sky130_fd_sc_hd__o2111a_1
       21   sky130_fd_sc_hd__o2111ai_1
        1   sky130_fd_sc_hd__o211a_1
       49   sky130_fd_sc_hd__o211ai_1
        6   sky130_fd_sc_hd__o21a_1
      867   sky130_fd_sc_hd__o21ai_0
        1   sky130_fd_sc_hd__o21ba_2
       18   sky130_fd_sc_hd__o21bai_1
        7   sky130_fd_sc_hd__o221ai_1
      154   sky130_fd_sc_hd__o22ai_1
        1   sky130_fd_sc_hd__o2bb2ai_1
        2   sky130_fd_sc_hd__o311ai_0
        3   sky130_fd_sc_hd__o31ai_1
        1   sky130_fd_sc_hd__o32ai_1
        1   sky130_fd_sc_hd__o41ai_1
       12   sky130_fd_sc_hd__or2_2
        1   sky130_fd_sc_hd__or3_2
        1   sky130_fd_sc_hd__or4_2
       13   sky130_fd_sc_hd__xnor2_1
       32   sky130_fd_sc_hd__xor2_1
</details>

----

After all synthesis steps are concluded, the design’s netlist is produced using,

```bash
write_verilog -noattr ~/Documents/Verilog/Labs/vsdbabysoc_synth.v
```

> [!Note]
> Synthesised Netlist file is saved as `vsdbabysoc_synth.v` and not `vsdbabysoc.synth.v` as specified in `testbench.v` to have consistent and clear naming that aligns with common Verilog file conventions, where underscores are preferred over dots for readability and compatibility with build tools. \
> The `testbench.v` is then edited in accordance with this change to ensure that the correct synthesized netlist file, `vsdbabysoc_synth.v`, is referenced during simulation and verification.

![testbench](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/testbench.png)

---

The netlist should now be successfully saved in the specified folder as shown below.

![netyosys](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/netyosys.png)

**With the synthesis process complete, the design is now optimized, mapped to the target technology, and ready for subsequent steps such as gate-level simulation.**

---

## Gate-Level Simulation of VSDBabySoC

After completing synthesis, the next step is Gate-Level Simulation (GLS), which verifies the functional correctness of the synthesized netlist. Unlike RTL simulation, which uses behavioral Verilog, GLS operates on the gate-level representation generated after synthesis, ensuring that the logical behavior remains consistent with the original design.

To perform GLS, the synthesized netlist (`vsdbabysoc_synth.v`) is simulated using the same testbench that was used for RTL simulation. This helps confirm that synthesis has not introduced any unintended changes.

Firstly, \
Ensure the following files are in the working directory (`Labs` in my case) before compilation.

```
vsdbabysoc_synth.v
avsddac.v
avsdpll.v
primitives.v
sky130_fd_sc_hd.v
```
this is done using,

```bash
cd ~/Documents/Verilog/Labs
cp -r ~/Documents/Verilog/Labs/VSDBabySoC/src/module/avsddac.v .
cp -r ~/Documents/Verilog/Labs/VSDBabySoC/src/module/avsdpll.v .
cp -r ~/Documents/Verilog/Labs/VSDBabySoC/src/gls_model/sky130_fd_sc_hd.v .
cp -r ~/Documents/Verilog/Labs/VSDBabySoC/src/gls_model/primitives.v .
```

Naturally, the synthesized netlist must be compiled together with the testbench using **iverilog**, as shown in the following command,

```bash
iverilog -o ~/Documents/Verilog/Labs/vsdbabysoc_synth.vvp -DPOST_SYNTH_SIM -DFUNCTIONAL -DUNIT_DELAY=#1 -I ~/Documents/Verilog/Labs/VSDBabySoC/src/include -I ~/Documents/Verilog/Labs/VSDBabySoC/src/module -I  ~/Documents/Verilog/Labs/VSDBabySoC/src/gls_model ~/Documents/Verilog/Labs/VSDBabySoC/src/module/testbench.v
```

> [!Note]
> `-DPOST_SYNTH_SIM` | Defines the macro `POST_SYNTH_SIM` to enable post-synthesis simulation mode. \
> `-DFUNCTIONAL`     | Defines the macro `FUNCTIONAL` to select functional simulation mode. \
> `-DUNIT_DELAY=#1`  | Defines the macro `UNIT_DELAY` with value `#1` for unit delay parameterization in simulation \
> `~/Documents/Verilog/Labs/VSDBabySoC/src/include` | Contains header files, parameter definitions, and macros shared across design modules.  \
> `~/Documents/Verilog/Labs/VSDBabySoC/src/module` | Includes the Verilog source files for each functional block of the VSDBabySoC. \
> `~/Documents/Verilog/Labs/VSDBabySoC/src/gls_model` | Holds the synthesized gate-level models and standard cell library files required for gate-level simulation.


Then, to view the waveform,

```bash
vvp vsdbabysoc_synth.vvp
gtkwave post_synth_sim.vcd 
```

![postsynthsim](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/postsynthsim.png)

---

### Waveform of GLS

![postsynthwave](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/postsynthwave.png)

---

**With this, the Gate-Level Simulation of VSDBabySoC is successfully completed.**

---

## Functional Verification: Pre-Synthesis vs. Post-Synthesis Simulation

**Objectives of the Comparison**

- Verify Functional Consistency
    Ensure that the synthesized design produces the same outputs as the RTL design for the same set of input stimuli.

- Check Timing Behavior
    Observe any differences in signal propagation or minor delays introduced by the gate-level implementation.

- Validate Module Interconnections
    Confirm that the connections between CPU, memory, and peripheral modules function correctly after synthesis.

---

![Pre-Synth Wave](https://github.com/navneetprasad1311/vsd-soc-pgrm-w2/blob/main/Part2/Images/waveform.png)
*Pre-synthesis simulation waveform of VSDBabySoC as captured in Week 2*

---

![Post-Synth Wave](https://github.com/navneetprasad1311/vsd-soc-pgrm-w3/blob/main/Part1/Images/postsynthwave.png)
*Post-synthesis simulation waveform of VSDBabySoC*

---

- All functional outputs of the synthesized netlist matched the RTL simulation, confirming that synthesis preserved the intended behavior.

- The comparison validates that the VSDBabySoC design is functionally correct and ready for further implementation steps such as *STA* (Static Timing Analysis).

---

## Summary

The Gate-Level Simulation (GLS) of **VSDBabySoC** confirms that the synthesized netlist faithfully replicates the behavior of the original RTL design. The synthesis process—including mapping to standard cells, optimization, and technology-specific adjustments—was completed successfully, producing a flattened, clean, and fully enumerated netlist.

Post-synthesis simulation verified:  

- **Functional correctness**: All module outputs matched the RTL simulation.  
- **Timing consistency**: Minor gate-level propagation delays were within acceptable limits.  
- **Module interconnections**: CPU, memory, and peripheral modules functioned correctly.

The comparison of **pre-synthesis and post-synthesis waveforms** demonstrates that the design remains stable and predictable after synthesis. With GLS completed, **VSDBabySoC is verified, optimized, and ready for subsequent stages**, such as **Static Timing Analysis (STA)** and place-and-route for physical implementation.

---