
module wrapper(clk, start, sign, aa, bb, out);

	parameter n = 8;
	parameter m = 8;
	parameter pipes = 0;
	parameter initiationInterval = 4;
	parameter mult = 0;
	input clk, start;

	input sign;
	input [n-1:0] aa;
	input [m-1:0] bb;
	output [m+n-1:0] out;

	wire [n-1:0] aa_r;
	wire [m-1:0] bb_r;
	wire start_r;
	wire sign_r;
	wire [m+n-1:0] out_w;

	mcmult2o #(n, m, pipes, initiationInterval, mult) mcmult(.clk(clk), .start(start_r), .sign(sign_r), .a(aa_r), .b(bb_r), .out(out_w) );

	flop #(1) start_f (.in(start), .clk(clk), .out(start_r));
	flop #(1) sign_f (.in(sign), .clk(clk), .out(sign_r));
	flop #(n) aa_f (.in(aa), .clk(clk), .out(aa_r));
	flop #(m) bb_f (.in(bb), .clk(clk), .out(bb_r));
	flop #(m+n) out_f (.in(out_w), .clk(clk), .out(out));

endmodule


