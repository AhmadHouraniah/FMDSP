module final_addition
#(
    parameter WIDTH = 16,
    parameter PIPE_STAGE_WIDTH = 2,
    parameter PIPELINE_BITS = 3
)
(
    input   wire [WIDTH-1:0] in1,    // First input operand
    input   wire [WIDTH-1:0] in2,    // Second input operand
    input   wire clk,                // Clock signal
    input   wire [PIPELINE_BITS-1:0] pipes, // Number of pipeline stages (1 to 4)
    output  wire [WIDTH-1:0] out     // Sum output
);
    localparam MAX_PIPES = 4;
    reg [WIDTH/PIPE_STAGE_WIDTH - 1 : 0] pipeline_enable;
    wire [WIDTH/PIPE_STAGE_WIDTH : 0] carry;
    
    assign carry[0] = 1'b0;

    wire [WIDTH-1:0] in1_sr [WIDTH/PIPE_STAGE_WIDTH  :0];
    wire [WIDTH-1:0] in2_sr [WIDTH/PIPE_STAGE_WIDTH  :0];
    
    assign in1_sr[0] = in1;
    assign in2_sr[0] = in2;

    generate
        genvar ii;
        for(ii = 0; ii < WIDTH; ii = ii + PIPE_STAGE_WIDTH) begin : ADD_STAGE
            final_addition_stage #(.WIDTH(PIPE_STAGE_WIDTH), .SR_WIDTH(WIDTH)) stage (
                .in1(in1_sr[ii/PIPE_STAGE_WIDTH]), 
                .in2(in2_sr[ii/PIPE_STAGE_WIDTH]), 
                .in1_sr(in1_sr[1+ii/PIPE_STAGE_WIDTH]), 
                .in2_sr(in2_sr[1+ii/PIPE_STAGE_WIDTH]),
                .carry_in(carry[ii / PIPE_STAGE_WIDTH]), 
                .out(out[ii +: PIPE_STAGE_WIDTH]),
                .carry_out(carry[(ii / PIPE_STAGE_WIDTH) + 1]), 
                .clk(clk), 
                .pipelined(pipeline_enable[ii / PIPE_STAGE_WIDTH])
            );
        end
    endgenerate

    integer jj;
    reg [PIPELINE_BITS-1:0] pipes_inv;
    always @(*) begin
        case(pipes)
            1: pipes_inv = 4;
            2: pipes_inv = 3;
            3: pipes_inv = 2;
            4: pipes_inv = 1;
            default: pipes_inv= pipes;
        endcase
        pipeline_enable = 8'bx; // Default to all zeros
        for (jj = 0; jj < WIDTH / PIPE_STAGE_WIDTH; jj = jj + 1) begin
            pipeline_enable[WIDTH / PIPE_STAGE_WIDTH -1 - jj] = jj%(pipes_inv)==0 & pipes_inv!=0;
        end
        pipeline_enable[WIDTH / PIPE_STAGE_WIDTH -1] = 1'b0;
    end
endmodule

