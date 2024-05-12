
module ha
(
	input   [0 : 0] a,
	input   [0 : 0] b,
	output  [0 : 0] s,
	output  [0 : 0] c
);


	assign s = a ^ b;
	assign c = a & b;

endmodule