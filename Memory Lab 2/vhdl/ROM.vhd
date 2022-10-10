library ieee;
use ieee.std_logic_1164.all;

library work;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is

COMPONENT ROM_Block
    PORT(
        address : in std_logic_vector(9 downto 0);
        clock   : in std_logic := '1';
        q       : out std_logic_vector(31 downto 0)
    );
END COMPONENT;

SIGNAL block_data : std_logic_vector(31 downto 0);

begin
    ROM_Block_inst : rom_block
    PORT MAP (
        address => address,
        clock   => clk,
        q       => block_data
    );

    rddata <= block_data when cs='1' and read='1' else (others => 'Z');
end synth;
