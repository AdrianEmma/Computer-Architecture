library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(4 downto 0);
        op : in  std_logic_vector(2 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end shift_unit;

architecture synth of shift_unit is
begin
end synth;
