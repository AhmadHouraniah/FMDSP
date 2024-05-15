module compressor(in1, in2, in3, out1, out2);
   parameter NN=16;

   input [NN-1:0] in1, in2, in3;
   output reg [NN:0] out1, out2;

   integer ii;
   always @* begin
      out2[0] = 1'b0;
      for(ii=0; ii<NN; ii=ii+1) begin
         {out2[ii+1], out1[ii]} = in1[ii] +in2[ii] +in3[ii];
      end
      out1[NN] = 1'b0;
   end
endmodule
