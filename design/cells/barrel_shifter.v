module barrel_shifter #(parameter WIDTH = 8, parameter SHIFT_BITS = 3)(
    input wire signed [WIDTH-1:0] data_in,
    input wire [SHIFT_BITS-1:0] shift_amount,
    output reg signed [WIDTH-1:0] data_out
);
    always @* begin
        // Arithmetic Right shift (preserves sign)
        data_out = data_in >>> shift_amount;
    end
endmodule
