module DSP_model #(
    parameter WIDTH = 16,
    parameter PPM_TYPE = 0,
    parameter SHIFT_BITS = 2,
    localparam WIDTH2 = WIDTH / 2
)(
    input shift_enable,
    input rst,
    input clk,
    input start,
    input [WIDTH-1:0] aa,
    input [WIDTH-1:0] bb,
    input [2*WIDTH-1:0] cc,
    input [SHIFT_BITS-1:0] shift_amount,
    input shift_dir,
    input [1:0] mode,
    input mac,
    input piped_final_addition,
    output compare_res,
    output signed [2*WIDTH-1:0] out
);

    reg compare_res_next;
    reg signed [2*WIDTH-1:0] out_wire;
    reg mac_prev;
    reg signed [2*WIDTH-1:0] outPrev;
    reg start_r1, start_r2, start_r3;
    reg signed [2*WIDTH-1:0] res0;

    always @* begin
        compare_res_next = (~mode[1] & ~mode[0] & start) | (~mode[1] & mode[0] & start_r1) | (mode[1] & ~mode[0] & start_r3);
        out_wire = outPrev;

        case (mode)
            2'b00: begin
                if (start) begin
                    res0 = $signed(aa[WIDTH2:0]) * $signed(bb[WIDTH2:0]);
                    if (mac & mac_prev) begin
                        if(shift_enable)
                            if (shift_dir)
                                out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
                            else
                                out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
                        else
                             out_wire = res0 + outPrev;
                    end else
                        out_wire = res0 + cc;
                end else
                    out_wire = 0;
            end
            2'b01: begin
                if (start) begin
                    res0 = $signed(aa[WIDTH2:0]) * $signed(bb[WIDTH-1:0]);
                    if (mac & mac_prev) begin
                        if(shift_enable)
                            if (shift_dir)
                                out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
                            else
                                out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
                        else
                             out_wire = res0 + outPrev;
                    end else
                        out_wire = res0 + cc;
                end
            end
            2'b10: begin
                if (start) begin
                    res0 = $signed(aa[WIDTH-1:0]) * $signed(bb[WIDTH-1:0]);
                    if (mac & mac_prev) begin
                        if(shift_enable)
                            if (shift_dir)
                                out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} >> shift_amount);
                            else
                                out_wire = res0 + ({{(2*WIDTH){outPrev[2*WIDTH-1]}}, outPrev} << shift_amount);
                        else
                             out_wire = res0 + outPrev;
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

    wire [2*WIDTH-1:0] out_r;
    shift_register #(
        .WIDTH(2*WIDTH), 
        .DEPTH(3)
    ) shift_register_inst (
        .clk(clk),
        .in(out_wire),
        .out(out_r)
    );
    
    wire compare_res_r;
    shift_register #(
        .WIDTH(1), 
        .DEPTH(3)
    ) shift_register_inst_2 (
        .clk(clk),
        .in(compare_res_next),
        .out(compare_res_r)
    );
    assign out = ~shift_enable & piped_final_addition? out_r : out_wire;
    assign compare_res = ~shift_enable & piped_final_addition? compare_res_r : compare_res_next;
    
endmodule
