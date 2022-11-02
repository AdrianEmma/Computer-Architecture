vlib work
vmap work work

vcom -93 ../vhdl/extend.vhd
vcom -93 ../testbench/check_functions.vhd
vcom -93 ../testbench/tb_Extend.vhd

vsim tb_Extend

add wave -hex extend_0/*

run -all
