module DSP_model(clk, start, mode, aa, bb, cc, mac, out, barrel_shifter, compare_res);

	parameter N = 9;
		localparam N2 = N/2;
	parameter M = 9;
		localparam M2 = M/2;
	parameter pipes = 0;
	parameter mult = 0;
	input clk, start;
    output reg compare_res;
	input [1:0] mode;
	input mac;
	input [1:0] barrel_shifter;
	input [N-1:0] aa;
	input [M-1:0] bb;
	input [N+M-1:0] cc;
	reg mac_prev;
	output reg signed [N+M-1:0] out;

	reg signed [N+M-1:0] outPrev;
	reg start_r1, start_r2, start_r3, start_r4, start_r5;

	reg signed [N+M-1:0] res0;

	
    always@* begin
		compare_res =  (~mode[1]&~mode[0]&start) | (~mode[1]&mode[0]&start_r1)| (mode[1]&~mode[0]&start_r3);
		out = outPrev;
		if(mode == 2'b00) begin
			if(start) begin
				res0 =  $signed(aa[N2 :0])*$signed(bb[M2 :0]) ;
				if(mac&mac_prev)
                    out = res0 + ({{(N+M){outPrev[N+M-1]}}, outPrev} >> barrel_shifter);
				else
					out = res0 + cc;
			end
			else
				out = 0;
		end
		else if (mode ==2'b01) begin
			if(start) begin
				res0 = $signed(aa[N2:0])*$signed(bb[M -1 :0]);
				if(mac&mac_prev) 
                    out = res0 + ({{(N+M){outPrev[N+M-1]}}, outPrev} >> barrel_shifter);
				else
					out = res0 + cc;
			end
		end
		else if(mode == 2'b10) begin
			if(start_r3) begin
				res0 = $signed(aa[N-1:0])*$signed(bb[M-1:0]);
				if(mac&mac_prev)
                    out = res0 + ({{(N+M){outPrev[N+M-1]}}, outPrev} >> barrel_shifter);
				else
					out = res0 + cc;
			end
		end
    end

	always@(posedge clk) begin
		mac_prev <= mac;
		outPrev <= out;
		start_r1 <= start;
		start_r2 <= start_r1;
		start_r3 <= start_r2;
	end

endmodule


