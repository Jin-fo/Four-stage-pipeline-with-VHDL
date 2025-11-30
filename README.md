# Pipelined SIMD multimedia unit Design with VHDL

## Prokect Description
This project focuses on the structural and behavioral design of a four-stage pipelined Multimedia Unit (MMU). The design is implemented using VHDL, a hardware description language, to model the MMU with a reduced subset of multimedia instructions, similar to those in Sony Cell SPU and Intel SSE architectures. 

The complete 4-stage pipelines is designed at the register transfer level (RTL) developed in a structural manner with several modules operating simultaneously. Each stage of the pipeline is defined by a module that is developed behaviorally with inter-stage register. Verification of each module will be done individually with their respective self-checking test benches. This will ensure the functional correctness of all stages of the pipeline prior to full system integration of the 4-stage MMU.  

The complete top-level MMU model is then instantiated with another test bench to validate the completeness of the four-stage pipeline, where each instruction will cycle through all stages of the pipeline. The resulting outputs will demonstrate the operational behavior and status of each pipeline stage during execution. 
![System diagram](Block_Diagram.png)
> **Note:** Diagram complete 4-stages (Instruction Fetch, Register File, ALU, and Write-back) of the complete pipeline, emphasizing the MMU stage of the ALU.

