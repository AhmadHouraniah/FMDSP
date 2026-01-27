module shift_register(clk, in, out);

    parameter WIDTH = 4;
    parameter DEPTH = 4;

    input clk;
    input [WIDTH-1:0] in;
    output [WIDTH-1:0] out;

    wire [WIDTH-1:0] registers [0:DEPTH];

    generate
        genvar i;
        assign registers[0] = in;
        for(i = 0; i< DEPTH; i = i+1) begin
            flop #(WIDTH) flop_instance (.clk(clk), .in(registers[i]), .out(registers[i+1]));
        end
        assign out = registers[DEPTH];
    endgenerate 

endmodule
