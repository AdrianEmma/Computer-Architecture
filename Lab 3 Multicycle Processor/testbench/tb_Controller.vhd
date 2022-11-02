library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.check_functions.all;

entity tb_Controller is
    generic(
        text_in : string := "Controller/in.txt"
    );
end;

architecture testbench of tb_Controller is
    signal finished    : boolean := false;
    signal currenttime : time    := 0 ns;
    constant FETCH1    : integer := 0;
    constant FETCH2    : integer := 1;
    constant DECODE    : integer := 2;
    constant R_OP      : integer := 3;
    constant RI_OP     : integer := 4;
    constant I_OP      : integer := 5;
    constant UI_OP     : integer := 6;
    constant LOAD1     : integer := 7;
    constant LOAD2     : integer := 8;
    constant STORE     : integer := 9;
    constant BRANCH    : integer := 10;
    constant CALL      : integer := 11;
    constant CALLR     : integer := 12;
    constant JMP       : integer := 13;
    constant BREAK     : integer := 14;
    constant JMPI      : integer := 15;
    constant HI_OP     : integer := 16;
    signal state       : integer := FETCH1;

    signal pc_counter : integer := 0;

    component controller is
        port(
            clk        : in  std_logic;
            reset_n    : in  std_logic;
            op         : in  std_logic_vector(5 downto 0);
            opx        : in  std_logic_vector(5 downto 0);
            branch_op  : out std_logic;
            imm_signed : out std_logic;
            ir_en      : out std_logic;
            pc_add_imm : out std_logic;
            pc_en      : out std_logic;
            pc_sel_a   : out std_logic;
            pc_sel_imm : out std_logic;
            rf_wren    : out std_logic;
            sel_addr   : out std_logic;
            sel_b      : out std_logic;
            sel_mem    : out std_logic;
            sel_pc     : out std_logic;
            sel_ra     : out std_logic;
            sel_rC     : out std_logic;
            read       : out std_logic;
            write      : out std_logic;
            op_alu     : out std_logic_vector(5 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 5 ns;

    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '0';
    signal op      : std_logic_vector(5 downto 0);
    signal opx     : std_logic_vector(5 downto 0);

    signal branch_op  : std_logic;
    signal imm_signed : std_logic;
    signal ir_en      : std_logic;
    signal pc_add_imm : std_logic;
    signal pc_en      : std_logic;
    signal pc_sel_a   : std_logic;
    signal pc_sel_imm : std_logic;
    signal rf_wren    : std_logic;
    signal sel_addr   : std_logic;
    signal sel_b      : std_logic;
    signal sel_mem    : std_logic;
    signal sel_pc     : std_logic;
    signal sel_ra     : std_logic;
    signal sel_rC     : std_logic;
    signal reads      : std_logic;
    signal write      : std_logic;
    signal op_alu     : std_logic_vector(5 downto 0);

    signal reg_read     : std_logic;
    signal sel_addr_reg : std_logic;

    function to_integer(x : std_logic) return integer is
    begin
        if x = '0' then
            return 0;
        else
            return 1;
        end if;
    end function to_integer;

begin
    controller_0 : controller port map(
            clk        => clk,
            reset_n    => reset_n,
            op         => op,
            opx        => opx,
            branch_op  => branch_op,
            imm_signed => imm_signed,
            ir_en      => ir_en,
            pc_add_imm => pc_add_imm,
            pc_en      => pc_en,
            pc_sel_a   => pc_sel_a,
            pc_sel_imm => pc_sel_imm,
            rf_wren    => rf_wren,
            sel_addr   => sel_addr,
            sel_b      => sel_b,
            sel_mem    => sel_mem,
            sel_pc     => sel_pc,
            sel_ra     => sel_ra,
            sel_rC     => sel_rC,
            read       => reads,
            write      => write,
            op_alu     => op_alu
        );

    check : process
        constant filename : string := "Controller/report.txt";
        file text_report : text is out filename;
        file text_input : text is in text_in;
        variable line_output : line;
        variable line_input  : line;
        variable counter     : integer := 0;
        variable timeout     : integer := 0;

        variable success : boolean := true;

        variable op_alu_mask : std_logic_vector(5 downto 0);
        variable op_alu_cmp  : std_logic_vector(5 downto 0);

        variable INT        : integer;
        variable SINGLE_BIT : std_logic;
        variable NIBBLE     : std_logic_vector(7 downto 0);
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
                hread(line_input, NIBBLE);
                op <= NIBBLE(5 downto 0);
                hread(line_input, NIBBLE);
                opx <= NIBBLE(5 downto 0);
                read(line_input, INT);
                state <= INT;
                read(line_input, op_alu_mask);
                read(line_input, op_alu_cmp);

                wait until clk = '0';
                -- op_alu
                if (unsigned(op_alu_mask) /= 0) then
                    success := scheck(op_alu and op_alu_mask, op_alu_cmp and op_alu_mask, "op_alu", filename, counter, currenttime, " Verify the op_alu generation.") and success;
                end if;

                -- valid instruction when ir_en
                if (sel_addr_reg = '1') then
                    success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " The IR has been enabled too soon.") and success;
                end if;

                -- unconditional branch
                if (state = BRANCH and unsigned(op) = 6) then
                    if (pc_en = '0') then
                        success := bcheck(branch_op, '1', "branch_op", filename, counter, currenttime, " During BRANCH, branch_op has to be 1.") and success;
                        if (op_alu /= "011001" and (op_alu /= "011100" and op_alu /= "011101")) then
                            assert false
                                report "br: Make sure that with the given op_alu value, the ALU will always return 1."
                                severity WARNING;
                        end if;
                    end if;
                end if;

                case state is
                    when FETCH1 =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During FETCH, write has to be 0.") and success;
                        success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During FETCH, rf_wren has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During FETCH, branch_op has to be 0.") and success;
                        if (pc_en = '1') then
                            success := bcheck(pc_add_imm, '0', "pc_add_imm", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                            success := bcheck(pc_sel_a, '0', "pc_sel_a", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                            success := bcheck(pc_sel_imm, '0', "pc_sel_imm", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                        end if;
                    when FETCH2 =>
                        timeout := 0;
                        loop
                            success := bcheck(write, '0', "write", filename, counter, currenttime, " During FETCH, write has to be 0.") and success;
                            success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During FETCH, rf_wren has to be 0.") and success;
                            success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During FETCH, branch_op has to be 0.") and success;
                            if (pc_en = '1') then
                                success := bcheck(pc_add_imm, '0', "pc_add_imm", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                                success := bcheck(pc_sel_a, '0', "pc_sel_a", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                                success := bcheck(pc_sel_imm, '0', "pc_sel_imm", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                            end if;
                            if (ir_en = '0') then
                                if (timeout = 10) then
                                    finished    <= true;
                                    line_output := new string'("===================================================================");
                                    writeline(output, line_output);
                                    line_output := new string'("IR has not been activated... Simulation aborted.");
                                    writeline(output, line_output);
                                    line_output := new string'("===================================================================");
                                    writeline(output, line_output);
                                    wait;
                                end if;
                            else
                                success := bcheck(reg_read, '1', "read", filename, counter, currenttime, " Before activating ir_en, read has to be activated.") and success;
                                exit;
                            end if;
                            wait until clk = '0';
                            timeout := timeout + 1;
                        end loop;
                    when DECODE =>
                        success := icheck((pc_counter + to_integer(pc_en)), 1, "PC enable count", filename, counter, currenttime, " Before the Execute states, the PC must be enabled only once.") and success;
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During DECODE, write has to be 0.") and success;
                        success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During DECODE, rf_wren has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During FETCH, branch_op has to be 0.") and success;
                        if (pc_en = '1') then
                            success := bcheck(pc_add_imm, '0', "pc_add_imm", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                            success := bcheck(pc_sel_a, '0', "pc_sel_a", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                            success := bcheck(pc_sel_imm, '0', "pc_sel_imm", filename, counter, currenttime, " Before the Execute states, PC must be incremented of 4.") and success;
                        end if;
                    when R_OP =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During R_OP, write has to be 0.") and success;
                        success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During R_OP, pc_en has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During R_OP, ir_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During R_OP, branch_op has to be 0.") and success;
                        success := bcheck(sel_mem, '0', "sel_mem", filename, counter, currenttime, " During R_OP, sel_mem has to be 0.") and success;
                        success := bcheck(sel_pc, '0', "sel_pc", filename, counter, currenttime, " During R_OP, sel_pc has to be 0.") and success;
                        success := bcheck(sel_ra, '0', "sel_ra", filename, counter, currenttime, " During R_OP, sel_ra has to be 0.") and success;

                        success := bcheck(rf_wren, '1', "rf_wren", filename, counter, currenttime, " During R_OP, rf_wren has to be 1.") and success;
                        success := bcheck(sel_rC, '1', "sel_rC", filename, counter, currenttime, " During R_OP, sel_rC has to be 1.") and success;
                        success := bcheck(sel_b, '1', "sel_b", filename, counter, currenttime, " During R_OP, sel_b has to be 1.") and success;
                    when RI_OP =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During RI_OP, write has to be 0.") and success;
                        success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During RI_OP, pc_en has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During RI_OP, ir_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During RI_OP, branch_op has to be 0.") and success;
                        success := bcheck(sel_mem, '0', "sel_mem", filename, counter, currenttime, " During RI_OP, sel_mem has to be 0.") and success;
                        success := bcheck(sel_pc, '0', "sel_pc", filename, counter, currenttime, " During RI_OP, sel_pc has to be 0.") and success;
                        success := bcheck(sel_b, '0', "sel_b", filename, counter, currenttime, " During RI_OP, sel_b has to be 0.") and success;
                        success := bcheck(sel_ra, '0', "sel_ra", filename, counter, currenttime, " During RI_OP, sel_ra has to be 0.") and success;

                        success := bcheck(rf_wren, '1', "rf_wren", filename, counter, currenttime, " During RI_OP, rf_wren has to be 1.") and success;
                        success := bcheck(sel_rC, '1', "sel_rC", filename, counter, currenttime, " During RI_OP, sel_rC has to be 1.") and success;
                    when I_OP =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During I_OP, write has to be 0.") and success;
                        success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During I_OP, pc_en has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During I_OP, ir_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During I_OP, branch_op has to be 0.") and success;
                        success := bcheck(sel_mem, '0', "sel_mem", filename, counter, currenttime, " During I_OP, sel_mem has to be 0.") and success;
                        success := bcheck(sel_pc, '0', "sel_pc", filename, counter, currenttime, " During I_OP, sel_pc has to be 0.") and success;
                        success := bcheck(sel_b, '0', "sel_b", filename, counter, currenttime, " During I_OP, sel_b has to be 0.") and success;
                        success := bcheck(sel_ra, '0', "sel_ra", filename, counter, currenttime, " During I_OP, sel_ra has to be 0.") and success;
                        success := bcheck(sel_rC, '0', "sel_rC", filename, counter, currenttime, " During I_OP, sel_rC has to be 0.") and success;
                        success := bcheck(imm_signed, '1', "imm_signed", filename, counter, currenttime, " During UI_OP, imm_signed has to be 1.") and success;

                        success := bcheck(rf_wren, '1', "rf_wren", filename, counter, currenttime, " During I_OP, rf_wren has to be 1.") and success;
                    when UI_OP =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During UI_OP, write has to be 0.") and success;
                        success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During UI_OP, pc_en has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During UI_OP, ir_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During UI_OP, branch_op has to be 0.") and success;
                        success := bcheck(sel_mem, '0', "sel_mem", filename, counter, currenttime, " During UI_OP, sel_mem has to be 0.") and success;
                        success := bcheck(sel_pc, '0', "sel_pc", filename, counter, currenttime, " During UI_OP, sel_pc has to be 0.") and success;
                        success := bcheck(sel_b, '0', "sel_b", filename, counter, currenttime, " During UI_OP, sel_b has to be 0.") and success;
                        success := bcheck(sel_ra, '0', "sel_ra", filename, counter, currenttime, " During UI_OP, sel_ra has to be 0.") and success;
                        success := bcheck(sel_rC, '0', "sel_rC", filename, counter, currenttime, " During UI_OP, sel_rC has to be 0.") and success;
                        success := bcheck(imm_signed, '0', "imm_signed", filename, counter, currenttime, " During UI_OP, imm_signed has to be 0.") and success;

                        success := bcheck(rf_wren, '1', "rf_wren", filename, counter, currenttime, " During UI_OP, rf_wren has to be 1.") and success;
                    when LOAD1 =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During LOAD1, write has to be 0.") and success;
                        success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During LOAD1, pc_en has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During LOAD1, ir_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During LOAD1, branch_op has to be 0.") and success;
                        success := bcheck(sel_b, '0', "sel_b", filename, counter, currenttime, " During LOAD1, sel_b has to be 0.") and success;
                        success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During LOAD1, rf_wren has to be 0.") and success;

                        success := bcheck(reads, '1', "read", filename, counter, currenttime, " During LOAD1, read has to be 1.") and success;
                        success := bcheck(sel_addr, '1', "sel_addr", filename, counter, currenttime, " During LOAD1, sel_addr has to be 1.") and success;
                        success := bcheck(imm_signed, '1', "imm_signed", filename, counter, currenttime, " During LOAD1, imm_signed has to be 1.") and success;
                    when LOAD2 =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During LOAD2, write has to be 0.") and success;
                        success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During LOAD2, pc_en has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During LOAD2, ir_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During LOAD2, branch_op has to be 0.") and success;
                        success := bcheck(sel_pc, '0', "sel_pc", filename, counter, currenttime, " During LOAD2, sel_pc has to be 0.") and success;
                        success := bcheck(sel_ra, '0', "sel_ra", filename, counter, currenttime, " During LOAD2, sel_ra has to be 0.") and success;
                        success := bcheck(sel_rC, '0', "sel_rC", filename, counter, currenttime, " During LOAD2, sel_rC has to be 0.") and success;

                        success := bcheck(sel_mem, '1', "sel_mem", filename, counter, currenttime, " During LOAD2, sel_mem has to be 1.") and success;
                        success := bcheck(rf_wren, '1', "rf_wren", filename, counter, currenttime, " During LOAD2, rf_wren has to be 1.") and success;
                    when STORE =>
                        success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During STORE, pc_en has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During STORE, ir_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During STORE, branch_op has to be 0.") and success;
                        success := bcheck(sel_b, '0', "sel_b", filename, counter, currenttime, " During STORE, sel_b has to be 0.") and success;
                        success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During STORE, rf_wren has to be 0.") and success;

                        success := bcheck(sel_addr, '1', "sel_addr", filename, counter, currenttime, " During STORE, sel_addr has to be 1.") and success;
                        success := bcheck(imm_signed, '1', "imm_signed", filename, counter, currenttime, " During STORE, imm_signed has to be 1.") and success;
                        success := bcheck(write, '1', "write", filename, counter, currenttime, " During STORE, write has to be 1.") and success;
                    when BRANCH =>
                        if (unsigned(op) /= 6) then
                            success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During BRANCH, pc_en has to be 0.") and success;
                            success := bcheck(branch_op, '1', "branch_op", filename, counter, currenttime, " During BRANCH, branch_op has to be 1.") and success;
                        end if;
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During BRANCH, write has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During BRANCH, ir_en has to be 0.") and success;
                        success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During BRANCH, rf_wren has to be 0.") and success;

                        success := bcheck(branch_op, '1', "branch_op", filename, counter, currenttime, " During BRANCH, branch_op has to be 1.") and success;
                        --success := bcheck(imm_signed, '1', "imm_signed", filename, counter, currenttime, " During BRANCH, imm_signed has to be 1.") and success;
                        success := bcheck(sel_b, '1', "sel_b", filename, counter, currenttime, " During BRANCH, sel_b has to be 1.") and success;
                        success := bcheck(pc_add_imm, '1', "pc_add_imm", filename, counter, currenttime, " During BRANCH, pc_add_imm has to be 1.") and success;
                    when CALL =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During CALL, write has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During CALL, ir_en has to be 0.") and success;
                        success := bcheck(pc_add_imm, '0', "pc_add_imm", filename, counter, currenttime, " During CALL, pc_add_imm has to be 0.") and success;
                        success := bcheck(pc_sel_a, '0', "pc_sel_a", filename, counter, currenttime, " During CALL, pc_sel_a has to be 0.") and success;
                        success := bcheck(sel_rC, '0', "sel_rC", filename, counter, currenttime, " During CALL, sel_rC has to be 0.") and success;

                        success := bcheck(pc_sel_imm, '1', "pc_sel_imm", filename, counter, currenttime, " During CALL, pc_sel_imm has to be 1.") and success;
                        success := bcheck(rf_wren, '1', "rf_wren", filename, counter, currenttime, " During CALL, rf_wren has to be 1.") and success;
                        success := bcheck(pc_en, '1', "pc_en", filename, counter, currenttime, " During CALL, pc_en has to be 1.") and success;
                        success := bcheck(sel_pc, '1', "sel_pc", filename, counter, currenttime, " During CALL, sel_pc has to be 1.") and success;
                        success := bcheck(sel_ra, '1', "sel_ra", filename, counter, currenttime, " During CALL, sel_ra has to be 1.") and success;
                    when CALLR =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During CALLR, write has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During CALLR, ir_en has to be 0.") and success;
                        success := bcheck(pc_add_imm, '0', "pc_add_imm", filename, counter, currenttime, " During CALLR, pc_add_imm has to be 0.") and success;
                        success := bcheck(pc_sel_imm, '0', "pc_sel_imm", filename, counter, currenttime, " During CALLR, pc_sel_imm has to be 0.") and success;

                        success := bcheck(pc_sel_a, '1', "pc_sel_a", filename, counter, currenttime, " During CALLR, pc_sel_a has to be 1.") and success;
                        success := bcheck(rf_wren, '1', "rf_wren", filename, counter, currenttime, " During CALLR, rf_wren has to be 1.") and success;
                        success := bcheck(pc_en, '1', "pc_en", filename, counter, currenttime, " During CALLR, pc_en has to be 1.") and success;
                        success := bcheck(sel_pc, '1', "sel_pc", filename, counter, currenttime, " During CALLR, sel_pc has to be 1.") and success;
                        success := bcheck(sel_rC or sel_ra, '1', "sel_rC", filename, counter, currenttime, " During CALLR, sel_rC or sel_ra has to be 1.") and success;
                    when JMP =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During JMP, write has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During JMP, ir_en has to be 0.") and success;
                        success := bcheck(pc_add_imm, '0', "pc_add_imm", filename, counter, currenttime, " During JMP, pc_add_imm has to be 0.") and success;
                        success := bcheck(pc_sel_imm, '0', "pc_sel_imm", filename, counter, currenttime, " During JMP, pc_sel_imm has to be 0.") and success;
                        success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During JMP, rf_wren has to be 0.") and success;

                        success := bcheck(pc_sel_a, '1', "pc_sel_a", filename, counter, currenttime, " During JMP, pc_sel_a has to be 1.") and success;
                        success := bcheck(pc_en, '1', "pc_en", filename, counter, currenttime, " During JMP, pc_en has to be 1.") and success;
                    when BREAK =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During BREAK, write has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During BREAK, ir_en has to be 0.") and success;
                        success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During BREAK, rf_wren has to be 0.") and success;
                        success := bcheck(pc_en, '0', "pc_en", filename, counter, currenttime, " During BREAK, pc_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During BREAK, branch_op has to be 0.") and success;
                    when JMPI =>
                        success := bcheck(write, '0', "write", filename, counter, currenttime, " During JMPI, write has to be 0.") and success;
                        success := bcheck(ir_en, '0', "ir_en", filename, counter, currenttime, " During JMPI, ir_en has to be 0.") and success;
                        success := bcheck(branch_op, '0', "branch_op", filename, counter, currenttime, " During JMPI, branch_op has to be 0.") and success;
                        success := bcheck(pc_add_imm, '0', "pc_add_imm", filename, counter, currenttime, " During JMPI, pc_add_imm has to be 0.") and success;
                        success := bcheck(pc_sel_a, '0', "pc_sel_a", filename, counter, currenttime, " During JMPI, pc_sel_a has to be 0.") and success;
                        success := bcheck(rf_wren, '0', "rf_wren", filename, counter, currenttime, " During JMPI, rf_wren has to be 0.") and success;

                        success := bcheck(pc_sel_imm, '1', "pc_sel_imm", filename, counter, currenttime, " During JMPI, pc_sel_imm has to be 1.") and success;
                        success := bcheck(pc_en, '1', "pc_en", filename, counter, currenttime, " During JMPI, pc_en has to be 1.") and success;
                    when others =>
                end case;

            end if;
        end if;
    end process;

    process(reset_n, clk)
    begin
        if (reset_n = '0') then
            pc_counter <= 0;
        elsif (rising_edge(clk)) then
            sel_addr_reg <= sel_addr;
            reg_read     <= reads;
            if (pc_en = '1' and (state < DECODE)) then
                pc_counter <= pc_counter + 1;
            elsif (state >= DECODE) then
                pc_counter <= 0;
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
