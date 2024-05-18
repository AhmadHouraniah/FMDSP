module final_addition(in1, in2, clk, pipes, out);
    parameter width = 16;
    parameter pipe_width = 2;
    input clk;
    input [width-1:0] in1;
    input [width-1:0] in2;
    input [pipe_width-1:0] pipes;
    output [width-1:0] out;
    assign out = in1+in2;
endmodule
