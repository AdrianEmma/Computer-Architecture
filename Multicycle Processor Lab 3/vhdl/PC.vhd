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
    inc_address : process(clk, reset_n)
    begin
        -- Asynchronous Program Counter RESET
        if reset_n='0' then
            counter <= x"0000";
        elsif rising_edge(clk) and en='1' then
            if add_imm = '1' then
                counter <= std_logic_vector(unsigned(counter) + unsigned(imm));
            elsif sel_imm = '1' then
                counter <= std_logic_vector(shift_left(unsigned(imm), 2));
            elsif sel_a = '1' then
                counter <= a;
            else    
                counter <= std_logic_vector(unsigned(counter) + 4);
            end if;
        end if;
    end process inc_address;
    
    -- Update address
    addr <= x"0000" & counter(15 downto 2) & "00";

end synth;
