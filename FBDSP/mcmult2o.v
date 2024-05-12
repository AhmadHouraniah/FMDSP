module wrapper(clk, start, aa, bb, mode, out);

	parameter n = 8;
	parameter m = 8;
	parameter pipes = 0;
	parameter initiationInterval = 4;
	parameter mult = 0;
	input clk, start;

    input [1:0] mode;
	input [n-1:0] aa;
	input [m-1:0] bb;
	output [m+n-1:0] out;

	wire [n-1:0] aa_r;
	wire [m-1:0] bb_r;
	wire start_r;
	wire [1:0] mode_r;
	wire [m+n-1:0] out_w;

	mcmult2o #(n, m, pipes, initiationInterval, mult) mcmult(.clk(clk), .start(start_r), .mode(mode_r), .a(aa_r), .b(bb_r), .out(out_w) );

	flop #(1) start_f (.in(start), .clk(clk), .out(start_r));
	flop #(2) mode_f (.in(mode), .clk(clk), .out(mode_r));
	flop #(n) aa_f (.in(aa), .clk(clk), .out(aa_r));
	flop #(m) bb_f (.in(bb), .clk(clk), .out(bb_r));
	flop #(m+n) out_f (.in(out_w), .clk(clk), .out(out));

endmodule




// Multi-cycle multiplier
// Performs a 4x4 mult in 1 cycle
// Performs an 4x8 mult in 2 cycles
// Performs an 8x8 mult in 4 cycles


// MAC_1, 2, 4 modes 

module mcmult2o(a, b, out, start, clk, mode);


    parameter n = 9;
    parameter m = 9;
    parameter pipes = 0;
    parameter initiationInterval = 2;
    parameter mult_type = 0;

    input [1:0] mode;
    input [n-1:0] a;
    input [m-1:0] b;
    input clk, start;
    output [17:0] out;
    wire start_r1, start_r2, start_r3;
    flop #(1) flop_start_r1 (.in(start), .clk(clk), .out(start_r1));
    flop #(1) flop_start_r2 (.in(start_r1), .clk(clk), .out(start_r2));
    flop #(1) flop_start_r3 (.in(start_r2), .clk(clk), .out(start_r3));

    wire [4:0] mult_in1 = 
        ~mode[1]? a[4:0]
        : (start|start_r1)? {1'b0, a[3:0]} : {a[7], a[7:4]};

    wire [4:0] mult_in2 = 
          ~mode[1]&~mode[0]? b[4:0]
        : ~mode[1]&mode[0]? start? {1'b0,b[3:0]} : {b[7], b[7:4]}
        : start? {1'b0,b[3:0]} : start_r1? {b[7], b[7:4]} : start_r2? {1'b0, b[3:0]} : {b[7], b[7:4]};

    wire [9:0] mult_out1, mult_out2;

    mult #(5, 5, mult_type) ppm (.a(mult_in1), .b(mult_in2), .out1(mult_out1), .out2(mult_out2));

    assign comp_in1 =  mult_out1;
    assign comp_in2 =  mult_out2;
    assign comp_in3 = start? 0 : start_r1? {{4{1'b0}}, final_sum_prev[7:4]} : start_r2? final_sum_prev[9:0]: {{3{final_sum_prev[9]}}, final_sum_prev[9:4]};
    wire [9:0] comp_in1, comp_in2, comp_in3;
    wire [10:0] comp_out1, comp_out2;

    compressor #(10) comp ( comp_in1, comp_in2, comp_in3, comp_out1, comp_out2);

    wire [9:0] final_sum = comp_out1 + comp_out2;
    wire [9:0] final_sum_prev;
    flop #(11) flop_final_sum (.in(final_sum), .clk(clk), .out(final_sum_prev));

    wire [3:0] res0, res1;
    flop #(4) flop_res0 (.in(start? final_sum[3:0] : res0), .clk(clk), .out(res0));
    flop #(4) flop_res1 (.in(start_r2? final_sum[3:0] : res1), .clk(clk), .out(res1));
    assign out = start? final_sum : start_r1 ? {final_sum[7:0], res0} : {final_sum[7:0], res1, res0};

endmodule