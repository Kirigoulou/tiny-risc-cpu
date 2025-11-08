vlib work

vcom -93 ../src/mux21.vhd
vcom -93 ../src/sign_expander.vhd
vcom -93 ../src/processing_unit/memory.vhd
vcom -93 ../src/processing_unit/processing_unit.vhd
vcom -93 ../src/processing_unit/register_board.vhd
vcom -93 ../src/processing_unit/UAL.vhd
vcom -93 tb_processing_unit.vhd

vsim tb_processing_unit
add wave *
run -a