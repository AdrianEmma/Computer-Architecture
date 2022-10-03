library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port(
        clk    : in  std_logic;
        aa     : in  std_logic_vector(4 downto 0);
        ab     : in  std_logic_vector(4 downto 0);
        aw     : in  std_logic_vector(4 downto 0);
        wren   : in  std_logic;
        wrdata : in  std_logic_vector(31 downto 0);
        a      : out std_logic_vector(31 downto 0);
        b      : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture synth of register_file is
    type reg_type is array(0 to 31) of std_logic_vector(31 downto 0);
    signal reg : reg_type;
begin
    write_read : process(clk, aa, ab, aw, wren, wrdata) 
    begin 
        reg(0) <= std_logic_vector(31 downto 0 => '0')
        if rising_edge(clk) then
            if wren = '0' then
                a <= reg(to_integer(unsigned(aa)));
                b <= reg(to_integer(unsigned(ab)));
            end if;    
            if wren = '1' then
                reg(to_integer(unsigned(aw))) <= wrdata;
            end if;
        end if;
    end process write_read;
end synth;
