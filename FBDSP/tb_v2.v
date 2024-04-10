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
	reg [n-1:0] aa;
	reg [m-1:0] bb;

    wire compare_res;

	// Outputs
	wire [m+n-1:0] out;

	integer ii;
	wire [m+n-1:0] model_out;

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



	DSP_model #(n,m, pipes, initiationInterval, mult)	model (
	.clk(clk),
	.start(start),
	.sign(sign),
	.out(model_out),
	.aa(aa),
	.bb(bb),
    .compare_res(compare_res)
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
			start =1;
			aa = {2'b11, {(1+n/32){$random}}};
			bb = {2'b11, {(1+m/32){$random}}};
			#cycleLength;
			start = 0;
		end
		#200 $finish;
    end

    always@(posedge clk) begin
        if(compare_res) begin
			#(cycleLength/10);
			if(sign==0) begin
				if(model_out == out)
					$display("correct");
				else
					$display("error");
			end else begin
				if(model_out == out)
				    $display("correct");
				else begin
				    $display("error");
				    error_count = error_count +1;
			    end
			end
        end 
    end

endmodule

        
