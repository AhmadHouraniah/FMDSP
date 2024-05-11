module tb();

reg signed [3 : 0] a, b;

wire signed [7 : 0]  res1, res2, res;
assign res =res1+res2+ 8'b0000_1000;
dadda dadda(.x(a), .y(b), .z0(res1), .z1(res2));

initial begin
    $dumpvars;
    a = 0;
    b = 0;
    # 10;
    $display("a: %d, b: %d, out: %d", a, b, res);

    a=10;
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