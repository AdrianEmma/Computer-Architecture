-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.0.0 Build 211 04/27/2016 SJ Lite Edition"
-- CREATED		"Tue Oct 03 14:49:59 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY GECKO IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		reset_n :  IN  STD_LOGIC;
		in_buttons :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		row1 :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0);
		row2 :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0);
		row3 :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0);
		row4 :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0);
		row5 :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0);
		row6 :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0);
		row7 :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0);
		row8 :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END GECKO;

ARCHITECTURE bdf_type OF GECKO IS 

COMPONENT buttons
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 cs : IN STD_LOGIC;
		 read : IN STD_LOGIC;
		 write : IN STD_LOGIC;
		 address : IN STD_LOGIC;
		 buttons : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT decoder
	PORT(address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 cs_RAM : OUT STD_LOGIC;
		 cs_ROM : OUT STD_LOGIC;
		 cs_Buttons : OUT STD_LOGIC;
		 cs_LEDs : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT cpu
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 rddata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write : OUT STD_LOGIC;
		 read : OUT STD_LOGIC;
		 address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 wrdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT leds
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 cs : IN STD_LOGIC;
		 write : IN STD_LOGIC;
		 read : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 LEDs : OUT STD_LOGIC_VECTOR(95 DOWNTO 0);
		 rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram
	PORT(clk : IN STD_LOGIC;
		 cs : IN STD_LOGIC;
		 write : IN STD_LOGIC;
		 read : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rom
	PORT(clk : IN STD_LOGIC;
		 cs : IN STD_LOGIC;
		 read : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	address :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	cs_Buttons :  STD_LOGIC;
SIGNAL	cs_LEDs :  STD_LOGIC;
SIGNAL	cs_RAM :  STD_LOGIC;
SIGNAL	cs_ROM :  STD_LOGIC;
SIGNAL	out_LEDs :  STD_LOGIC_VECTOR(95 DOWNTO 0);
SIGNAL	rddata :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	wrdata :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;


BEGIN 



b2v_buttons_0 : buttons
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 cs => cs_Buttons,
		 read => SYNTHESIZED_WIRE_7,
		 write => SYNTHESIZED_WIRE_8,
		 address => address(2),
		 buttons => in_buttons,
		 wrdata => wrdata,
		 rddata => rddata);


b2v_decoder_0 : decoder
PORT MAP(address => address,
		 cs_RAM => cs_RAM,
		 cs_ROM => cs_ROM,
		 cs_Buttons => cs_Buttons,
		 cs_LEDs => cs_LEDs);


b2v_inst : cpu
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 rddata => rddata,
		 write => SYNTHESIZED_WIRE_8,
		 read => SYNTHESIZED_WIRE_7,
		 address => address,
		 wrdata => wrdata);


b2v_LEDs_0 : leds
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 cs => cs_LEDs,
		 write => SYNTHESIZED_WIRE_8,
		 read => SYNTHESIZED_WIRE_7,
		 address => address(3 DOWNTO 2),
		 wrdata => wrdata,
		 LEDs => out_LEDs,
		 rddata => rddata);


b2v_RAM_0 : ram
PORT MAP(clk => clk,
		 cs => cs_RAM,
		 write => SYNTHESIZED_WIRE_8,
		 read => SYNTHESIZED_WIRE_7,
		 address => address(11 DOWNTO 2),
		 wrdata => wrdata,
		 rddata => rddata);


b2v_ROM_0 : rom
PORT MAP(clk => clk,
		 cs => cs_ROM,
		 read => SYNTHESIZED_WIRE_7,
		 address => address(11 DOWNTO 2),
		 rddata => rddata);

row1(11 DOWNTO 0) <= out_LEDs(11 DOWNTO 0);
row2(11 DOWNTO 0) <= out_LEDs(23 DOWNTO 12);
row3(11 DOWNTO 0) <= out_LEDs(35 DOWNTO 24);
row4(11 DOWNTO 0) <= out_LEDs(47 DOWNTO 36);
row5(11 DOWNTO 0) <= out_LEDs(59 DOWNTO 48);
row6(11 DOWNTO 0) <= out_LEDs(71 DOWNTO 60);
row7(11 DOWNTO 0) <= out_LEDs(83 DOWNTO 72);
row8(11 DOWNTO 0) <= out_LEDs(95 DOWNTO 84);

END bdf_type;