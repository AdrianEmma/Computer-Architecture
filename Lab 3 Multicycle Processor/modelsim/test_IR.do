vlib work
vmap work work

vcom -93 ../vhdl/IR.vhd
vcom -93 ../testbench/check_functions.vhd
vcom -93 ../testbench/tb_IR.vhd

vsim tb_IR

add wave -hex ir_0/*

run -all
