library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.check_functions.all;

entity tb_Extend is
end;

architecture testbench of tb_Extend is
    signal finished    : boolean := false;
    signal currenttime : time    := 0 ns;

    component extend is
        port(
            imm16  : in  std_logic_vector(15 downto 0);
            signed : in  std_logic;
            imm32  : out std_logic_vector(31 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 5 ns;

    signal clk    : std_logic := '0';
    signal signed : std_logic := '0';

    signal imm16 : std_logic_vector(15 downto 0) := (others => '0');
    signal imm32 : std_logic_vector(31 downto 0);

begin
    extend_0 : extend port map(
            signed => signed,
            imm16  => imm16,
            imm32  => imm32
        );

    check : process
        constant filename : string := "Extend/report.txt";
        file text_report : text is out filename;
        variable line_output : line;
        file text_input : text is in "Extend/in.txt";
        variable line_input : line;
        variable counter    : integer := 0;

        variable success : boolean := true;

        variable valid     : std_logic;
        variable imm32_cmp : std_logic_vector(31 downto 0);

        variable SINGLE_BIT : std_logic;
        variable HWORD      : std_logic_vector(15 downto 0);
    begin
        line_input := new string'("");

        if (endfile(text_input)) then
            finished    <= true;
            line_output := new string'("===================================================================");
            writeline(output, line_output);
            if (success) then
                line_output := new string'("Simulation is successful");
            else
                line_output := new string'("Errors encountered during simulation. Refer to the report.txt file.");
            end if;
            writeline(output, line_output);
            line_output := new string'("===================================================================");
            writeline(output, line_output);
            wait;
        end if;
        counter := counter + 1;

        readline(text_input, line_input);

        if (line_input'length /= 0) then
            if (line_input(1) = '-') then -- Print message
                line_output := line_input;
                writeline(output, line_input);
            elsif (line_input(1) /= '#') then
                wait until clk = '1';

                read(line_input, SINGLE_BIT);
                signed <= SINGLE_BIT;

                hread(line_input, HWORD);
                imm16 <= HWORD;

                wait until clk = '0';

                hread(line_input, imm32_cmp);

                success := hcheck(imm32, imm32_cmp, "imm32", filename, counter, currenttime, "") and success;

            end if;
        end if;
    end process;

    process
    begin
        if (finished) then
            wait;
        else
            clk <= not clk;
            wait for CLK_PERIOD / 2;
            currenttime <= currenttime + CLK_PERIOD / 2;
        end if;
    end process;

end testbench;
