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
	reg [n+m-1:0] cc;

    wire compare_res;

	// Outputs
	wire [m+n-1:0] out;

	integer ii;
	wire [m+n-1:0] model_out;

	// Instantiate the Unit Under Test (UUT)
    wire [31:0] nc;
    
	DSP_top #(n,m, pipes, 1, mult)	uut (
	.clk(clk),
	.start(start),
	.mode(mode),
	.out(out),
	.barrel_shifter(2'b0),
	.mac(1'b0),
	.cc(cc),
	.aa(aa),
	.bb(bb)
	);

	DSP_model #(n,m, pipes, 1, mult)	model (
	.clk(clk),
	.start(start),
	.mode(mode),
	.barrel_shifter(2'b0),
	.mac(1'b0),
	.out(model_out),
	.cc(cc),
	.aa(aa),
	.bb(bb),
    .compare_res(compare_res)
	);

	always #clkLength clk=~clk;

	wire [4:0] aa_1 = aa[4:0];
	wire [4:0] bb_1 = bb[4:0];
	

	initial begin
		$dumpvars;
		cc = 0;
		mode=0;
		clk = 0;
		start <= 0;
		aa <= 0;
		bb <= 0;

		#211;

		mode=0;
		for(ii=0; ii<testCount; ii=ii+1) begin
			start =1;
			aa[8:5] = 4'b0;
			bb[8:5] = 4'b0;
			aa[4:0] = $random;
			bb[4:0] = $random;
			#cycleLength;
			//start = 0;
		end
		start = 0;
		#100;
		if(error_count == 0)
			$display("Mode 1 Passed");
		else
			$display("Mode 1 Failed with %d errors", error_count);
		error_count = 0;

		
		mode=1;
		for(ii=0; ii<testCount; ii=ii+1) begin
			start =1;
			aa[8:5] = 4'b0;
			aa[4:0] = $random;
			bb = $random;
			#cycleLength;
			start = 0;
			#cycleLength;
			
		end
		#100;
		if(error_count == 0)
			$display("Mode 2 Passed");
		else
			$display("Mode 2 Failed with %d errors", error_count);
		error_count = 0;
		
		#200 
		$display("Error count: %d", error_count);
		$finish;
    end

	wire [9:0] mode_1_out = out[9:0];
	wire [9:0] mode_1_model_out = model_out[9:0];
	wire [14:0] mode_2_out = out[14:0];
	wire [14:0] mode_2_model_out = model_out[14:0];
	
    always@(posedge clk) begin
        if(compare_res) 
			if(model_out != out) 
				error_count = error_count +1;
    end

endmodule

        
