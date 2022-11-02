library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        read    : out std_logic;
        write   : out std_logic;
        address : out std_logic_vector(15 downto 0);
        rddata  : in  std_logic_vector(31 downto 0);
        wrdata  : out std_logic_vector(31 downto 0)
    );
end controller;

architecture synth of controller is
begin
end synth;
