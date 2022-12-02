library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port(
        address    : in  std_logic_vector(15 downto 0);
        cs_Buttons : out std_logic;
        cs_LEDS    : out std_logic;
        cs_RAM     : out std_logic;
        cs_ROM     : out std_logic
    );
end decoder;

architecture synth of decoder is
begin
end synth;
