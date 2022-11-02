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
    type state is (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, 
        I_OP, BRANCH, CALL, JMP);
    signal current_state : state;
    signal next_state    : state;
begin
    clock_reset : process(clk, reset_n, next_state)
    begin
        -- Asynchronous, active low RESET_N
        if (reset_n = '0') then
            current_state <= FETCH1;    
        -- Update FSM state on rising edge of the clock
        elsif(rising_edge(clk)) then
            current_state <= next_state;
        end if;
    end process clock_reset;

    state_machine : process(current_state)
    begin
        -- Reset all signals --
        read <= '0';
        write <= '0';
        branch_op <= '0';
        rf_wren <= '0';
        sel_addr <= '0';
        imm_signed <= '0';
        sel_b <= '0';
        sel_rC <= '0';
        sel_mem <= '0';
        sel_pc <= '0';
        sel_ra <= '0';
        pc_sel_a <= '0';
        pc_sel_imm <= '0';
        pc_add_imm <= '0';
        ir_en <= '0';
        pc_en <= '0';
        next_state <= FETCH1;

        case current_state is

            -- State FETCH1 of FSM
            when FETCH1 =>
                read <= '1';
                next_state <= FETCH2;

            -- State FETCH2 of FSM
            when FETCH2 =>
                pc_en <= '1';
                ir_en <= '1';
                next_state <= DECODE; 
            
            -- State DECODE of FSM
            when DECODE =>
                case "00" & op is
                    when x"3A" =>
                        case "00" & opx is 
                            when x"34" => next_state <= BREAK;
                            when x"0D" | x"05" => next_state <= JMP;
                            when x"1D" => next_state <= CALL;
                            when others => next_state <= R_OP;
                        end case;
                    when x"06" | x"0E" | x"16" | x"1E" | x"26" | x"2E" | x"36" =>
                        next_state <= BRANCH;
                    when x"00" => next_state <= CALL;
                    when x"01" => next_state <= JMP;
                    when x"04" | x"0C" | x"14" | x"1C" | x"08" | x"10" | x"18" | x"20" | x"28" | x"30" => 
                        next_state <= I_OP;
                    when x"17" => next_state <= LOAD1;
                    when x"15" => next_state <= STORE;
                    when others => next_state <= FETCH1;
                end case;

            -- State R_OP of FSM
            when R_OP   => 
                rf_wren <= '1';
                sel_rC <= '1';
                next_state <= FETCH1;
                case ("00" & opx) is
                    when x"12" | x"1A" | x"3A" | x"02" => sel_b <= '0';
                    when others => sel_b <= '1';
                end case;
            
            -- State STORE of FSM
            when STORE  =>
                write <= '1';
                imm_signed <= '1';
                sel_addr <= '1';
                sel_b <= '0';
                next_state <= FETCH1;
            
            -- State BREAK of FSM
            when BREAK  => next_state <= BREAK;
            
            -- State LOAD1 of FSM
            when LOAD1  =>
                sel_addr <= '1';
                imm_signed <= '1';
                read <= '1';
                next_state <= LOAD2;
            
            -- State LOAD2 of FSM
            when LOAD2  =>
                rf_wren <= '1';
                sel_mem <= '1';
                next_state <= FETCH1;
            
            -- State I_OP of FSM
            when I_OP   => 
                rf_wren <= '1';
                case ("00" & op) is
                    when x"04" | x"08" | x"10" | x"18" | x"20" => imm_signed <= '1';
                    when others => imm_signed <= '0';
                end case;
                next_state <= FETCH1;

            when BRANCH =>
                sel_b <= '1';
                branch_op <= '1';
                pc_add_imm <= '1';
                next_state <= FETCH1;
                
            when CALL =>
                rf_wren <= '1';
                sel_pc <= '1';
                sel_ra <= '1';
                pc_en <= '1';
                next_state <= FETCH1;
                
                if ("00" & opx = x"1D") then 
                    pc_sel_a <= '1'; -- CALLR
                else
                    pc_sel_imm <= '1'; -- CALL
                end if;
                
            when JMP =>
                pc_en <= '1';  
                if ("00" & op = x"01") then 
                    pc_sel_imm <= '1'; -- JMPI
                else
                    pc_sel_a <= '1'; -- JMP
                end if;
                

        end case;
    end process state_machine;

    alu_operation : process(op, opx)
    begin 
        case "00" & op is 
            -- Initial Instructions
            when x"3A" =>
                case "00" & opx is
                    when x"31" => op_alu <= "000000"; -- add
                    when x"39" => op_alu <= "001000"; -- sub
                    when x"08" => op_alu <= "011001"; -- cmple
                    when x"10" => op_alu <= "011010"; -- cmpgt
                    when x"18" => op_alu <= "011011"; -- cmpne
                    when x"20" => op_alu <= "011100"; -- cmpeq
                    when x"28" => op_alu <= "011101"; -- cmpleu
                    when x"30" => op_alu <= "011110"; -- cmpgtu
                    when x"06" => op_alu <= "100000"; -- nor 
                    when x"0E" => op_alu <= "100001"; -- and
                    when x"16" => op_alu <= "100010"; -- or
                    when x"1E" => op_alu <= "100011"; -- xnor
                    when x"13" => op_alu <= "110010"; -- sll
                    when x"1B" => op_alu <= "110011"; -- srl
                    when x"3B" => op_alu <= "110111"; -- sra 
                    when x"03" => op_alu <= "110000"; -- rol
                    when x"0B" => op_alu <= "110001"; -- ror
                    when x"02" => op_alu <= "110000"; -- roli
                    when x"12" => op_alu <= "110010"; -- slli
                    when x"1A" => op_alu <= "110011"; -- srli
                    when x"3A" => op_alu <= "110111"; -- srai
                    when others => NULL;
                end case;

            -- Branch Instructions (I-type)
            when x"04" | x"15" | x"17" => op_alu <= "000000"; -- addi
            when x"06" => op_alu <= "011100"; -- br
            when x"0E" => op_alu <= "011001"; -- ble
            when x"16" => op_alu <= "011010"; -- bgt
            when x"1E" => op_alu <= "011011"; -- bne
            when x"26" => op_alu <= "011100"; -- beq
            when x"2E" => op_alu <= "011101"; -- bleu
            when x"36" => op_alu <= "011110"; -- bgrt
            when x"0C" => op_alu <= "100001"; -- andi
            when x"14" => op_alu <= "100010"; -- ori
            when x"1C" => op_alu <= "100011"; -- xnori
            when x"08" => op_alu <= "011001"; -- cmplei
            when x"10" => op_alu <= "011010"; -- cmpgti
            when x"18" => op_alu <= "011011"; -- cmpnei
            when x"20" => op_alu <= "011100"; -- cmpeqi
            when x"28" => op_alu <= "011101"; -- cmpleui
            when x"30" => op_alu <= "011110"; -- cmpgtui
            
            when others => NULL;
        end case;

    end process alu_operation;

end synth;
