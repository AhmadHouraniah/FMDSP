module barrel_shifter #(parameter WIDTH = 8, parameter SHIFT_BITS = 3)(
    input wire signed [WIDTH-1:0] data_in,
    input wire [SHIFT_BITS-1:0] shift_amount,
    input wire direction, // 0 for left shift, 1 for right shift
    output reg signed [WIDTH-1:0] data_out
);
    always @* begin
        if (direction == 1'b0) begin
            // Left shift
            data_out = data_in << shift_amount;

        end else begin
            // Right shift with sign extension
            data_out = {{WIDTH{data_in[WIDTH-1]}},data_in} >> shift_amount;

        end
    end
endmodule
