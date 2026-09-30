# DESIGN-OF-A-32-BIT-ALU-USING-OPEN-SOURCE-TOOLS

An ALU is the core brain inside a computer's CPU that does all the math and logic processing. This specific design can handle large 32-bit numbers for performing addition, subtraction, Bitwise AND,OR and XOR operations , fast shifting using Barrel shifters, and advanced multiplication using Booth multiplier.

# Project Architecture

* `alu_main_code.v` – The primary ALU controller that integrates all computational submodules.
* `boothmultiplier.v` – Submodule executing signed multiplication.
* `barrelshifter_code.v` – Submodule executing low-latency data bit-shifting.
* `alu_testcode.v` – The top-level verification environment (`alu_32_bit_tb`) containing the main execution stimuli.
* `signal.gtkw` – Preserved GTKWave interface configurations for targeted signal monitoring.
* `run.ys` – A script file used by Yosys to synthesize the design and convert the Verilog code into logic gates.

# Compilation & Simulation

This project is built in Visual studio code and simulated using Icarus Verilog, visualized through GTKWave and synthesized in Yosys through EDA playground.

# 1. Compile the Hardware Design
Run the compilation block by referencing the top-level testbench module:
```
iverilog -o unified_system.out -s alu_32_bit_tb alu_main_code.v alu_testcode.v barrelshifter_code.v boothmultiplier.v
```

# 2. Run the Simulation Execution
Execute the compiled design using VVP to generate the target waveform database (`.vcd` file):
```
vvp unified_system.out
```

# 3. Open Waveforms in GTKWave
Analyze signal transitions, register behaviors, and flag configurations directly via the timing analyzer tool:
```
gtkwave alu_system_wave.vcd
```
# 4. Synthesize with Yosys (EDA Playground): 
Select Yosys under Tools, check Run Synthesis, and click Run.


