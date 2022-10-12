library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

package check_functions is
    function scheck(
        original       : in std_logic_vector;
        comp           : in std_logic_vector;
        name, filename : in string;
        counter        : in integer;
        currenttime    : in time;
        message        : in string) return boolean;

    function icheck(
        original       : in integer;
        comp           : in integer;
        name, filename : in string;
        counter        : in integer;
        currenttime    : in time;
        message        : in string) return boolean;

    function hcheck(
        original       : in std_logic_vector;
        comp           : in std_logic_vector;
        name, filename : in string;
        counter        : in integer;
        currenttime    : in time;
        message        : in string) return boolean;

    function bcheck(
        original       : in std_logic;
        comp           : in std_logic;
        name, filename : in string;
        counter        : in integer;
        currenttime    : in time;
        message        : in string) return boolean;
end check_functions;

package body check_functions is
    function scheck(
        original       : in std_logic_vector;
        comp           : in std_logic_vector;
        name, filename : in string;
        counter        : in integer;
        currenttime    : in time;
        message        : in string) return boolean is
        variable line_output : line;
        file text_report : text is out filename;
    begin
        if (original /= comp) then
            assert false
                report "Unexpected output value for " & name
                severity error;
            line_output := new string'("Time: ");
            write(line_output, currenttime);
            write(line_output, string'(" Input File Line: "));
            write(line_output, counter);
            writeline(text_report, line_output);
            write(line_output, string'("* Error: " & name & " = '"));
            write(line_output, original);
            write(line_output, string'("' instead of '"));
            write(line_output, comp);
            write(line_output, string'("'."));
            writeline(text_report, line_output);
            write(line_output, message);
            writeline(text_report, line_output);
            writeline(text_report, line_output);
            return false;
        else
            return true;
        end if;
    end scheck;

    function icheck(
        original       : in integer;
        comp           : in integer;
        name, filename : in string;
        counter        : in integer;
        currenttime    : in time;
        message        : in string) return boolean is
        variable line_output : line;
        file text_report : text is out filename;
    begin
        if (original /= comp) then
            assert false
                report "Unexpected output value for " & name
                severity error;
            line_output := new string'("Time: ");
            write(line_output, currenttime);
            write(line_output, string'(" Input File Line: "));
            write(line_output, counter);
            writeline(text_report, line_output);
            write(line_output, string'("* Error: " & name & " = "));
            write(line_output, original);
            write(line_output, string'(" instead of "));
            write(line_output, comp);
            write(line_output, string'("."));
            writeline(text_report, line_output);
            write(line_output, message);
            writeline(text_report, line_output);
            writeline(text_report, line_output);
            return false;
        else
            return true;
        end if;
    end icheck;

    function hcheck(
        original       : in std_logic_vector;
        comp           : in std_logic_vector;
        name, filename : in string;
        counter        : in integer;
        currenttime    : in time;
        message        : in string) return boolean is
        variable line_output : line;
        file text_report : text is out filename;
    begin
        if (original /= comp) then
            assert false
                report "Unexpected output value for " & name
                severity error;
            line_output := new string'("Time: ");
            write(line_output, currenttime);
            write(line_output, string'(" Input File Line: "));
            write(line_output, counter);
            writeline(text_report, line_output);
            write(line_output, string'("* Error: " & name & " = 0x"));
            hwrite(line_output, original);
            write(line_output, string'(" instead of 0x"));
            hwrite(line_output, comp);
            write(line_output, string'("."));
            writeline(text_report, line_output);
            write(line_output, message);
            writeline(text_report, line_output);
            writeline(text_report, line_output);
            return false;
        else
            return true;
        end if;
    end hcheck;

    function bcheck(
        original       : in std_logic;
        comp           : in std_logic;
        name, filename : in string;
        counter        : in integer;
        currenttime    : in time;
        message        : in string) return boolean is
        variable line_output : line;
        file text_report : text is out filename;
    begin
        if (original /= comp) then
            assert false
                report "Unexpected output value for " & name
                severity error;
            line_output := new string'("Time: ");
            write(line_output, currenttime);
            write(line_output, string'(" Input File Line: "));
            write(line_output, counter);
            writeline(text_report, line_output);
            write(line_output, string'("* Error: " & name & " = '"));
            write(line_output, original);
            write(line_output, string'("' instead of '"));
            write(line_output, comp);
            write(line_output, string'("'."));
            writeline(text_report, line_output);
            write(line_output, message);
            writeline(text_report, line_output);
            writeline(text_report, line_output);
            return false;
        else
            return true;
        end if;
    end bcheck;

end check_functions;
