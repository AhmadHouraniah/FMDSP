This directory a DSP implementation.
The DSP supports the following operations:

1-cycle N/2xN/2 + N multiply-add

1-cycle N/2xN/2 multiply-accumulate

2-cycle N/2xN + N multiply-add
2-cycle N/2xN multiply-accumulate

4-cycle NxN + N multiply-add
4-cycle NxN multiply-accumulate

For MAC operations, there is a built it barrel shifter where we set the direction and bits to be shifted
The shift operation is applied on the stored data.

Note: N should be an odd number, and we use the ceil of N/2 in our operations (e.g. 4c- 33x33, 2c-33x17, 1c-17x17 ) 
