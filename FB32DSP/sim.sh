iverilog -o out.run tb.v DSP_model.v mcmult2o.v ../cells/mult_wrapper.v ../cells/compressor.v ../cells/flop.v ../cells/ha.v ../cells/fa.v ../cells/dadda.v ../cells/wallace.v ; vvp out.run
