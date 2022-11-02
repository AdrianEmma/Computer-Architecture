library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.check_functions.all;

entity tb_IR is
end;

architecture testbench of tb_IR is
    signal finished    : boolean := false;
    signal currenttime : time    := 0 ns;

    component IR is
        port(
            clk    : in  std_logic;
            enable : in  std_logic;
            D      : in  std_logic_vector(31 downto 0);
            Q      : out std_logic_vector(31 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 5 ns;

    signal clk    : std_logic := '0';
    signal enable : std_logic := '0';

    signal D : std_logic_vector(31 downto 0) := (others => '0');
    signal Q : std_logic_vector(31 downto 0);

begin
    ir_0 : IR port map(
            clk    => clk,
            enable => enable,
            D      => D,
            Q      => Q
        );

    check : process
        constant filename : string := "IR/report.txt";
        file text_report : text is out filename;
        variable line_output : line;
        file text_input : text is in "IR/in.txt";
        variable line_input : line;
        variable counter    : integer := 0;

        variable success : boolean := true;

        variable valid : std_logic;
        variable Q_cmp : std_logic_vector(31 downto 0);

        variable SINGLE_BIT : std_logic;
        variable WORD       : std_logic_vector(31 downto 0);
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
                enable <= SINGLE_BIT;
                hread(line_input, WORD);
                D <= WORD;

                wait until clk = '0';

                read(line_input, valid);
                hread(line_input, Q_cmp);

                if (valid = '1') then
                    success := hcheck(Q, Q_cmp, "Q", filename, counter, currenttime, "") and success;
                end if;
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
