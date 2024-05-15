Inputs 

M-bit aa multiplicand
N-bit bb multiplicand

start, this is a control signal for mulplication signs
start should be pulsed in the 1st cycle of the operation.
If start is constantly 1 the DSP operates in mode 1
controls whether we do signed multiplications

A mode input might be needed to support signed mults for modes 1 and 2 (2 bits possibly)

This architecture supports signed multiplications.
An MxN DSP can the following multiplications
1- M/2 x N/2 Multiplications in 1 cycle
2- M   x N/2 Multiplications in 2 cycles
3- M   x N   Multiplications in 4 cycles

4- MAC operations (for all modes?)
