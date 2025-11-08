vlib work
vcom -93 ../src/mux21.vhd
vcom -93 ../src/sign_expander.vhd
vcom -93 ../src/instruction_control_unit/instruction_memory.vhd
vcom -93 ../src/instruction_control_unit/program_counter.vhd
vcom -93 ../src/instruction_control_unit/instruction_control_unit.vhd
vcom -93 tb_instruction_control_unit.vhd
vsim tb_instruction_control_unit
add wave *
run -a