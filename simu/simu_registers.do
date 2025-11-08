vlib work
vcom -93 ../src/register_board.vhd
vcom -93 tb_registers.vhd
vsim tb_registers
add wave *
run -a