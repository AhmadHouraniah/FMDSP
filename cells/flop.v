module flop(clk, in, out);
   parameter NN=16;

   input clk;
   input [NN-1:0] in;
   output reg [NN-1:0] out;

   always @(posedge clk) begin
      out <= #1 in;
   end

endmodule


module flop_reset(clk, in, reset, out);
   parameter NN=16;

   input clk, reset;
   input [NN-1:0] in;
   output reg [NN-1:0] out;

   always @(posedge clk and posedge reset) begin
      if(reset)
         out <= #1 0;
      else
         out <= #1 in;
   end

endmodule
