# femtoRV32

## Milestone 1 - Single Cycle Implementation (Full RISC-V ISA Support)

### Supported Instructions List

- [x] LUI
- [x] AUIPC
- [x] JAL
- [x] JALR
- [x] BEQ
- [x] BNE
- [x] BLT
- [x] BGE
- [x] BLTU
- [x] BGEU
- [x] LB
- [x] LH
- [x] LW
- [x] LBU
- [x] LHU
- [x] SB
- [x] SH
- [x] SW
- [x] ADDI
- [x] SLTI
- [x] SLTIU
- [x] XORI
- [x] ORI
- [x] ANDI
- [x] SLLI
- [x] SRLI
- [x] SRAI [needs more testing]
- [x] ADD
- [x] SUB
- [x] SLL
- [x] SLT
- [x] SLTU
- [x] XOR
- [x] SRL
- [x] SRA [needs more testing]
- [x] OR
- [x] AND
- [x] \* FENCE
- [x] \* FENCE.TSO
- [x] \* PAUSE
- [x] \* ECALL
- [x] \* EBREAK

\* these instructions are implemented as a halting behaviour where the PC doesn't get updated anymore.

## Milestone 2 - Pipelined with Full-Forwarding Implementation (Full RISC-V ISA Support)

#### Pipelined Implementation
- [x] Pipeline Registers
- [x] Forwarding Unit
- [x] Hazard Detection Unit
- [x] Byte-addressable memory
- [x] Combined Instruction & Data Memory
- [ ] ~Issuing an instruction every 2 cycles to avoid structural hazards.~
- [x] Handle Structural Hazards by stalling fetching a new instruction for one cycle when there is a data memory read or write.
