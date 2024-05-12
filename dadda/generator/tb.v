module tb();

    parameter N = 16;
    parameter M = 16;
    parameter mult = 0;
    reg signed [N-1:0] a;
    reg signed [M-1:0] b;


    wire signed [M+N-1 : 0]  res1, res2, res;
    assign res =res1+res2;
    mult #(N, M, 1) dut (.a(a), .b(b), .out1(res1), .out2(res2));

    initial begin
        $dumpvars;
        a = -15;
        b = 3;
        # 10;
        $display("a: %d, b: %d, out: %d", a, b, res);

        a=-10;
        b=10;
        #10;

        $display("a: %d, b: %d, out: %d", a, b, res);

        a=3;
        b=7;
        #10;

        $display("a: %d, b: %d, out: %d", a, b, res);

        $finish;
    end

endmodule