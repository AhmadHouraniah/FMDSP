`timescale 1ns / 1ps

module mcmult2_tb;

	parameter N = `N;
	parameter M = `M;
	parameter PIPES = `PIPES;
	//only works for 2 and 3, requires modifications for larger intervals
	//0:wallace, 1:dadda
	parameter mult = `MULT;
	
    localparam N2 = N/2;
    localparam M2 = M/2;

	parameter testCount = 200;
	parameter clkLength = 5;
	parameter cycleLength = 2*clkLength;

	integer error_count=0;
	// Inputs
	reg [1:0] mode;
	reg clk;
	reg start;
	reg [1:0] barrel_shifter;
	reg [N-1:0] aa;
	reg [M-1:0] bb;
	reg [N+M-1:0] cc;

    wire compare_res;

	// Outputs
	wire [M+N-1:0] out;

	integer ii;
	wire [M+N-1:0] model_out;

	// Instantiate the Unit Under Test (UUT)
    wire [31:0] nc;
    
	reg mac;

	DSP_top #(N,M, PIPES, mult, 2)	uut (
	.clk(clk),
	.start(start),
	.mode(mode),
	.out(out),
	.shift_amount(barrel_shifter),
	.shift_dir(1'b1),
	.mac(mac),
	.cc(cc),
	.aa(aa),
	.bb(bb)
	);

	DSP_model #(N,M, PIPES, mult)	model (
	.clk(clk),
	.start(start),
	.mode(mode),
	.barrel_shifter(barrel_shifter),
	.mac(mac),
	.out(model_out),
	.cc(cc),
	.aa(aa),
	.bb(bb),
    .compare_res(compare_res)
	);

	always #clkLength clk=~clk;

	initial begin
		$dumpvars;
		cc = 0;
		mac = 0;
		mode=0;
		clk = 0;
		start <= 0;
		aa <= 0;
		bb <= 0;
		barrel_shifter = 0;
		#216;
		mode=0;
		for(ii=0; ii<testCount; ii=ii+1) begin
			start =1;
			aa[N:N2+1] = {N2{aa[N2]}};
			bb[N:N2+1] = {N2{bb[N2]}};
			aa[N2:0] = $random;
			bb[N2:0] = $random;
			#cycleLength;
		end
		start = 0;
		#100;
		if(error_count == 0)
			$display("Mode 1 Passed");
		else
			$display("Mode 1 Failed with %d errors", error_count);
		error_count = 0;

		mode=0;
		mac=1;
		
		for(ii=0; ii<testCount; ii=ii+1) begin
			start =1;
			//barrel_shifter = $random;
			aa[N:N2+1] = {N2{aa[N2]}};
			bb[N:N2+1] = {N2{bb[N2]}};
			aa[N2:0] = $random;
			bb[N2:0] = $random;
			#cycleLength;
			//start = 0;
		end
		start = 0;
		#100;
		if(error_count == 0)
			$display("MAC Mode 1 Passed");
		else
			$display("MAC Mode 1 Failed with %d errors", error_count);
		error_count = 0;
		
		mac=0;
		mode=1;
		barrel_shifter = 0;
		for(ii=0; ii<testCount; ii=ii+1) begin
			start =1;
			aa[N2:0] = $random;
			aa[N:N2+1] = {N2{aa[N2]}};
			bb = $random;
			#cycleLength;
			start = 0;
			#cycleLength;
			
		end
		start = 0;
		#100;
		if(error_count == 0)
			$display("Mode 2 Passed");
		else
			$display("Mode 2 Failed with %d errors", error_count);
		error_count = 0;
		

		mac=1;
		mode=1;
		for(ii=0; ii<testCount; ii=ii+1) begin
			start =1;
			aa[N2:0] = $random;
			aa[N:N2+1] = {N2{aa[N2]}};
			bb = $random;
			#cycleLength;
			start = 0;
			#cycleLength;
			
		end
		start = 0;
		#100;
		if(error_count == 0)
			$display("MAC Mode 2 Passed");
		else
			$display("MAC Mode 2 Failed with %d errors", error_count);
		error_count = 0;

		mac = 0;
		barrel_shifter = 0;
		mode=2;
		for(ii=0; ii<testCount; ii=ii+1) begin
			start =1;
			aa = $random;
			bb = $random;
			#cycleLength;
			start = 0;
			#cycleLength;
			#cycleLength;
			#cycleLength;
		end
		start = 0;
		#100;
		if(error_count == 0)
			$display("Mode 3 Passed");
		else
			$display("Mode 3 Failed with %d errors", error_count);
		error_count = 0;
		
		mac = 1;
		mode=2;
		for(ii=0; ii<testCount; ii=ii+1) begin
			start =1;
			//barrel_shifter = $random;
			aa = $random;
			bb = $random;
			#cycleLength;
			start = 0;
			#cycleLength;
			#cycleLength;
			#cycleLength;
		end
		start = 0;
		#100;
		if(error_count == 0)
			$display("MAC Mode 3 Passed");
		else
			$display("MAC Mode 3 Failed with %d errors", error_count);
		error_count = 0;

		#200 
		$finish;
    end

    always@(posedge clk) begin
        if(compare_res) 
			if(model_out != out) 
				error_count = error_count +1;
    end

endmodule

        
