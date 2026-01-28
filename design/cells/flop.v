module flop(clk, in, out);
   parameter NN=16;

   input clk;
   input [NN-1:0] in;
   output reg [NN-1:0] out;

   always @(posedge clk) begin
      out <= in;
   end

endmodule

