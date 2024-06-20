`timescale 1ns / 1ps

module tb;

    parameter WIDTH = `WIDTH;
    parameter PIPE_STAGE_WIDTH = `PIPE_STAGE_WIDTH;
    parameter PIPELINE_BITS = 2;
    parameter PPM_TYPE = `PPM_TYPE;
    parameter SHIFT_BITS = 2;
    parameter testCount = 200;
    parameter clkLength = 5;
    parameter cycleLength = 2 * clkLength;
    localparam WIDTH2 = WIDTH / 2;

    integer error_count = 0;

    // Inputs
    reg [1:0] mode;
    reg clk;
    reg start;
    reg [1:0] barrel_shifter;
    reg [WIDTH-1:0] aa;
    reg [WIDTH-1:0] bb;
    reg [WIDTH+WIDTH-1:0] cc;
    reg mac;
    reg shift_dir = 0;
    reg [PIPE_STAGE_WIDTH-1:0] pipe_stages; // Correcting the size of the pipe_stages

    wire [WIDTH+WIDTH-1:0] model_out;
    wire [WIDTH+WIDTH-1:0] out;
    wire compare_res;

    // Instantiate the Unit Under Test (UUT)
    DSP_top #(
        .WIDTH(WIDTH), 
        .PPM_TYPE(PPM_TYPE), 
        .SHIFT_BITS(SHIFT_BITS), 
        .PIPE_STAGE_WIDTH(PIPE_STAGE_WIDTH), 
        .PIPELINE_BITS(PIPELINE_BITS)
    ) uut (
        .clk(clk),
        .start(start),
        .mode(mode),
        .out(out),
        .shift_amount(barrel_shifter),
        .shift_dir(shift_dir),
        .pipe_stages(pipe_stages), // Corrected the connection
        .mac(mac),
        .cc(cc),
        .aa(aa),
        .bb(bb)
    );

    DSP_model #(
        .WIDTH(WIDTH), 
        .PPM_TYPE(PPM_TYPE), 
        .SHIFT_BITS(SHIFT_BITS), 
        .PIPE_STAGE_WIDTH(PIPE_STAGE_WIDTH), 
        .PIPELINE_BITS(PIPELINE_BITS)
    ) model (
        .clk(clk),
        .start(start),
        .mode(mode),
        .out(model_out),
        .shift_amount(barrel_shifter),
        .shift_dir(shift_dir),
        .pipe_stages(pipe_stages), // Corrected the connection
        .mac(mac),
        .cc(cc),
        .aa(aa),
        .bb(bb),
        .compare_res(compare_res)
    );

    always #clkLength clk = ~clk;

    initial begin
        $dumpvars;
        cc = 0;
        mac = 0;
        mode = 0;
        clk = 0;
        start = 0;
        aa = 0;
        bb = 0;
        barrel_shifter = 0;
        pipe_stages = 0;
        #216;

        // Test different modes and configurations
        test_mode(0, 1, 0, 1, "Mode Accumulate", 0);

        test_mode(0, 0, 0, 0, "Mode 0", 0);
        test_mode(0, 1, 0, 0, "MAC | Mode 0", 0);
        test_mode(1, 0, 1, 0, "Mode 1", 0);
        test_mode(1, 1, 1, 0, "MAC | Mode 1", 0);
        test_mode(2, 0, 3, 0, "Mode 2", 0);
        test_mode(2, 1, 3, 0, "MAC | Mode 2", 0);

        test_mode(0, 0, 0, 0, "Mode 0", 1);
        test_mode(0, 1, 0, 0, "MAC | Mode 0", 1);
        test_mode(1, 0, 1, 0, "Mode 1", 1);
        test_mode(1, 1, 1, 0, "MAC | Mode 1", 1);
        test_mode(2, 0, 3, 0, "Mode 2", 1);
        test_mode(2, 1, 3, 0, "MAC | Mode 2", 1);

        #200;
        $finish;
    end

    task test_mode(input reg [1:0] mode_sel, input reg mac_sel, input integer extra_cycles, input reg accumulate, input [31*8:1] mode_name, input reg [PIPE_STAGE_WIDTH-1:0] pipe_stages);
        integer i;
        begin
            mode = mode_sel;
            #100;
			mac = mac_sel;
			
            for (i = 0; i < testCount; i = i + 1) begin
                start = 1;
				if(accumulate) begin							
					aa[WIDTH2:0] = $random;
					aa[WIDTH:WIDTH2+1] = {WIDTH2{aa[WIDTH2]}};
					bb = 1;
				end 
				else begin
					case(mode)
						0: begin
							aa[WIDTH2:0] = $random;
							bb[WIDTH2:0] = $random;
							aa[WIDTH:WIDTH2+1] = {WIDTH2{aa[WIDTH2]}};
							bb[WIDTH:WIDTH2+1] = {WIDTH2{bb[WIDTH2]}};
						end
						1: begin
							aa[WIDTH2:0] = $random;
							aa[WIDTH:WIDTH2+1] = {WIDTH2{aa[WIDTH2]}};
							bb = $random;
						end
						2: begin
							aa = $random;
							bb = $random;
						end
					endcase
				end
                #cycleLength;
                start = 0;
                #(cycleLength * extra_cycles);
            end
            start = 0;
            #100;
            if (error_count == 0)
                $display("%s | Pipes %d | Passed", mode_name, pipe_stages);
            else
                $display("%s | Pipes %d | Failed with %d errors", mode_name, pipe_stages, error_count);
            error_count = 0;
        end
    endtask

    always @(posedge clk) begin
        if (compare_res && (model_out !== out)) 
            error_count = error_count + 1;
    end

endmodule
