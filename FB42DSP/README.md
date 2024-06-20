# DSP Implementation Module

This directory contains a versatile DSP (Digital Signal Processing) implementation. The DSP module supports a variety of operations optimized for different computational needs, including multiply-add, multiply-accumulate, and accumulation operations.

## Supported Operations

The DSP supports the following operations:

- **1-cycle Operations:**
  - N/2 x N/2 + 2N Multiply-Add
  - N/2 x N/2 Multiply-Accumulate
  - 2N Accumulate

- **2-cycle Operations:**
  - N/2 x N + 2N Multiply-Add
  - N/2 x N Multiply-Accumulate

- **4-cycle Operations:**
  - N x N + 2N Multiply-Add
  - N x N Multiply-Accumulate

## Features

### Pipelining

The DSP module supports pipelining the final addition. The number of pipeline stages can be specified, allowing for flexibility and optimization based on the specific application requirements. The number of stages is determined by the parameter `pipeline_stages`, where the actual number of stages is calculated as `2^pipeline_stages`.

### Barrel Shifter

Included within the DSP module is a barrel shifter that shifts the stored data. This feature is particularly useful for MAC (Multiply-Accumulate) and accumulation operations, enabling efficient data manipulation and processing.

## Important Notes

- **Odd Number Width (N):** The width `WIDTH` should be an odd number. The operations use the ceiling of `WIDTH/2` in the calculations. For example, when `WIDTH= 33`:
  - 4-cycle operation: 33 x 33
  - 2-cycle operation: 33 x 17
  - 1-cycle operation: 17 x 17

By adhering to these specifications, the DSP module ensures optimal performance and flexibility for various digital signal processing tasks.
