iverilog -o out.run tb.v DSP_model.v mcmult2o.v mult_wrapper.v compressor.v cells/flop.v cells/ha.v cells/fa.v dadda.v wallace.v ; vvp out.run
