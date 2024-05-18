module compressor32(in1, in2, in3, out1, out2);
   parameter NN=16;

   input [NN-1:0] in1, in2, in3;
   output reg [NN:0] out1, out2;

   integer ii;
   always @* begin
      out2[0] = 1'b0;
      for(ii=0; ii<NN; ii=ii+1) begin
         {out2[ii+1], out1[ii]} = in1[ii] +in2[ii] +in3[ii];
      end
      //out1[NN-1] = in1[NN-1] +in2[NN-1] +in3[NN-1];
      out1[NN] = 1'b0;
   end
endmodule


module compressor42(in1, in2, in3, in4, out1, out2);
   parameter NN=16;

   input [NN-1:0] in1, in2, in3, in4;
   output [NN:0] out1, out2;
   wire [NN-1:0] l1, l2;

   compressor32 #(NN) comp1 (in1, in2, in3, {nc, l1}, {nc,l2});
   compressor32 #(NN) comp2 (l1, l2, in4, out1, out2);
endmodule
