module DSP_top(clk, start, aa, bb, cc, shift_amount, shift_dir, mode, out, mac,  pipe_stages);
    parameter WIDTH = 33;
        localparam WIDTH2 = WIDTH/2; //16
    parameter PPM_TYPE = 0; //0: wallace, 1: dadda

    parameter SHIFT_BITS = 2;
    parameter PIPE_STAGE_WIDTH = 2;
    parameter PIPELINE_BITS = 3;

    input [PIPELINE_BITS-1:0] pipe_stages;
    input [SHIFT_BITS-1:0] shift_amount;
    input shift_dir;
    input [WIDTH-1:0] aa;
    input [WIDTH-1:0] bb;
    input [2*WIDTH-1:0] cc;
    input [1:0] mode;
    input clk, start, mac;

    output [2*WIDTH-1:0] out;


    wire start_r1, start_r2, start_r3;
    flop #(1) flop_start_r1 (.in(start), .clk(clk), .out(start_r1));
    flop #(1) flop_start_r2 (.in(start_r1), .clk(clk), .out(start_r2));
    flop #(1) flop_start_r3 (.in(start_r2), .clk(clk), .out(start_r3));

    wire mac_prev;
    flop #(1) flop_mac_r1 (.in(mac), .clk(clk), .out(mac_prev));
    
    reg [WIDTH2:0] mult_in1;
    reg [WIDTH2:0] mult_in2;
    
    wire [WIDTH2+WIDTH2+2:0] mult_out1, mult_out2;

    PPM #(WIDTH2+1, WIDTH2+1, PPM_TYPE) PPM (.a(mult_in1), .b(mult_in2), .out1(mult_out1), .out2(mult_out2));

    reg [$clog2(WIDTH):0] shift_val;

    always@*begin
        shift_val = 0;
        case(mode)
            0: begin
                mult_in1 = aa[WIDTH2:0];
                mult_in2 = bb[WIDTH2:0];
            end
            1: begin
                mult_in1 = aa[WIDTH2:0];
                if(start) begin
                    mult_in2 = {1'b0,bb[WIDTH2-1:0]};
                end
                else begin
                    shift_val = WIDTH2;
                    mult_in2 =  bb[WIDTH-1:WIDTH2];
                end
            end
            2: begin
                if(start) begin
                    mult_in1 = {1'b0, aa[WIDTH2-1:0]};
                    mult_in2 = {1'b0,bb[WIDTH2-1:0]};
                end else if(start_r1) begin
                    shift_val = WIDTH2;
                    mult_in1 = {1'b0, aa[WIDTH2-1:0]};
                    mult_in2 = {bb[WIDTH-1:WIDTH2]};
                end else if(start_r2) begin
                    shift_val = WIDTH2;
                    mult_in1 = {aa[WIDTH-1:WIDTH2]};
                    mult_in2 = {1'b0,bb[WIDTH2-1:0]};
                end else begin
                    shift_val = WIDTH2*2;
                    mult_in1 = {aa[WIDTH-1:WIDTH2]};
                    mult_in2 = {bb[WIDTH-1:WIDTH2]};
                end 
            end
            default: begin
                mult_in1 = 0;
                mult_in2 = 0;
                shift_val = 0;
            end
        endcase       
    end

    wire [2*WIDTH-1:0] comp_out1, comp_out2, comp_out1_r1, comp_out2_r1, shifted_comp_out1_r1, shifted_comp_out2_r1;

    wire [2*WIDTH-1:0] comp_in1 =  { {2*WIDTH-1{1'b1}},mult_out1[WIDTH2+WIDTH2+1:0] }<< shift_val;

    wire [2*WIDTH-1:0] comp_in2 =  mult_out2[WIDTH2+WIDTH2+1:0]<< shift_val;

    wire [2*WIDTH-1:0] comp_in3 =  start? mac&mac_prev? shifted_comp_out1_r1: cc : comp_out1_r1 ;

    wire [2*WIDTH-1:0] comp_in4 =  start? mac&mac_prev?  shifted_comp_out2_r1: 0 : comp_out2_r1;
    
//    barrel_shifter #(2*WIDTH, SHIFT_BITS) barrel_shifter1(.data_in(comp_out1_r1), .shift_amount(shift_amount), .direction(shift_dir), .data_out(shifted_comp_out1_r1));
//    barrel_shifter #(2*WIDTH, SHIFT_BITS) barrel_shifter2(.data_in(comp_out2_r1), .shift_amount(shift_amount), .direction(shift_dir), .data_out(shifted_comp_out2_r1));
    barrel_shifter2 #(2*WIDTH, SHIFT_BITS) barrel_shifter1(.data_in1(comp_out1_r1), .data_in2(comp_out2_r1),.shift_amount(shift_amount), .direction(shift_dir), .data_out1(shifted_comp_out1_r1), .data_out2(shifted_comp_out2_r1));

    flop #(2*WIDTH) flop_comp_out1_r1 (.in(comp_out1), .clk(clk), .out(comp_out1_r1));
    flop #(2*WIDTH) flop_comp_out2_r1 (.in(comp_out2), .clk(clk), .out(comp_out2_r1));

    compressor42 #(2*WIDTH) comp ( comp_in1, comp_in2, comp_in3, comp_in4, {nc1,comp_out1}, {nc2,comp_out2});

    final_addition #(.WIDTH(2*WIDTH), .PIPE_STAGE_WIDTH(PIPE_STAGE_WIDTH), .PIPELINE_BITS(3) ) adder (.clk(clk), .in1(comp_out1), .in2(comp_out2), .pipes(3'b0), .out(out));

endmodule




