module DSP_top(clk, start, aa, bb, cc, shift_amount, shift_dir, mode, out, mac, mac_start,  pipe_stages);
    parameter N = 16;
        localparam N2 = N/2;
    parameter M = 16;
        localparam M2 = M/2;
    parameter PPM_type = 0; //0: wallace, 1: dadda

    parameter SHIFT_BITS = 2;


    input [1:0] pipe_stages;
    input [1:0] shift_amount;
    input shift_dir;
    input [N-1:0] aa;
    input [M-1:0] bb;
    input mac_start;

    input [N+M-1:0] cc;

    input [1:0] mode;
    input clk, start, mac;

    output [N+M-1:0] out;


    wire start_r1, start_r2, start_r3;
    flop #(1) flop_start_r1 (.in(start), .clk(clk), .out(start_r1));
    flop #(1) flop_start_r2 (.in(start_r1), .clk(clk), .out(start_r2));
    flop #(1) flop_start_r3 (.in(start_r2), .clk(clk), .out(start_r3));

    wire mac_prev;
    flop #(1) flop_mac_r1 (.in(mac), .clk(clk), .out(mac_prev));

    wire [N/2 + M/2 + 1:0] mult;
    
    reg [N2:0] mult_in1;
    reg [M2:0] mult_in2;
     
    reg [3:0] shift_val;

    always@*begin
        shift_val = 0;
        case(mode)
            0: begin
                mult_in1 = aa[N2:0];
                mult_in2 = bb[M2:0];
            end
            1: begin
                mult_in1 = aa[N2:0];
                if(start) begin
                    mult_in2 = {1'b0,bb[N2-1:0]};
                end
                else begin
                    shift_val = N2;
                    mult_in2 =  bb[M-1:M2];
                end
            end
            2: begin
                if(start) begin
                    mult_in1 = {1'b0, aa[N2-1:0]};
                    mult_in2 = {1'b0,bb[M2-1:0]};
                end else if(start_r1) begin
                    shift_val = N2;
                    mult_in1 = {1'b0, aa[N2-1:0]};
                    mult_in2 = {bb[M-1], bb[M-1:M2]};
                end else if(start_r2) begin
                    shift_val = N2;
                    mult_in1 = {aa[N-1], aa[N-1:N2]};
                    mult_in2 = {1'b0,bb[M2-1:0]};
                end else begin
                    shift_val = N2*2;
                    mult_in1 = {aa[N-1], aa[N-1:N2]};
                    mult_in2 = {bb[M-1], bb[M-1:M2]};
                end 
            end
        endcase       
    end

    wire [N2+M2+2:0] mult_out1, mult_out2;

    PPM #(N2+1, M2+1, PPM_type) PPM (.a(mult_in1), .b(mult_in2), .out1(mult_out1), .out2(mult_out2));

    wire [N+M-1:0] comp_in1 =  { {N+M-1{1'b1}},mult_out1[N2+M2+1:0] }<< shift_val;

    wire [N+M-1:0] comp_in2 =  mult_out2[N2+M2+1:0]<< shift_val;

    wire [N+M-1:0] comp_in3 =  start? mac&mac_prev? shifted_comp_out1_r1: cc : comp_out1_r1 ;

    wire [N+M-1:0] comp_in4 =  start? mac&mac_prev?  shifted_comp_out2_r1: 0 : comp_out2_r1;
    
    wire [N+M-1:0] comp_out1, comp_out2, comp_out1_r1, comp_out2_r1, shifted_comp_out1_r1, shifted_comp_out2_r1;
    barrel_shifter #(N+M, SHIFT_BITS) barrel_shifter1(.data_in(comp_out1_r1), .shift_amount(shift_amount), .direction(shift_dir), .data_out(shifted_comp_out1_r1));
    barrel_shifter #(N+M, SHIFT_BITS) barrel_shifter2(.data_in(comp_out2_r1), .shift_amount(shift_amount), .direction(shift_dir), .data_out(shifted_comp_out2_r1));

    flop_reset #(N+M) flop_comp_out1_r1 (.in(comp_out1), .reset(1'b0), .clk(clk), .out(comp_out1_r1));
    flop_reset #(N+M) flop_comp_out2_r1 (.in(comp_out2), .reset(1'b0), .clk(clk), .out(comp_out2_r1));

    compressor42 #(N+M) comp ( comp_in1, comp_in2, comp_in3, comp_in4, {nc,comp_out1}, {nc,comp_out2});

    final_addition #(N+M, 2) adder (.clk(clk), .in1(comp_out1), .in2(comp_out2), .pipes(2'b0), .out(out));

endmodule




