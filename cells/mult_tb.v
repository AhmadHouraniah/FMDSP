module tb();

    parameter N = 5;
    parameter M = 5;
    parameter mult = 0;
    reg signed [N-1:0] a;
    reg signed [M-1:0] b;


    wire signed [M+N-1 : 0]  res1, res2, res;
    assign res =res1+res2;
    wire [M+N-1 : 0] expected_res = a*b;
    PPM #(N, M, 1) dut (.a(a), .b(b), .out1(res1), .out2(res2));

    initial begin
        $dumpvars;
        repeat(1000) begin
            a=$random;
            b=$random;
            #10;
            if(res != expected_res)
                $display("Error a: %d, b: %d, out: %d, expected: %d", a, b, res, expected_res);
            //else
                //$display("Correct %d, %d", res, expected_res);
        end
        $finish;
    end

endmodule