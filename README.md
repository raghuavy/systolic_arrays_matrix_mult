# systolic_arrays_matrix_mult

> 2×2 matrix multiplier implemented using a systolic array architecture in SystemVerilog.

---

## Overview

This project implements a 2×2 integer matrix multiplier using a **systolic array** approach. Rather than instantiating four independent parallel MACs, data flows through a grid of Processing Elements (PEs) in a staggered wave over multiple clock cycles — matching the architecture used in real ML accelerators like Google's TPU.

Given input matrices **A** and **B**, the module computes **C = A × B**:

```
C[0][0] = A[0][0]*B[0][0] + A[0][1]*B[1][0]
C[0][1] = A[0][0]*B[0][1] + A[0][1]*B[1][1]
C[1][0] = A[1][0]*B[0][0] + A[1][1]*B[1][0]
C[1][1] = A[1][0]*B[0][1] + A[1][1]*B[1][1]
```

---

## File Structure

```
├── mat_mul.sv          # Top-level systolic matrix multiplier
├── tb_mat_mul.sv       # Testbench
└── README.md
```

---

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Active-low synchronous reset |
| `matA[1:0][1:0][N-1:0]` | input | 2×2×N bits | Input matrix A |
| `matB[1:0][1:0][N-1:0]` | input | 2×2×N bits | Input matrix B |
| `mat_out[1:0][1:0][2*N-1:0]` | output | 2×2×2N bits | Result matrix C |

Default `N = 8` (8-bit inputs, 16-bit outputs).

---

## Systolic Array Architecture

Instead of 4 dedicated independent MACs, the design uses 4 PE accumulators arranged in a 2×2 grid. Each cycle, a new partial product is computed and accumulated, with data flowing right (A) and down (B) through the array in a staggered wave:

```
A row 0 ──► PE(0,0) ──► PE(0,1)
               │              │
A row 1 ──► PE(1,0) ──► PE(1,1)
               ▲              ▲
           B col 0        B col 1
```

### Cycle-by-cycle breakdown

| Cycle | PE(0,0) | PE(0,1) | PE(1,0) | PE(1,1) |
|-------|---------|---------|---------|---------|
| 0 | A[0][0]×B[0][0] | — | — | — |
| 1 | +A[0][1]×B[1][0] | A[0][0]×B[0][1] | A[1][0]×B[0][0] | — |
| 2 | done → C[0][0]=50 | +A[0][1]×B[1][1] | +A[1][1]×B[1][0] | A[1][0]×B[0][1] |
| 3 | — | done → C[0][1]=43 | done → C[1][0]=22 | +A[1][1]×B[1][1] |
| 4 | — | — | — | done → C[1][1]=19 |

The staggered firing is what makes it systolic — each PE activates one cycle after its top-left neighbor.

---

## Simulation Results

Verified in Vivado Behavioral Simulation across multiple test cases.

**Test 1 — waveform verification:**
```
A = | 4  3 |    B = | 8  7 |
    | 2  1 |        | 6  5 |

C = | 50  43 |   (0x0032, 0x002B)
    | 22  19 |   (0x0016, 0x0013)
```

**Test 2 — identity × identity = identity** 

**Test 3 — zero matrix = all zeros** 

**Test 4 — larger values:**
```
A = | 15  10 |    B = | 20  15 |
    | 12   8 |        |  5  25 |

C = | 350  475 |   (0x015E, 0x01DB)
    | 280  380 |   (0x0118, 0x017C)
```

### Waveform
![Simulation Waveform](https://github.com/user-attachments/assets/ee0a5698-68a0-43ac-a8b2-367854a3d580)

### Synthesized schematic
![Netlist](https://github.com/user-attachments/assets/6947829f-1030-47b9-b645-a59e94837e5f)

### Schematic
![Schematic](https://github.com/user-attachments/assets/7cc532c3-aa02-41b2-9f85-085716d3c007)

---

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `N` | `8` | Bit width of input elements. Output is `2*N` bits. |

---

## How It Differs from a Parallel Multiplier

| | Parallel MAC | This design (Systolic) |
|---|---|---|
| PEs | 4 independent units | 4 PEs, data flows between them |
| Latency | N cycles (bit-serial) | 5 cycles fixed |
| Data routing | each MAC fed directly from inputs | A flows right, B flows down |
| Scalability | exponential resource growth | linear scaling to N×N |

---
