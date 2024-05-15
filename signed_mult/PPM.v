module mult(input [3:0] a, input [3:0] b, output [7:0] result1, output [7:0] result2);

	wire stage_0_0_0 = a[0]&b[0];
	wire stage_0_0_1 = a[0]&b[1];
	wire stage_0_0_2 = a[0]&b[2];
	wire stage_0_0_3 = a[0]&~b[3];
	wire stage_0_1_3 = 1'b1;
	wire stage_0_1_1 = a[1]&b[0];
	wire stage_0_1_2 = a[1]&b[1];
	wire stage_0_2_3 = a[1]&b[2];
	wire stage_0_0_4 = a[1]&~b[3];
	wire stage_0_1_4 = 1'b1;
	wire stage_0_2_2 = a[2]&b[0];
	wire stage_0_3_3 = a[2]&b[1];
	wire stage_0_2_4 = a[2]&b[2];
	wire stage_0_0_5 = a[2]&~b[3];
	wire stage_0_1_5 = 1'b1;
	wire stage_0_4_3 = a[3]&b[0];
	wire stage_0_3_4 = a[3]&b[1];
	wire stage_0_2_5 = a[3]&b[2];
	wire stage_0_0_6 = a[3]&~b[3];
	wire stage_0_1_6 = 1'b1;
	wire stage_1_0_0 = stage_0_0_0;
	wire stage_1_0_1 = stage_0_0_1;
	wire stage_1_1_1 = stage_0_1_1;
	FA FA_0 (.a(stage_0_0_2), .b(stage_0_0_2), .cin(1'b0), .out(stage_1_0_2), .cout(stage_1_1_2));
	FA FA_1 (.a(stage_0_1_1), .b(stage_0_0_3), .cin(cout), .out(stage_1_0_1), .cout(stage_1_1_2));
	FA FA_2 (.a(stage_0_1_0), .b(stage_0_0_4), .cin(cout), .out(stage_1_0_0), .cout(stage_1_1_2));
	wire stage_1_1_2 = cout;
	FA FA_3 (.a(stage_0_0_3), .b(stage_0_0_3), .cin(1'b0), .out(stage_1_0_3), .cout(stage_1_1_3));
	FA FA_4 (.a(stage_0_1_2), .b(stage_0_0_4), .cin(cout), .out(stage_1_0_2), .cout(stage_1_1_3));
	FA FA_5 (.a(stage_0_1_1), .b(stage_0_0_5), .cin(cout), .out(stage_1_0_1), .cout(stage_1_1_3));
	FA FA_6 (.a(stage_0_1_0), .b(stage_0_0_6), .cin(cout), .out(stage_1_0_0), .cout(stage_1_1_3));
	wire stage_1_1_3 = cout;
	FA FA_7 (.a(stage_0_0_4), .b(stage_0_0_4), .cin(1'b0), .out(stage_1_0_4), .cout(stage_1_1_4));
	FA FA_8 (.a(stage_0_1_3), .b(stage_0_0_5), .cin(cout), .out(stage_1_0_3), .cout(stage_1_1_4));
	FA FA_9 (.a(stage_0_1_2), .b(stage_0_0_6), .cin(cout), .out(stage_1_0_2), .cout(stage_1_1_4));
	wire stage_1_1_4 = cout;
	HA HA_10 (.a(stage_0_0_5), .b(stage_0_1_5), .out(stage_1_0_5), .cout(stage_1_1_5));
	wire stage_1_0_6 = stage_0_0_6;
	assign result1 = {stage_None_0_0, stage_None_0_1, stage_None_0_2, stage_None_0_3, stage_None_0_4, stage_None_0_5, stage_None_0_6, stage_None_0_7};
	assign result2 = {stage_None_1_0, stage_None_1_1, stage_None_1_2, stage_None_1_3, stage_None_1_4, stage_None_1_5, stage_None_1_6, stage_None_1_7};
endmodule

module FA(input a, input b, input cin, output out, output cout);
	assign {cout, out} = a+b+cin;
endmodule

module HA(input a, input b, output out, output cout);
	assign {cout, out} = a+b;
endmodule

