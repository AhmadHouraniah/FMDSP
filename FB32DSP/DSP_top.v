module DSP_top(clk, start, aa, bb, cc, shift_amount, shift_dir, mode, out, mac);
    parameter WIDTH = 33;
        localparam WIDTH2 = WIDTH/2; //16
    parameter PPM_TYPE = 0; //0: wallace, 1: dadda

    parameter SHIFT_BITS = 2;

    input [SHIFT_BITS-1:0] shift_amount;
    input shift_dir;
    input [WIDTH-1:0] aa;
    input [WIDTH-1:0] bb;
    input [2*WIDTH-1:0] cc;
    input [1:0] mode;
    input clk, start, mac;

    output [2*WIDTH-1:0] out;
    wire [2*WIDTH-1:0] outPrev;
    flop #(2*WIDTH) flop_outPrev(.in(out), .clk(clk), .out(outPrev));
    
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

    wire [2*WIDTH-1:0] comp_out1, comp_out2, outPrevShifted;

    wire [2*WIDTH-1:0] comp_in1 =  { {2*WIDTH-1{1'b1}},mult_out1[WIDTH2+WIDTH2+1:0] }<< shift_val;

    wire [2*WIDTH-1:0] comp_in2 =  mult_out2[WIDTH2+WIDTH2+1:0]<< shift_val;

    wire [2*WIDTH-1:0] comp_in3 =  start? mac&mac_prev? outPrevShifted: cc : outPrev ;
    
    barrel_shifter #(2*WIDTH, SHIFT_BITS) barrel_shifter2(.data_in(outPrev), .shift_amount(shift_amount), .direction(shift_dir), .data_out(outPrevShifted));

    compressor32 #(2*WIDTH) comp ( comp_in1, comp_in2, comp_in3, {nc1, comp_out1}, {nc2, comp_out2});
    assign out = comp_out1 + comp_out2;
endmodule




