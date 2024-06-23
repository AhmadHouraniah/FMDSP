module DSP_model #(
    parameter WIDTH = 16,
    parameter PPM_TYPE = 0,
    parameter SHIFT_BITS = 2,
    parameter PIPE_STAGE_WIDTH = 2,
    parameter PIPELINE_BITS = 3,
    localparam WIDTH2 = WIDTH / 2
)(
    input clk,
    input start,
    input [WIDTH-1:0] aa,
    input [WIDTH-1:0] bb,
    input [2*WIDTH-1:0] cc,
    input [SHIFT_BITS-1:0] shift_amount,
    input shift_dir,
    input [1:0] mode,
    input mac,
    input [PIPELINE_BITS-1:0] pipe_stages,
    output reg compare_res,
    output signed [2*WIDTH-1:0] out
);

    reg signed [2*WIDTH-1:0] out_wire;
    reg mac_prev;
    reg signed [2*WIDTH-1:0] outPrev;
    reg start_r1, start_r2, start_r3;
    reg signed [2*WIDTH-1:0] res0;
	reg signed [2*WIDTH-1:0] shifted1;

    always @* begin
        compare_res = (~mode[1] & ~mode[0] & start) | (~mode[1] & mode[0] & start_r1) | (mode[1] & ~mode[0] & start_r3);
        out_wire = outPrev;

        case (mode)
            2'b00: begin
                if (start) begin
                    res0 = $signed(aa[WIDTH2:0]) * $signed(bb[WIDTH2:0]);
                    if (mac & mac_prev) begin
                        if (shift_dir)
                            out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
                        else
                            out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
                    end else
                        out_wire = res0 + cc;
                end else
                    out_wire = 0;
            end
            2'b01: begin
                if (start) begin
                    res0 = $signed(aa[WIDTH2:0]) * $signed(bb[WIDTH-1:0]);
                    if (mac & mac_prev) begin
                        if (shift_dir)
                            out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
                        else
                            out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
                    end else
                        out_wire = res0 + cc;
                end
            end
            2'b10: begin
                if (start) begin
                    res0 = $signed(aa[WIDTH-1:0]) * $signed(bb[WIDTH-1:0]);
                    if (mac & mac_prev) begin
                        if (shift_dir) begin
                            //out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
							shifted1 = ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
							out_wire = shifted1 +res0;
						end else
                            out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
                    end else
                        out_wire = res0 + cc;
                end
            end
        endcase
    end
    always @(posedge clk) begin
        mac_prev <= mac;
        outPrev <= out_wire;
        start_r1 <= start;
        start_r2 <= start_r1;
        start_r3 <= start_r2;
    end

    shift_register #(
        .WIDTH(2*WIDTH),
        .PIPELINE_BITS(PIPELINE_BITS)
    ) shift_register_inst (
        .clk(clk),
        .data_in(out_wire),
        .depth(pipe_stages),
        .data_out(out)
    );

endmodule

module shift_register #(
    parameter WIDTH = 8,
    parameter PIPELINE_BITS = 3
)(
    input wire clk,                  
    input wire [WIDTH-1:0] data_in,  
    input wire [PIPELINE_BITS-1:0] depth,  
    output reg [WIDTH-1:0] data_out  
);

    reg [WIDTH-1:0] stages [0:PIPELINE_BITS-1]; 
    reg [PIPELINE_BITS-1:0] current_depth; 
    integer i;

    always @(posedge clk) begin
        for (i = PIPELINE_BITS-1; i > 0; i = i - 1) begin
            stages[i] <= #1 stages[i-1];
        end
        stages[0] <= #1 data_in; 

        current_depth <= depth;
    end

    always @* begin
        if (depth == 0)
            data_out = data_in;
        else if (current_depth > 0 && current_depth <= PIPELINE_BITS) begin
            data_out = stages[current_depth-1];
        end
    end

endmodule
