module DSP_top(clk, start, aa, bb, cc, shift_amount, shift_dir, mode, out, mac, mac_start,  pipe_stages);
    parameter N = 33;
        localparam N2 = N/2; //16
    parameter PPM_type = 0; //0: wallace, 1: dadda

    parameter SHIFT_BITS = 2;
    parameter PIPE_STAGES_BITS = 2;

    input [PIPE_STAGES_BITS-1:0] pipe_stages;
    input [SHIFT_BITS-1:0] shift_amount;
    input shift_dir;
    input [N-1:0] aa;
    input [N-1:0] bb;
    input mac_start;

    input [N+N-1:0] cc;

    input [1:0] mode;
    input clk, start, mac;

    output [N+N-1:0] out;


    wire start_r1, start_r2, start_r3;
    flop #(1) flop_start_r1 (.in(start), .clk(clk), .out(start_r1));
    flop #(1) flop_start_r2 (.in(start_r1), .clk(clk), .out(start_r2));
    flop #(1) flop_start_r3 (.in(start_r2), .clk(clk), .out(start_r3));

    wire mac_prev;
    flop #(1) flop_mac_r1 (.in(mac), .clk(clk), .out(mac_prev));
    
    reg [N2:0] mult_in1;
    reg [N2:0] mult_in2;
    
    wire [N2+N2+2:0] mult_out1, mult_out2;

    PPM #(N2+1, N2+1, PPM_type) PPM (.a(mult_in1), .b(mult_in2), .out1(mult_out1), .out2(mult_out2));

    reg [$clog2(N):0] shift_val;

    always@*begin
        shift_val = 0;
        case(mode)
            0: begin
                mult_in1 = aa[N2:0];
                mult_in2 = bb[N2:0];
            end
            1: begin
                mult_in1 = aa[N2:0];
                if(start) begin
                    mult_in2 = {1'b0,bb[N2-1:0]};
                end
                else begin
                    shift_val = N2;
                    mult_in2 =  bb[N-1:N2];
                end
            end
            2: begin
                if(start) begin
                    mult_in1 = {1'b0, aa[N2-1:0]};
                    mult_in2 = {1'b0,bb[N2-1:0]};
                end else if(start_r1) begin
                    shift_val = N2;
                    mult_in1 = {1'b0, aa[N2-1:0]};
                    mult_in2 = {bb[N-1:N2]};
                end else if(start_r2) begin
                    shift_val = N2;
                    mult_in1 = {aa[N-1:N2]};
                    mult_in2 = {1'b0,bb[N2-1:0]};
                end else begin
                    shift_val = N2*2;
                    mult_in1 = {aa[N-1:N2]};
                    mult_in2 = {bb[N-1:N2]};
                end 
            end
        endcase       
    end

    wire [N+N-1:0] comp_in1 =  { {N+N-1{1'b1}},mult_out1[N2+N2+1:0] }<< shift_val;

    wire [N+N-1:0] comp_in2 =  mult_out2[N2+N2+1:0]<< shift_val;

    wire [N+N-1:0] comp_in3 =  start? mac&mac_prev? shifted_sum_r: cc : sum_r ;
    
    wire [N+N-1:0] comp_out1, comp_out2, sum, sum_r, shifted_sum_r ;

    barrel_shifter #(N+N, SHIFT_BITS) barrel_shifter1(.data_in(sum_r), .shift_amount(shift_amount), .direction(shift_dir), .data_out(shifted_sum_r));
    compressor32 #(N+N) comp ( comp_in1, comp_in2, comp_in3, {nc,comp_out1}, {nc,comp_out2});
    assign sum = comp_out1+ comp_out2;
    flop #(N+N) flop_comp_out1_r1 (.in(sum), .clk(clk), .out(sum_r));

endmodule




