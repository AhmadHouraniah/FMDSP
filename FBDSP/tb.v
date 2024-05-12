`timescale 1ns / 1ps

module mcmult2_tb;

	parameter n = 9;
	parameter m = 9;
	parameter pipes = 0;
	//only works for 2 and 3, requires modifications for larger intervals
	//0:wallace, 1:dadda
	parameter mult = 1;
	

	parameter testCount = 200;
	parameter clkLength = 10;
	parameter cycleLength = 2*clkLength;

	integer error_count=0;
	// Inputs
	reg [1:0] mode;
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
    
	wrapper #(n,m, pipes, 1, mult)	uut (
	.clk(clk),
	.start(start),
	.mode(mode),
	.out({out}),
	.aa(aa),
	.bb(bb)
	);

	DSP_model #(n,m, pipes, 1, mult)	model (
	.clk(clk),
	.start(start),
	.mode(mode),
	.out(model_out),
	.aa(aa),
	.bb(bb),
    .compare_res(compare_res)
	);

	always #clkLength clk=~clk;

	wire [4:0] aa_1 = aa[4:0];
	wire [4:0] bb_1 = bb[4:0];
	

	initial begin
		$dumpvars;
		mode=0;
		clk = 0;
		start <= 0;
		aa <= 0;
		bb <= 0;

		#211;

		for(ii=0; ii<testCount/4; ii=ii+1) begin
			#cycleLength;
			start =1;
			aa[4:0] = $random;
			bb[4:0] = $random;
			//start = 0;
		end
		#200 
		$display("Error count: %d", error_count);
		$finish;
    end

    always@(posedge clk) begin
        if(compare_res) begin
			#(cycleLength/10);
			if(model_out == out) begin
				    $display("correct");
            end else begin
			    error_count = error_count +1;
			end
		end 
    end

endmodule

        
