library ieee;
use ieee.std_logic_1164.all;

entity circuit is
  port (
    A : in std_logic;
    B : in std_logic;
    C : in std_logic;
    D : in std_logic;
    E : in std_logic;
    F : out std_logic
  );
end circuit;

architecture rtl of circuit is
begin

  F <=  A AND B when E = '0' else
        C OR D when E = '1' else
        '0';

end rtl;