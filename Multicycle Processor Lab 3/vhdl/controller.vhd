library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
    type state is (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, I_OP);
    signal current_state : state;
    signal next_state    : state;
begin

    state_machine : process(clk)
    begin
        if rising_edge(clk) then
            case current_state is

                -- State FETCH1 of FSM
                when FETCH1 =>
                    read <= '1';
                    rf_wren <= '0';
                    imm_signed <= '0';
                    sel_b <= '0';
                    sel_rC <= '0';
                    sel_mem <= '0';
                    next_state <= FETCH2; 

                -- State FETCH2 of FSM
                when FETCH2 =>
                    pc_en <= '1';
                    read <= '0';
                    ir_en <= '1';
                    next_state <= DECODE; 
                
                -- State DECODE of FSM
                when DECODE =>
                    pc_en <= '0';
                    ir_en <= '0';
                    case "00" & op is
                        when x"3A" =>
                            case "00" & opx is 
                                when x"34" => next_state <= BREAK;
                                when others => next_state <= R_OP;
                            end case;

                        when x"04" => next_state <= I_OP;
                        when x"17" => next_state <= LOAD1;
                        when x"15" => next_state <= STORE;

                    end case;

                -- State R_OP of FSM
                when R_OP   => 
                    rf_wren <= '1';
                    sel_b <= '1';
                    sel_rC <= '1';
                    next_state <= FETCH2;
                
                -- State STORE of FSM
                when STORE  =>
                    write <= '1';
                    imm_signed <= '1';
                    sel_addr <= '1';
                    sel_b <= '0';
                    next_state <= FETCH1;
                
                -- State BREAK of FSM
                when BREAK  => NULL;
                
                -- State LOAD1 of FSM
                when LOAD1  =>
                    sel_addr <= '1';
                    read <= '1';
                    next_state <= LOAD2;
                
                -- State LOAD2 of FSM
                when LOAD2  =>
                    read <= '0';
                    imm_signed <= '0';
                    sel_addr <= '0';
                    rf_wren <= '1';
                    sel_mem <= '1';
                    next_state <= FETCH1;
                
                -- State I_OP of FSM
                when I_OP   => 
                    rf_wren <= '1';
                    imm_signed <= '1';
                    next_state <= FETCH1;

            end case;
            current_state <= next_state;
        end if;
    end process state_machine;

    alu_operation : process(op, opx)
    begin 
        case "00" & op is 
            when x"3A" =>
                case "00" & opx is
                    when x"0E" => op_alu <= "100001";
                    when x"1B" => op_alu <= "110011";
                    when others => NULL;
                end case;

            when others => op_alu <= "000000";
        end case;

    end process alu_operation;
    
    current_state <= FETCH1 when reset_n='1';
end synth;
