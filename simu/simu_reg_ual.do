vlib work
vcom -93 ../src/register_board.vhd
vcom -93 ../src/UAL.vhd
vcom -93 tb_reg_ual.vhd
vsim tb_reg_ual
add wave *
run -a