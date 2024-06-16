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
   output [NN-1:0] out;
   reg [NN-1:0] data;
   assign out = reset? 0 : data;
   
   always @(posedge clk or posedge reset) begin
      if(reset)
         data <= #1 0;
      else 
         data <= #1 in;

   end

endmodule
