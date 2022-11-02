library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.check_functions.all;

entity tb_PC is
end;

architecture testbench of tb_PC is
    signal finished    : boolean := false;
    signal currenttime : time    := 0 ns;

    component PC is
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
    end component;

    constant CLK_PERIOD : time := 5 ns;

    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '0';
    signal en      : std_logic := '0';
    signal sel_a   : std_logic := '0';
    signal sel_imm : std_logic := '0';
    signal add_imm : std_logic := '0';

    signal imm  : std_logic_vector(15 downto 0) := (others => '0');
    signal a    : std_logic_vector(15 downto 0) := (others => '0');
    signal addr : std_logic_vector(31 downto 0);

begin
    pc_0 : PC port map(
            clk     => clk,
            reset_n => reset_n,
            en      => en,
            sel_a   => sel_a,
            sel_imm => sel_imm,
            add_imm => add_imm,
            imm     => imm,
            a       => a,
            addr    => addr
        );

    check : process
        constant filename : string := "PC/report.txt";
        file text_report : text is out filename;
        variable line_output : line;
        file text_input : text is in "PC/in.txt";
        variable line_input : line;
        variable counter    : integer := 0;

        variable success : boolean := true;

        variable valid    : std_logic;
        variable addr_cmp : std_logic_vector(31 downto 0);

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
                reset_n <= SINGLE_BIT;
                read(line_input, SINGLE_BIT);
                en <= SINGLE_BIT;
                read(line_input, SINGLE_BIT);
                sel_a <= SINGLE_BIT;
                read(line_input, SINGLE_BIT);
                sel_imm <= SINGLE_BIT;
                read(line_input, SINGLE_BIT);
                add_imm <= SINGLE_BIT;

                hread(line_input, HWORD);
                imm <= HWORD;
                hread(line_input, HWORD);
                a <= HWORD;

                wait until clk = '0';

                read(line_input, valid);
                hread(line_input, addr_cmp);

                if (valid = '1' and addr_cmp /= addr) then
                    success := hcheck(addr, addr_cmp, "addr", filename, counter, currenttime, "") and success;
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
