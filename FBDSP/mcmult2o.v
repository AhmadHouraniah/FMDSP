// Multi-cycle multiplier
// Performs a 4x4 mult in 1 cycle
// Performs an 4x8 mult in 2 cycles
// Performs an 8x8 mult in 4 cycles
// Supports signed muliplications based on 'sign' input
module mcmult2o(a, b, out, start, sign, clk);

parameter n = 8;
parameter m = 8;
parameter pipes = 0;
parameter initiationInterval = 2;
parameter mult = 0;


input sign;
input [7:0] a;
input [7:0] b;
input clk, start;
output [15:0] out;
wire start_r1, start_r2, start_r3;
flop #(1) flop_start_r1 (.in(start), .clk(clk), .out(start_r1));
flop #(1) flop_start_r2 (.in(start_r1), .clk(clk), .out(start_r2));
flop #(1) flop_start_r3 (.in(start_r2), .clk(clk), .out(start_r3));

wire [4:0] mult_in1 = (start|start_r1)? {1'b0, a[3:0]} : {a[7]&sign, a[7:4]};
wire [4:0] mult_in2 = start? {1'b0,b[3:0]} : start_r1? {b[7]&sign, b[7:4]} : start_r2? {1'b0, b[3:0]} : {b[7]&sign, b[7:4]};
wire [10:0] mult_out1, mult_out2;

DW02_multp #(4+1,4+1,12,0) multp(mult_in1, mult_in2, sign, {nc1, mult_out1}, {nc4, mult_out2});

assign comp_in1 =  mult_out1;
assign comp_in2 =  mult_out2;
assign comp_in3 = start? 0 : start_r1? {{4{1'b0}}, final_sum_prev[7:4]} : start_r2? final_sum_prev[9:0]: {{3{final_sum_prev[9]}}, final_sum_prev[9:4]};
wire [10:0] comp_in1, comp_in2, comp_in3;
wire [11:0] comp_out1, comp_out2;

compressor #(11) comp ( comp_in1, comp_in2, comp_in3, comp_out1, comp_out2);

wire [11:0] final_sum = comp_out1 + comp_out2;
wire [11:0] final_sum_prev;
flop #(12) flop_final_sum (.in(final_sum), .clk(clk), .out(final_sum_prev));

wire [3:0] res0, res1;
flop #(4) flop_res0 (.in(start? final_sum[3:0] : res0), .clk(clk), .out(res0));
flop #(4) flop_res1 (.in(start_r2? final_sum[3:0] : res1), .clk(clk), .out(res1));
assign out = start? final_sum : start_r1 ? {final_sum[7:0], res0} : {final_sum[7:0], res1, res0};

endmodule