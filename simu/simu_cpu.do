vlib work

vcom -2008 ../src/mux21.vhd
vcom -2008 ../src/sign_expander.vhd

vcom -2008 ../src/processing_unit/memory.vhd
vcom -2008 ../src/processing_unit/processing_unit.vhd
vcom -2008 ../src/processing_unit/register_board.vhd
vcom -2008 ../src/processing_unit/UAL.vhd

vcom -2008 ../src/instruction_control_unit/instruction_control_unit.vhd
vcom -2008 ../src/instruction_control_unit/instruction_memory.vhd
vcom -2008 ../src/instruction_control_unit/program_counter.vhd

vcom -2008 ../src/control_unit/instruction_decoder.vhd
vcom -2008 ../src/control_unit/register_32b.vhd

vcom -2008 ../src/cpu.vhd

vcom -2008 tb_cpu.vhd

vsim tb_cpu
add wave *
run -a