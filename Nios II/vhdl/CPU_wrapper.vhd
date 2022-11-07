-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 32-bit"
-- VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
-- CREATED		"Wed Oct 30 17:22:54 2013"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;


	PORT
	(
		reset_n :  IN  STD_LOGIC;
		clk :  IN  STD_LOGIC;
		rddata :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		write :  OUT  STD_LOGIC;
		read :  OUT  STD_LOGIC;
		address :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		wrdata :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END CPU;

ARCHITECTURE bdf_type OF CPU IS 
BEGIN
END bdf_type;