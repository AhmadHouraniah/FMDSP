module DSP_model(clk, start, sign, aa, bb, out, compare_res);

	parameter n = 8;
	parameter m = 8;
	parameter pipes = 0;
	parameter initiationInterval = 4;
	parameter mult = 0;
	input clk, start;
    output compare_res;
	input sign;
	input [n-1:0] aa;
	input [m-1:0] bb;
	output [m+n-1:0] out;

	wire [n-1:0] aa_r;
	wire [m-1:0] bb_r;
	wire start_r1, start_r2, start_r3, start_r4;
	wire sign_r;
	reg [m+n-1:0] out_w;

	flop #(1) start1_f (.in(start), .clk(clk), .out(start_r1));
	flop #(1) start2_f (.in(start_r1), .clk(clk), .out(start_r2));
	flop #(1) start3_f (.in(start_r2), .clk(clk), .out(start_r3));
	flop #(1) start4_f (.in(start_r3), .clk(clk), .out(start_r4));
	flop #(1) sign_f (.in(sign), .clk(clk), .out(sign_r));
	flop #(n) aa_f (.in(aa), .clk(clk), .out(aa_r));
	flop #(m) bb_f (.in(bb), .clk(clk), .out(bb_r));
	flop #(m+n) out_f (.in(out_w), .clk(clk), .out(out));

    assign compare_res = start_r1 | start_r2 | start_r4;

    always@* begin
        if(sign_r) begin
            if(start_r1)
                out_w = $signed(aa[n/2 -1:0])*$signed(bb[m/2 -1:0]);
            else if(start_r2)
                out_w = $signed(aa[n-1:0])*$signed(bb[m/2 -1:0]);
            else
                out_w = $signed(aa[n-1:0])*$signed(bb[m-1:0]);
        end
        else begin
            if(start_r1)
                out_w = (aa[n/2 -1:0])*(bb[m/2 -1:0]);
            else if(start_r2)
                out_w = (aa[n-1:0])*(bb[m/2 -1:0]);
            else
                out_w = (aa[n-1:0])*(bb[m-1:0]);
        end
    end

endmodule


