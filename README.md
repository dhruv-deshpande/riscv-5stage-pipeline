# 32-bit RISC-V 5-Stage Pipelined Processor (RV32I)

![Verilog](https://img.shields.io/badge/Language-Verilog%20%7C%20SystemVerilog-blue)
![Simulation](https://img.shields.io/badge/Simulation-GTKWave-green)

## 1. Overview
This repository contains the RTL design and verification of a 32-bit RISC-V microprocessor implementing the RV32I Base Integer Instruction Set. The processor features a classic 5-stage in-order pipeline (Fetch, Decode, Execute, Memory, Writeback) with full dynamic hazard resolution and data forwarding.



## 2. Microarchitecture & Features
* **Architecture:** 32-bit RISC-V (RV32I)
* **Pipeline Stages:**
  * **IF (Instruction Fetch):** PC update logic and instruction memory interface.
  * **ID (Instruction Decode):** Register file read, control unit decoding, and immediate generation.
  * **EX (Execute):** ALU operations, branch target calculation.
  * **MEM (Memory):** Data memory read/write interface.
  * **WB (Writeback):** Register file writeback.
* **Hazard Resolution:** * Data hazards are handled via forwarding paths from EX/MEM and MEM/WB pipeline registers.
  * Load-use hazards trigger a pipeline stall via the centralized Hazard Unit.
  * Control hazards (branches/jumps) flush the IF and ID stages.

## 3. Directory Structure
The repository is modularized by pipeline stage. Each directory contains the synthesizable RTL, component dependencies, SystemVerilog testbenches, and simulation waveforms.

```text
RISCV-5STAGE-PIPELINE/
├── fetch_cycle/       # IF stage RTL and TB
├── decode_cycle/      # ID stage RTL and TB
├── execute_cycle/     # EX stage RTL and TB
├── memory_cycle/      # MEM stage RTL and TB
├── writeback_cycle/   # WB stage RTL and TB
├── hazard_unit/       # Hazard detection and forwarding logic
└── pipeline_top/      # Top-level integration and full system TB
