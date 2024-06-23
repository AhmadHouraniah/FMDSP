module DSP_model #(
    parameter WIDTH = 16,
    parameter PPM_TYPE = 0,
    parameter SHIFT_BITS = 2,
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
    output reg compare_res,
    output signed [2*WIDTH-1:0] out
);

    reg signed [2*WIDTH-1:0] out_wire;
    reg mac_prev;
    reg signed [2*WIDTH-1:0] outPrev;
    reg start_r1, start_r2, start_r3;
    reg signed [2*WIDTH-1:0] res0;

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
                        if (shift_dir)
                            out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
                        else
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

    assign out = out_wire;

endmodule

