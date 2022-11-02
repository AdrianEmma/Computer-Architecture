vlib work
vmap work work

vcom -93 ../vhdl/controller.vhd
vcom -93 ../testbench/check_functions.vhd
vcom -93 ../testbench/tb_Controller.vhd

vsim -Gtext_in=Controller/in0.txt tb_Controller

add wave -hex controller_0/*

run -all