module final_addition_stage
#(
    parameter SR_WIDTH = 16,
    parameter WIDTH = 2
)
(
    input [SR_WIDTH-1:0] in1,
    input [SR_WIDTH-1:0] in2,
    input clk,
    input pipelined,
    input carry_in,
    output carry_out,
    output [WIDTH-1:0] out,
    output [SR_WIDTH -1 :0] in1_sr,
    output [SR_WIDTH -1 :0] in2_sr    
);

    wire [WIDTH:0] carry;
    assign carry[0] = carry_in;
    wire [WIDTH-1:0] sum;
    wire [WIDTH-1:0] sum_r;
    wire c_o_r;

    generate
        genvar ii;
        for (ii = 0; ii < WIDTH; ii = ii + 1) begin : FA
            fa fa_inst (
                .a(in1[ii]), 
                .b(in2[ii]), 
                .c_i(carry[ii]), 
                .s(sum[ii]), 
                .c_o(carry[ii + 1])
            );
        end
    endgenerate

    flop #(WIDTH) flop_sum (
        .in(sum), 
        .clk(clk), 
        .out(sum_r)
    );

    flop #(1) flop_c_o (
        .in(carry[WIDTH]), 
        .clk(clk), 
        .out(c_o_r)
    );

    wire [SR_WIDTH-WIDTH -1 :0] in1_sr_reg;

    flop #(SR_WIDTH-WIDTH ) flop_in1_sr (
        .in(in1[SR_WIDTH -1 :WIDTH]), 
        .clk(clk), 
        .out(in1_sr_reg)
    );

    wire [SR_WIDTH-WIDTH -1 :0] in2_sr_reg;
    
    flop #(SR_WIDTH-WIDTH ) flop_in2_sr (
        .in(in2[SR_WIDTH -1 :WIDTH]), 
        .clk(clk), 
        .out(in2_sr_reg)
    );

    assign in1_sr[SR_WIDTH-WIDTH -1 :0]  = pipelined ? in1_sr_reg : in1[SR_WIDTH :WIDTH];
    assign in2_sr[SR_WIDTH-WIDTH -1 :0]  = pipelined ? in2_sr_reg : in2[SR_WIDTH -1 :WIDTH];
    assign in1_sr[SR_WIDTH -1 :SR_WIDTH-WIDTH] = 0;
    assign in2_sr[SR_WIDTH -1 :SR_WIDTH-WIDTH] = 0;
    
    assign out = pipelined ? sum_r : sum;
    assign carry_out = pipelined ? c_o_r : carry[WIDTH];

endmodule


//
//module tb_final_addition;
//
//    parameter WIDTH = 16;
//    parameter PIPELINE_BITS = 3;
//
//    // Inputs
//    reg [WIDTH-1:0] in1;
//    reg [WIDTH-1:0] in2;
//    reg clk;
//    reg [PIPELINE_BITS-1:0] pipes;
//
//    // Outputs
//    wire [WIDTH-1:0] out;
//
//    // Instantiate the Unit Under Test (UUT)
//    final_addition #(
//        .WIDTH(WIDTH),
//        .PIPELINE_BITS(PIPELINE_BITS)
//    ) uut (
//        .in1(in1),
//        .in2(in2),
//        .clk(clk),
//        .pipes(pipes),
//        .out(out)
//    );
//
//    // Clock generation
//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk; // 100MHz clock
//    end
//    integer ii;
//    // Stimulus
//    initial begin
//        $dumpvars;
//        // Initialize Inputs
//        in1 = 0;
//        in2 = 0;
//        pipes = 0;
//
//        // Wait for the global reset
//        #11;
//
//        // Apply test vectors
//        // Test case 1
//        pipes = 0;
//        in1 = 1;
//        in2 = 2;
//        #1;
//        if(in1+in2 == out)
//            $display("Correct! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);
//        else
//            $display("Error! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);
//        #100;
//
//        // Test case 2
//        pipes = 1;
//        in1 = 2500;
//        in2 = 7850;
//        #20;
//        if(in1+in2 == out)
//            $display("Correct! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);
//        else
//            $display("Error! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);        #100;
//
//
//        // Test case 3
//        pipes = 2;
//        in1 = 789;
//        in2 = 4562;
//        #40;
//        if(in1+in2 == out)
//            $display("Correct! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);
//        else
//            $display("Error! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);        #100;
//
//        // Test case 4
//        pipes = 3;
//        in1 = 4562;
//        in2 = 4544;
//        #80;
//        if(in1+in2 == out)
//            $display("Correct! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);
//        else
//            $display("Error! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);        // Finish simulation
//        #100;
//
//
//
//        pipes = 4;
//        in1 = 4562;
//        in2 = 4544;
//        #160;
//        if(in1+in2 == out)
//            $display("Correct! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);
//        else
//            $display("Error! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);        // Finish simulation
//        #100;
//
//        
//        for(ii=0; ii<50; ii= ii+1) begin
//            pipes = $urandom_range(0, 3);
//            in1 = $random;
//            in2 = $random;
//            #(pipes*10);
//            if(in1+in2 == out)
//                $display("Correct! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);
//            else
//                $display("Error! Test Case 1: in1 = %d, in2 = %d, pipes = %d, out = %d", in1, in2, pipes, out);        // Finish simulation
//        end
//        #100;
//        $finish;
//    end
//
//endmodule
