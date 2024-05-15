module mult(a, b, out1, out2);
    parameter N = 17;
    parameter M = 17;
    parameter mult = 0;
    input [N-1:0] a;
    input [M-1:0] b;
    output [M+N-1:0] out1, out2;
    wire [M+N-1:0] sign_bits = {1'b1, {M-2{1'b0}} ,1'b1, {N{1'b0}}};
    wire [M+N-1:0] res1, res2;
    generate
        if(mult == 0)
            wallace mult_wallace(.x(a), .y(b), .z0(res1), .z1(res2));
        else
            dadda mult_dadda(.x(a), .y(b), .z0(res1), .z1(res2));
    endgenerate
    compressor  #(N+M) mult_comp(.in1(res1), .in2(res2), .in3(sign_bits), .out1({nc, out1}), .out2({nc, out2}));

endmodule