library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
    signal counter : std_logic_vector(15 downto 0);
begin
    inc_address : process(clk)
    begin
        if rising_edge(clk) then
            if en='1' then
                counter <= std_logic_vector(unsigned(counter) + 4);
            else 
                if reset_n='1' then
                    counter <= x"0000";
                end if;
            end if;
        end if;
    addr <= x"0000" & counter(15 downto 2) & "00";
    end process inc_address;
end synth;
