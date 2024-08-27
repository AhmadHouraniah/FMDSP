module fa
(
	input   [0 : 0] a,
	input   [0 : 0] b,
	input   [0 : 0] c_i,
	output  [0 : 0] s,
	output  [0 : 0] c_o
);


	wire s_1,c_1,c_2;

	ha ha_1_comp (.a (a), .b(b), .s(s_1), .c(c_1));
	ha ha_2_comp (.a (s_1), .b(c_i), .s(s), .c(c_2));

	assign c_o = c_1 | c_2;

endmodule

