# FMDSP: Folded Multiplier DSP Block

Open-source DSP Block IP Generator intended for FPGAs.

## Project Structure

The project is organized into the following sections:

- **design/**: Contains the Verilog source code for the DSP designs and shared cells.
  - `FB32DSP/`: 32-bit DSP design.
  - `FB42DSP/`: 42-bit DSP design.
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

## Building and Verification

To run simulations, navigate to the respective verification directory:

```bash
cd verification/FB32DSP
make simulate
```

This will automatically build the `generate_PPM` tool from the `mult-tree` submodule and run the simulation using Icarus Verilog.
