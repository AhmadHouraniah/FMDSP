module final_addition
#(
    parameter WIDTH = 16
)
(
    input   wire [WIDTH-1:0] in1,    // First input operand
    input   wire [WIDTH-1:0] in2,    // Second input operand
    input   wire clk,                // Clock signal
    input   wire piped, // Number of pipeline stages (1 to 4)
    output  wire [WIDTH:0] out     // Sum output
);

    localparam WIDTH4 = (WIDTH + 3) / 4; //ceil

    wire [WIDTH4-1:0] adder1_in1_r, adder2_in1_r, adder3_in1_r, adder4_in1_r;
    wire [WIDTH4-1:0] adder1_in2_r, adder2_in2_r, adder3_in2_r, adder4_in2_r;
    wire [WIDTH4-1:0] sum1, sum2, sum3, sum4;
    wire carry_out1, carry_out2, carry_out3, carry_out4;
    wire [WIDTH:0] out_reg;

    wire [WIDTH4-1:0] adder1_in1 = in1[1*WIDTH4-1:0*WIDTH4];
    wire [WIDTH4-1:0] adder2_in1 = in1[2*WIDTH4-1:1*WIDTH4];
    wire [WIDTH4-1:0] adder3_in1 = in1[3*WIDTH4-1:2*WIDTH4];
    wire [WIDTH4-1:0] adder4_in1 = in1[WIDTH-1:3*WIDTH4];

    wire [WIDTH4-1:0] adder1_in2 = in2[1*WIDTH4-1:0*WIDTH4];
    wire [WIDTH4-1:0] adder2_in2 = in2[2*WIDTH4-1:1*WIDTH4];
    wire [WIDTH4-1:0] adder3_in2 = in2[3*WIDTH4-1:2*WIDTH4];
    wire [WIDTH4-1:0] adder4_in2 = in2[WIDTH-1:3*WIDTH4];

    wire carry_in1 = 1'b0;
    wire carry_in2 = carry_out1;
    wire carry_in3 = carry_out2;
    wire carry_in4 = carry_out3;
    
    adder #(WIDTH4) adder1 (.in1(piped ? adder1_in1_r : adder1_in1), .in2(piped? adder1_in2_r : adder1_in2), .carry_in(piped? carry_in1_r : carry_in1), .out(sum1), .carry_out(carry_out1)); 
    adder #(WIDTH4) adder2 (.in1(piped ? adder2_in1_r : adder2_in1), .in2(piped? adder2_in2_r : adder2_in2), .carry_in(piped? carry_in2_r : carry_in2), .out(sum2), .carry_out(carry_out2)); 
    adder #(WIDTH4) adder3 (.in1(piped ? adder3_in1_r : adder3_in1), .in2(piped? adder3_in2_r : adder3_in2), .carry_in(piped? carry_in3_r : carry_in3), .out(sum3), .carry_out(carry_out3)); 
    adder #(WIDTH4) adder4 (.in1(piped ? adder4_in1_r : adder4_in1), .in2(piped? adder4_in2_r : adder4_in2), .carry_in(piped? carry_in4_r : carry_in4), .out(sum4), .carry_out(carry_out4)); 

    shift_register #(1, 0) shift_register_carry1  (.clk(clk), .in(carry_in1), .out(carry_in1_r));
    shift_register #(1, 1) shift_register_carry2  (.clk(clk), .in(carry_in2), .out(carry_in2_r));
    shift_register #(1, 1) shift_register_carry3  (.clk(clk), .in(carry_in3), .out(carry_in3_r));
    shift_register #(1, 1) shift_register_carry4  (.clk(clk), .in(carry_in4), .out(carry_in4_r));

    shift_register #(1, 0) shift_register_carry5  (.clk(clk), .in(carry_out4), .out(out_reg[WIDTH]));

    shift_register #(WIDTH4, 0) shift_register_in_1_1  (.clk(clk), .in(adder1_in1), .out(adder1_in1_r));
    shift_register #(WIDTH4, 1) shift_register_in_1_2  (.clk(clk), .in(adder2_in1), .out(adder2_in1_r));
    shift_register #(WIDTH4, 2) shift_register_in_1_3  (.clk(clk), .in(adder3_in1), .out(adder3_in1_r));
    shift_register #(WIDTH4, 3) shift_register_in_1_4  (.clk(clk), .in(adder4_in1), .out(adder4_in1_r));

    shift_register #(WIDTH4, 0) shift_register_in_2_1  (.clk(clk), .in(adder1_in2), .out(adder1_in2_r));
    shift_register #(WIDTH4, 1) shift_register_in_2_2  (.clk(clk), .in(adder2_in2), .out(adder2_in2_r));
    shift_register #(WIDTH4, 2) shift_register_in_2_3  (.clk(clk), .in(adder3_in2), .out(adder3_in2_r));
    shift_register #(WIDTH4, 3) shift_register_in_2_4  (.clk(clk), .in(adder4_in2), .out(adder4_in2_r));

    shift_register #(WIDTH4, 3) shift_register_out_1 (.clk(clk), .in(sum1), .out(out_reg[WIDTH4-1:0]));
    shift_register #(WIDTH4, 2) shift_register_out_2 (.clk(clk), .in(sum2), .out(out_reg[2*WIDTH4-1:WIDTH4]));
    shift_register #(WIDTH4, 1) shift_register_out_3 (.clk(clk), .in(sum3), .out(out_reg[3*WIDTH4-1:2*WIDTH4]));
    wire [4*WIDTH4 - WIDTH -1 : 0] nc ;
    shift_register #(WIDTH4, 0) shift_register_out_4 (.clk(clk), .in(sum4), .out({nc, out_reg[WIDTH-1:3*WIDTH4]}));

    assign out = piped? out_reg : {carry_out4, sum4, sum3, sum2, sum1};

endmodule


module adder(in1, in2, carry_in, out, carry_out);
    parameter WIDTH = 4;

    input [WIDTH-1:0] in1, in2;
    input carry_in;
    output [WIDTH-1:0] out;
    output carry_out;

    assign {carry_out, out} = in1 + in2 + carry_in; 

endmodule

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

`ifdef SIM_FINAL_ADDITION
module tb();

    parameter WIDTH = 16;
    reg [WIDTH-1:0] A, B;
    wire [WIDTH:0] sum;
    reg clk = 0;
    reg piped;

    always #5 clk = ~clk;

    final_addition #(WIDTH) fa (.in1(A), .in2(B), .clk(clk), .piped(piped), .out(sum));

    initial begin
        $dumpvars;
        #1;
        A = 10;
        B = 20;
        piped = 0;
        #50;


        A = $random;
        B = $random;
        piped = 1;
        #10;
        A = $random;
        B = $random;
        piped = 1;
        #10;
        A = $random;
        B = $random;
        piped = 1;
        #10;
        A = $random;
        B = $random;
        piped = 1;
        #10;
        A = $random;
        B = $random;
        piped = 1;
        #10;
        A = $random;
        B = $random;
        piped = 1;
        #10;
        #30;
        $finish;
    end
endmodule
`endif 