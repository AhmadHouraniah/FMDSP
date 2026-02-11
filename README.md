# FMDSP: Folded Multiplier DSP Block

Open-source DSP Block IP Generator intended for FPGAs.

## Project Structure

The project is organized into the following sections:

- **design/**: Contains the Verilog source code for the DSP designs and shared cells.
  - `FB32DSP/`: Area-efficient DSP Block.
  - `FB42DSP/`: High-performance DSP Block.
  - `cells/`: Shared arithmetic components (adders, multipliers, etc.).
  
- **verification/**: Contains testbenches and Makefiles for simulation.
  - `FB32DSP/`: Verification environment for FB32DSP.
  - `FB42DSP/`: Verification environment for FB42DSP.
  
- **implementation/**: Contains configuration files for OpenLane flow.
  - `FB32DSP/`: OpenLane config, pin order, and timing constraints.
  - `FB42DSP/`: OpenLane config, pin order, and timing constraints.

- **mult-tree/**: Submodule for generating partial product reduction trees.

## Designs

### FB32DSP
Parametric Folded DSP block with feedback loop. [Documentation](docs/FB32DSP.md)

### FB42DSP
Parametric Folded DSP block with pipelining support. [Documentation](docs/FB42DSP.md)

## Setup

To set up the project (initialize submodules, install PDK, and pull Docker image), run:

```bash
make
```

## Usage

### Simulation

To run simulations, for example:

```bash
cd verification/FB32DSP
make simulate
```

### Implementation

To harden the design, for example:

```bash
cd implementation/FB32DSP
make harden
```
