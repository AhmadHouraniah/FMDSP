module DSP_model(clk, start, aa, bb, cc, shift_amount,  shift_dir, mode, out, mac, pipe_stages, compare_res);

    parameter WIDTH = 33;
        localparam WIDTH2 = WIDTH/2; //16
    parameter PPM_TYPE = 0; //0: wallace, 1: dadda

    parameter SHIFT_BITS = 2;
    parameter PIPE_STAGE_WIDTH = 2;
    parameter PIPELINE_BITS = 3;

	input clk, start;	
	input [PIPELINE_BITS-1:0] pipe_stages;
	input [1:0] mode;
	input mac;
    input [SHIFT_BITS-1:0] shift_amount;
	input [WIDTH-1:0] aa;
	input [WIDTH-1:0] bb;
	input [2*WIDTH-1:0] cc;
	input shift_dir;
	
    output reg compare_res;
	output signed [2*WIDTH-1:0] out;
	reg signed [2*WIDTH-1:0] out_wire;
	reg mac_prev;
	
	reg signed [2*WIDTH-1:0] outPrev;
	
	reg start_r1, start_r2, start_r3, start_r4, start_r5;

	reg signed [2*WIDTH-1:0] res0;

	
    always@* begin
		compare_res =  (~mode[1]&~mode[0]&start) | (~mode[1]&mode[0]&start_r1)| (mode[1]&~mode[0]&start_r3);
		out_wire = outPrev;
		if(mode == 2'b00) begin
			if(start) begin
				res0 =  $signed(aa[WIDTH2 :0])*$signed(bb[WIDTH2 :0]) ;
				if(mac&mac_prev)
					if(shift_dir)
						out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
					else
                    	out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
				else
					out_wire = res0 + cc;
			end
			else
				out_wire = 0;
		end
		else if (mode ==2'b01) begin
			if(start) begin
				res0 = $signed(aa[WIDTH2:0])*$signed(bb[WIDTH -1 :0]);
				if(mac&mac_prev) 
					if(shift_dir)
                    	out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
					else
						out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
				else
					out_wire = res0 + cc;
			end
		end
		else if(mode == 2'b10) begin
			if(start) begin
				res0 = $signed(aa[WIDTH-1:0])*$signed(bb[WIDTH-1:0]);
				if(mac&mac_prev)
					if(shift_dir)
                    	out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
					else
						out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
				else
					out_wire = res0 + cc;
			end
		end
    end

	always@(posedge clk) begin
		mac_prev <= mac;
		outPrev <= out_wire;
		start_r1 <= start;
		start_r2 <= start_r1;
		start_r3 <= start_r2;
	end
	
	shift_register #(.WIDTH(2*WIDTH), .PIPELINE_BITS(PIPELINE_BITS)) shift_register(.data_in(out_wire), .depth(pipe_stages), .clk(clk), .data_out(out));
	
endmodule

module shift_register #(
    parameter WIDTH = 8,
    parameter PIPELINE_BITS = 3
)(
    input wire clk,                  // Clock signal
    input wire [WIDTH-1:0] data_in,  // Data input
    input wire [PIPELINE_BITS-1:0] depth,  // Number of stages
    output reg [WIDTH-1:0] data_out  // Data output
);

reg [WIDTH-1:0] stages [0:PIPELINE_BITS-1]; // Array to hold shifted data
reg [PIPELINE_BITS-1:0] current_depth; // Register to hold the current depth value
integer i;

// Sequential logic to shift data
always @(posedge clk) begin
    // Shift data through the stages
    for (i = PIPELINE_BITS-1; i > 0; i = i - 1) begin
        stages[i] <= #1 stages[i-1];
    end
    stages[0] <= #1 data_in; // Input data goes into the first stage

    // Update current_depth register
    current_depth <= depth;
end

// Output the data from the correct stage based on current_depth
always @* begin
    if(depth == 0)
		data_out = data_in;
	else
		if (current_depth > 0 && current_depth <= PIPELINE_BITS) begin
			data_out = stages[current_depth-1];
		end
    // If depth is invalid, do not update data_out (retain last valid output)
end

endmodule
