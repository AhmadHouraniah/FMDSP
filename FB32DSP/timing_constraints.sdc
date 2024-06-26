
create_clock [get_ports clk] -name clk -period $::env(CLOCK_PERIOD)

# Clock non-idealities
set_propagated_clock [all_clocks]
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINTY) [get_clocks {clk}]
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [get_clocks {clk}]

# Maximum transition time for the design nets
set_max_transition $::env(MAX_TRANSITION_CONSTRAINT) [current_design]

# Maximum fanout
set_max_fanout $::env(MAX_FANOUT_CONSTRAINT) [current_design]

# Timing paths delays derate
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]

# Multicycle paths
#set_multicycle_path -setup 2 -through [get_ports {wbs_ack_o}]
#set_multicycle_path -hold 1  -through [get_ports {wbs_ack_o}]
#set_multicycle_path -setup 2 -through [get_ports {wbs_cyc_i}]
#set_multicycle_path -hold 1  -through [get_ports {wbs_cyc_i}]
#set_multicycle_path -setup 2 -through [get_ports {wbs_stb_i}]
#set_multicycle_path -hold 1  -through [get_ports {wbs_stb_i}]

# Clock source latency
set clk_max_latency 5.57
set clk_min_latency 4.65
set_clock_latency -source -max $clk_max_latency [get_clocks {clk}]
set_clock_latency -source -min $clk_min_latency [get_clocks {clk}]

# Clock input Transition
set clk_tran 0.61
set_input_transition $clk_tran [get_ports {clk}]

# Input delays
set_input_delay -max 2 -clock [get_clocks {clk}] [all_inputs]

# Input Transition
set_input_transition -max 0.14  [all_inputs]

# Output delays
set_output_delay -max 2  -clock [get_clocks {clk}] [all_outputs]

# Output loads
set_load 0.19 [all_outputs]

set_case_analysis 0 [get_ports mode[0]]
set_case_analysis 0 [get_ports mode[1]]


report_checks -path min 



set_case_analysis 1 [get_ports mode[0]]
set_case_analysis 0 [get_ports mode[1]]


report_checks -path min 



set_case_analysis 0 [get_ports mode[1]]
set_case_analysis 1 [get_ports mode[0]]


report_checks -path min 


unset_case_analysis [get_ports mode[1]]
unset_case_analysis [get_ports mode[0]]


set_case_analysis 0 [get_ports pipe_stages[0]]
set_case_analysis 0 [get_ports pipe_stages[1]]
set_case_analysis 0 [get_ports pipe_stages[2]]


report_checks -path min 


set_case_analysis 1 [get_ports pipe_stages[0]]
set_case_analysis 0 [get_ports pipe_stages[1]]
set_case_analysis 0 [get_ports pipe_stages[2]]



report_checks -path min 


set_case_analysis 0 [get_ports pipe_stages[0]]
set_case_analysis 1 [get_ports pipe_stages[1]]
set_case_analysis 0 [get_ports pipe_stages[2]]


report_checks -path min 


set_case_analysis 1 [get_ports pipe_stages[0]]
set_case_analysis 1 [get_ports pipe_stages[1]]
set_case_analysis 0 [get_ports pipe_stages[2]]

report_checks -path min 


set_case_analysis 0 [get_ports pipe_stages[0]]
set_case_analysis 0 [get_ports pipe_stages[1]]
set_case_analysis 1 [get_ports pipe_stages[2]]

report_checks -path min 

unset_case_analysis [get_ports pipe_stages[0]]
unset_case_analysis [get_ports pipe_stages[1]]
unset_case_analysis [get_ports pipe_stages[2]]
