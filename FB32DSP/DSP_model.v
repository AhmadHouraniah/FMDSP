module DSP_model(clk, start, mode, aa, bb, out, compare_res);

	parameter n = 9;
	parameter m = 9;
	parameter pipes = 0;
	parameter initiationInterval = 4;
	parameter mult = 0;
	input clk, start;
    output compare_res;
	input [1:0] mode;
	input [n-1:0] aa;
	input [m-1:0] bb;
	output [m+n-1:0] out;

	wire [n-1:0] aa_r;
	wire [m-1:0] bb_r;
	wire start_r1, start_r2, start_r3, start_r4, start_r5;
	wire [1:0] mode_r;
	reg [m+n-1:0] out_w;
	wire [m+n-1:0] out_w2;

	flop #(1) start1_f (.in(start), .clk(clk), .out(start_r1));
	flop #(1) start2_f (.in(start_r1), .clk(clk), .out(start_r2));
	flop #(1) start3_f (.in(start_r2), .clk(clk), .out(start_r3));
	flop #(1) start4_f (.in(start_r3), .clk(clk), .out(start_r4));
	flop #(1) start5_f (.in(start_r4), .clk(clk), .out(start_r5));
	flop #(2) mode_f (.in(mode), .clk(clk), .out(mode_r));
	flop #(n) aa_f (.in(aa), .clk(clk), .out(aa_r));
	flop #(m) bb_f (.in(bb), .clk(clk), .out(bb_r));
	flop #(m+n) out1_f (.in(out_w), .clk(clk), .out(out_w2));
	flop #(m+n) out2_f (.in(out_w2), .clk(clk), .out(out));

    assign compare_res =start_r2| start_r3| start_r5;

	wire [9:0] out_0 = out_w[9:0];
	wire [14:0] out_1 = out_w[14:0];
	
    always@* begin
		out_w = {m+n{1'b0}};
		if(mode_r == 2'b00)
			if(start_r1)
				out_w[9:0] = $signed(aa[4 :0])*$signed(bb[4 :0]);
		else if (mode_r ==2'b01)
			out_w[14:0] = $signed(aa[4:0])*$signed(bb[8 :0]);
		else
			out_w = $signed(aa[n-1:0])*$signed(bb[m-1:0]);
    end

endmodule


