# 5-Stage Pipelined RISC-V Processor (RV32I)

A 32-bit **RISC-V (RV32I)** processor implemented in **Verilog HDL** featuring a classic **5-stage pipeline**, **data forwarding**, **hazard detection**, and **branch handling**. The processor demonstrates the fundamentals of pipelined processor architecture using a modular and synthesizable RTL design.

---

## Features

- 32-bit RV32I Processor
- 5-stage pipelined architecture
  - Instruction Fetch (IF)
  - Instruction Decode (ID)
  - Execute (EX)
  - Memory Access (MEM)
  - Write Back (WB)
- Data Forwarding Unit
- Load-Use Hazard Detection
- Branch Handling with Pipeline Flush
- Separate Instruction and Data Memories (Harvard Architecture)
- Modular Verilog RTL Design
- Synthesizable and Simulation Ready

---
##Architecture
<img width="1448" height="804" alt="Untitled design (1)" src="https://github.com/user-attachments/assets/2ac94082-c5e8-4950-a028-5c76ffa08bfb" />

## Supported Instructions

### Arithmetic
| Instruction | Description |
|-------------|-------------|
| `ADD` | Register Addition |
| `SUB` | Register Subtraction |
| `ADDI` | Immediate Addition |

### Logical
| Instruction | Description |
|-------------|-------------|
| `AND` | Bitwise AND |
| `OR` | Bitwise OR |

### Memory
| Instruction | Description |
|-------------|-------------|
| `LW` | Load Word |
| `SW` | Store Word |

### Branch
| Instruction | Description |
|-------------|-------------|
| `BEQ` | Branch if Equal |

---

## Hazard Handling

### Data Hazards

The processor resolves data hazards using a forwarding unit to eliminate unnecessary pipeline stalls.

- **EX → EX Forwarding:** Forwards the ALU result from the EX/MEM stage to the ALU inputs when the immediately preceding instruction produces a required operand.
- **MEM → EX Forwarding:** Forwards data from the MEM/WB stage when the required value is not available from the EX stage.

### Load-Use Hazard

The forwarding unit resolves most data hazards by bypassing results from later pipeline stages to the Execute stage. However, when an instruction immediately follows a `lw` instruction and depends on the loaded value, forwarding alone cannot resolve the dependency because the data is not yet available.

The Hazard Unit detects this condition and maintains correct execution by:

- Stalling the **PC** and **IF/ID** pipeline register
- Inserting a bubble into the **ID/EX** pipeline register
- Allowing execution to resume normally once the loaded data becomes available through forwarding

This ensures correct execution while maintaining pipeline integrity.

---

## Control Hazards

The processor follows a **Predict-Not-Taken** branch policy.

- Instructions are fetched sequentially assuming the branch is **not taken**.
- If a branch is determined to be **taken** during the Execute stage:
  - The **Program Counter (PC)** is updated with the branch target address.
  - Incorrectly fetched instructions are flushed from the pipeline.
  - Execution resumes from the correct branch target.

## Test Program1

```assembly
# x1 = 10
addi x1, x0, 10

# x2 = 20
addi x2, x0, 20

# x3 = x1 + x2 = 30
add  x3, x1, x2

# x4 = x3 - x1 = 20
sub  x4, x3, x1
# x3 is forwarded from the EX/MEM pipeline register.

# x5 = x3 & x4
and  x5, x3, x4
# x4 is forwarded from the EX/MEM pipeline register.
# x3 is forwarded from the MEM/WB pipeline register.

# x6 = x3 | x4
or   x6, x3, x4
# x4 is forwarded from the MEM/WB pipeline register.

# Store x6 to memory location 0
sw   x6, 0(x0)
# Store data (x6) is forwarded from the EX/MEM pipeline register.

# Load memory[0] into x7
lw   x7, 0(x0)

# Branch not taken
beq  x1, x2, SKIP1
# No pipeline flush.

addi x11, x0, 1

SKIP1:

# Branch taken
beq  x7, x6, TARGET
# PC is redirected to TARGET.
# Instructions in the wrong path are flushed.

addi x12, x0, 99
# Flushed. This instruction is not executed.

TARGET:

# Final arithmetic operation
add  x13, x1, x2

# NOP
addi x0, x0, 0
```
<img width="1221" height="333" alt="Screenshot 2026-07-30 at 7 20 45 PM" src="https://github.com/user-attachments/assets/f6f4b468-b7c6-4674-870b-a5e6659c9b22" />

## Test Program2

```assembly
# Load word from memory[x21 + 40] into x23
lw   x23, 40(x21)

# x24 = x23 & x28
and  x24, x23, x28
# Load-use hazard.
# The Hazard Unit stalls the PC and IF/ID pipeline register and inserts a bubble
# in the ID/EX pipeline register. The loaded value is then forwarded from the
# MEM/WB pipeline register.

# x7 = x22 | x23
or   x7, x22, x23
# x23 is forwarded from the MEM/WB pipeline register.

# Branch if x9 == x18
beq  x9, x18, TARGET
# If the branch is taken, the PC is redirected to TARGET and
# incorrectly fetched instructions are flushed.

# x19 = x23 - x18
sub  x19, x23, x18
# x23 is read from the register file (already written back).

# x24 = x6 - x19
sub  x24, x6, x19
# x19 is forwarded from the EX/MEM pipeline register.

TARGET:

# x23 = x19 + x20
add  x23, x19, x20
# x19 is forwarded from the EX/MEM pipeline register.

# NOP
addi x0, x0, 0
```
<img width="1168" height="333" alt="Screenshot 2026-07-30 at 6 18 34 PM" src="https://github.com/user-attachments/assets/e1c0266e-2d7f-4617-b229-e61d07d7e383" />

## Future Improvements

- Support for the complete RV32I instruction set
- Jump instructions (`JAL`, `JALR`)
- Additional branch instructions (`BNE`, `BLT`, `BGE`, etc.)
- RV32M extension (Multiplication and Division)
- Branch prediction
- Instruction and Data caches
- UART peripheral


---

## Author

**Sachin Nagaraddi**

B.Tech in Electronics and Communication Engineering  
National Institute of Technology Karnataka (NITK), Surathkal
