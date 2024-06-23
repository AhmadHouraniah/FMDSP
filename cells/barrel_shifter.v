module barrel_shifter2 #(parameter WIDTH = 8, parameter SHIFT_BITS = 3)(
    input wire signed [WIDTH-1:0] data_in1,
    input wire signed [WIDTH-1:0] data_in2,
    input wire [SHIFT_BITS-1:0] shift_amount,
    input wire direction, // 0 for left shift, 1 for right shift
    output reg signed [WIDTH-1:0] data_out1,
    output reg signed [WIDTH-1:0] data_out2
);

    always @* begin
        if (direction == 1'b0) begin
            // Left shift
            data_out1 = data_in1 << shift_amount;
            data_out2 = data_in2 << shift_amount;
            data_out1[WIDTH-1] = data_in1[WIDTH-1];
            data_out2[WIDTH-1] = data_in2[WIDTH-1];
            
        end else begin
            // Right shift with sign extension
            data_out1 = {{WIDTH{data_in1[WIDTH-1]}},data_in1} >> shift_amount;
            data_out2 = {{WIDTH{data_in2[WIDTH-1]}},data_in2} >> shift_amount;
        end
    end

endmodule
//
//module barrel_shifter2 #(parameter WIDTH = 8, parameter SHIFT_BITS = 3)(
//    input wire signed [WIDTH-1:0] data_in1,
//    input wire signed [WIDTH-1:0] data_in2,
//    input wire [SHIFT_BITS-1:0] shift_amount,
//    input wire direction, // 0 for left shift, 1 for right shift
//    output reg signed [WIDTH-1:0] data_out1,
//    output reg signed [WIDTH-1:0] data_out2,
//    output reg signed [WIDTH-1:0] data_out3
//    
//    );
//    
//    reg signed [WIDTH-1:0] shifted_data1;
//    reg signed [WIDTH-1:0] shifted_data2;
//    reg signed [WIDTH-1:0] carry_data1;
//    reg signed [WIDTH-1:0] carry_data2;
//
//    always @* begin
//        if (direction == 1'b0) begin
//            // Left shift
//            shifted_data1 = data_in1 << shift_amount;
//            shifted_data2 = data_in2 << shift_amount;
//            carry_data1 = data_in1 >> (WIDTH - shift_amount);
//            carry_data2 = data_in2 >> (WIDTH - shift_amount);
//        end else begin
//            // Right shift with sign extension
//            shifted_data1 = data_in1 >>> shift_amount;
//            shifted_data2 = data_in2 >>> shift_amount;
//            carry_data1 = data_in1 << (WIDTH - shift_amount);
//            carry_data2 = data_in2 << (WIDTH - shift_amount);
//        end
//        
//        // Combine shifted data and carry data
//        data_out1 = shifted_data1;
//        data_out2 = shifted_data2;
//        result = {1'b0, data_out1} + {1'b0, data_out2} + {1'b0, carry_data1} + {1'b0, carry_data2};
//    end
//endmodule
//

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
            data_out = data_in >>> shift_amount;
        end
    end
endmodule
