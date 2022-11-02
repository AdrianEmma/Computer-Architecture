library ieee;
use ieee.std_logic_1164.all;

entity mux2x32 is
    port(
        i0  : in  std_logic_vector(31 downto 0);
        i1  : in  std_logic_vector(31 downto 0);
        sel : in  std_logic;
        o   : out std_logic_vector(31 downto 0)
    );
end mux2x32;

architecture synth of mux2x32 is
begin
    o <= i0 when sel='0' else i1;
end synth;
