module DSP_top(clk, start, aa, bb, cc, barrel_shifter, mode, out, mac);
    parameter N = 16;
        localparam N2 = N/2;
    parameter M = 16;
        localparam M2 = M/2;
    parameter PPM_type = 0; //0: wallace, 1: dadda
    input [1:0] barrel_shifter;
    input [N-1:0] aa;
    input [M-1:0] bb;

    input [N+M-1:0] cc;

    input [1:0] mode;
    input clk, start, mac;

    output [N+M-1:0] out;


    wire start_r1, start_r2, start_r3;
    flop #(1) flop_start_r1 (.in(start), .clk(clk), .out(start_r1));
    flop #(1) flop_start_r2 (.in(start_r1), .clk(clk), .out(start_r2));
    flop #(1) flop_start_r3 (.in(start_r2), .clk(clk), .out(start_r3));

    wire [N/2 + M/2 + 1:0] mult;
    
    wire [N2:0] mult_in1 = 
        ~mode[1]? aa[N2:0]
        : (start|start_r1)? {1'b0, aa[N2-1:0]} : {aa[N-1], aa[N-1:N2]};

    wire [M2:0] mult_in2 = 
          ~mode[1]&~mode[0]? bb[N2:0]
        : ~mode[1]&mode[0]? start? {1'b0,bb[N2-1:0]} : {bb[N-1], bb[N-1:N2]}
        : start | start_r2? {1'b0,bb[M2-1:0]} : {bb[M-1], bb[M-1:M2]};

    wire [N2+M2+2:0] mult_out1, mult_out2;

    PPM #(N2+1, M2+1, PPM_type) PPM (.a(mult_in1), .b(mult_in2), .out1(mult_out1), .out2(mult_out2));

    reg [3:0] shift_val;
    always @* begin
        shift_val = 0;
        if(start_r1)
            if(mode == 1)
                shift_val = N2;
        else if(start_r3)
            if(mode==2)
                shift_val = N2*2;
    end
//    = (start_r1|start_r2)&~mode[1]&mode[0]*N2/2 + (start_r3 & mode == 2)*N2 ; // is this inefficient? 0 for c1, 2 for c2 and c3, 4 for c4

    wire [N+M-1:0] comp_in1 =  { {N+M-1{1'b1}},mult_out1[N2+M2+1:0] << shift_val};

    wire [N+M-1:0] comp_in2 =  mult_out2[N2+M2+1:0]<< shift_val;

    wire [N+M-1:0] comp_in3 =  start? mac? { {N+M-1{comp_out1_r1[N+M-1]}}, comp_out1_r1 >> barrel_shifter} : cc : comp_out1_r1;

    wire [N+M-1:0] comp_in4 =  start?      { {N+M-1{comp_out1_r1[N+M-1]}}, comp_out2_r1 >> barrel_shifter} :      comp_out2_r1;
    
    wire [N+M-1:0] comp_out1, comp_out2, comp_out1_r1, comp_out2_r1;

    compressor42 #(N+M) comp ( comp_in1, comp_in2, comp_in3, comp_in4, {nc,comp_out1}, {nc,comp_out2});
    flop_reset #(N+M) comp_out1_f1 (.in(comp_out1), .clk(clk), .reset(~mac & start), .out(comp_out1_r1));
    flop_reset #(N+M) comp_out2_f1 (.in(comp_out2), .clk(clk), .reset(~mac & start), .out(comp_out2_r1));

    final_addition #(N+M, 2) adder (.clk(clk), .in1(comp_out1), .in2(comp_out2), .pipes(2'b0), .out(out));

endmodule



