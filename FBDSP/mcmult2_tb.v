`timescale 1ns / 1ps

module mcmult2_tb;

	parameter n = 8;
	parameter m = 8;
	parameter pipes = 0;
	//only works for 2 and 3, requires modifications for larger intervals
	parameter initiationInterval = 4;
	//1:PCST, 0:DW02
	parameter mult = 1;
	

	parameter testCount = 200;
parameter clkLength = 10;
	parameter cycleLength = 2*clkLength;

	integer error_count=0;
	// Inputs
	reg sign;
	reg clk;
	reg start;
	reg [n-1:0] aa, aaReg1, aaReg2, aaReg3, aaReg4, aaReg5, aaReg6, aaReg7, aaReg8, aaReg9;
	reg [m-1:0] bb, bbReg1, bbReg2, bbReg3, bbReg4, bbReg5, bbReg6, bbReg7, bbReg8, bbReg9;
	reg start_reg1, start_reg2, start_reg3, start_reg4;
	reg start_reg5, start_reg6, start_reg7, start_reg8, start_reg9, start_reg10;

	integer ii;
	// Outputs
	wire [m+n-1:0] out;

	reg [m+n-1:0] temp;

	// Instantiate the Unit Under Test (UUT)
    wire [31:0] nc;
    
	wrapper #(n,m, pipes, initiationInterval, mult)	uut (
	.clk(clk),
	.start(start),
	.sign(sign),
	.out({out}),
	.aa(aa),
	.bb(bb)
	);


	always #clkLength clk=~clk;

	initial begin
		$dumpvars;
		sign=0;
		clk = 0;
		start <= 0;
		aa <= 0;
		bb <= 0;

		#211;

		for(ii=0; ii<testCount/4; ii=ii+1) begin
			repeat(initiationInterval-1)
				#cycleLength;
			start <=1;
			aa <= {2'b00, {(1+n/32){$random}}};
			bb <= {2'b00, {(1+m/32){$random}}};
			#cycleLength;
			start <= 0;
		end


		for(ii=0; ii<testCount/4; ii=ii+1) begin
			repeat(initiationInterval-1)
				#cycleLength;
			start <=1;
			aa <= {2'b01, {(1+n/32){$random}}};
			bb <= {2'b01, {(1+m/32){$random}}};
			#cycleLength;
			
			start <= 0;
		end

		for(ii=0; ii<testCount/4; ii=ii+1) begin
			repeat(initiationInterval-1)
				#cycleLength;
			start =1;
			aa = {2'b10, {(1+n/32){$random}}};
			bb = {2'b10, {(1+m/32){$random}}};
			#cycleLength;
			start = 0;
		end

		for(ii=0; ii<testCount/4; ii=ii+1) begin
			repeat(initiationInterval-1)
				#cycleLength;
			start =1;
			aa = {2'b11, {(1+n/32){$random}}};
			bb = {2'b11, {(1+m/32){$random}}};
			#cycleLength;
			start = 0;
			end
			#200 $finish;
		end



	always@(posedge clk) begin
		start_reg1	<= #(cycleLength/10)  start;
		start_reg2 	<= #(cycleLength/10)  start_reg1;
		start_reg3 	<= #(cycleLength/10)  start_reg2;
		start_reg4 	<= #(cycleLength/10)  start_reg3;
		start_reg5 	<= #(cycleLength/10)  start_reg4;
		start_reg6 	<= #(cycleLength/10)  start_reg5;
		start_reg7 	<= #(cycleLength/10)  start_reg6;
		start_reg8 	<= #(cycleLength/10)  start_reg7;
		start_reg9 	<= #(cycleLength/10)  start_reg8;
		start_reg10 <= #(cycleLength/10)  start_reg9;
		aaReg1	   	<= #(cycleLength/10)  aa;
		aaReg2		<= #(cycleLength/10)  aaReg1;
		aaReg3		<= #(cycleLength/10)  aaReg2;
		aaReg4		<= #(cycleLength/10)  aaReg3;
		aaReg5		<= #(cycleLength/10)  aaReg4;
		aaReg6		<= #(cycleLength/10)  aaReg5;
		aaReg7		<= #(cycleLength/10)  aaReg6;
		aaReg8		<= #(cycleLength/10)  aaReg7;
		aaReg9		<= #(cycleLength/10)  aaReg8;
		bbReg1	  	<= #(cycleLength/10)  bb;
		bbReg2		<= #(cycleLength/10)  bbReg1;
		bbReg3		<= #(cycleLength/10)  bbReg2;
		bbReg4		<= #(cycleLength/10)  bbReg3;
		bbReg5		<= #(cycleLength/10)  bbReg4;
		bbReg6		<= #(cycleLength/10)  bbReg5;
		bbReg7		<= #(cycleLength/10)  bbReg6;
		bbReg8		<= #(cycleLength/10)  bbReg7;
		bbReg9		<= #(cycleLength/10)  bbReg8;
	end



	generate
		case (pipes+initiationInterval+1)
			1: begin
				always@(posedge start_reg3) begin
					#(cycleLength/10);
					if(sign) begin
						temp = bbReg3*aaReg3;
						if(aaReg3*bbReg3 == out)
							$display("correct ");
						else
							$display("%d is the wrong output	  %d * %d = %d",out, bbReg3, aaReg3, temp);
					end else begin
						temp = $signed(bbReg3)*$signed(aaReg3);
						if(temp == out)
							$display("correct ");
						else
							$display("%d is the wrong output	  %d * %d = %d",$signed(out), $signed(bbReg3), $signed(aaReg3), $signed(temp));

					end
				end
			end
			2: begin
				always@(posedge start_reg4) begin
					#(cycleLength/10);
					temp = bbReg4*aaReg4;
					if(aaReg4*bbReg4 == out)
						$display("correct ");
					else
						$display("%d is the wrong output	  %d * %d = %d",out, bbReg4, aaReg4, temp);
				end
			end
			3: begin
				always@(posedge start_reg5) begin
					#(cycleLength/10);
					temp = bbReg5*aaReg5;
					if(aaReg5*bbReg5 == out)
						$display("correct ");
					else
						$display("%d is the wrong output	  %d * %d = %d",out, bbReg5, aaReg5, temp);
				end

			end
			4: begin
				always@(posedge start_reg6) begin
					#(cycleLength/10);
					temp = bbReg6*aaReg6;
					if(aaReg6*bbReg6 == out)
						$display("correct ");
					else
						$display("%d is the wrong output	  %d * %d = %d",out, bbReg6, aaReg6, temp);
				end
			end
			5: begin
				always@(posedge start_reg5) begin
					#(cycleLength/10);
					if(sign==0) begin
						temp = bbReg5*aaReg5;
						if(aaReg5*bbReg5 == out)
							$display("correct");
						else
							$display("%d is the wrong output	  %d * %d = %d",out, bbReg5, aaReg5, temp);
					end else begin
						temp = $signed(bbReg5)*$signed(aaReg5);
						if(temp == out)
							$display("%d is the correct output	  %d * %d = %d",$signed(out), $signed(bbReg5), $signed(aaReg5), $signed(temp));
						else begin
							$display("%h is the wrong output	  %d * %d = %h",$signed(out), $signed(bbReg5), $signed(aaReg5), $signed(temp));
							error_count = error_count +1;
						end
					end
				end
			end
			6: begin
				always@(posedge start_reg9) begin
					#(cycleLength/10);
					temp = bbReg8*aaReg8;
					if(aaReg8*bbReg8 == out)
						$display("correct ");
					else
						$display("%d is the wrong output	  %d * %d = %d",out, bbReg8, aaReg8, temp);
				end
			end
			7: begin
				always@(posedge start_reg10) begin
					#(cycleLength/10);
					temp = bbReg9*aaReg9;
					if(aaReg9*bbReg9 == out)
						$display("correct ");
					else
						$display("%d is the wrong output	  %d * %d = %d",out, bbReg9, outReg9, temp);
				end
			end
		endcase
	endgenerate

endmodule


