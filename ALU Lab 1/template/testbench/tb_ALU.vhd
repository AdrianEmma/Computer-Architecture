library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ALU is
end;

architecture bench of tb_ALU is
    signal a, b, s : std_logic_vector(31 downto 0);
    signal op      : std_logic_vector(5 downto 0);

begin
    alu_0 : ENTITY work.alu(bdf_type) PORT MAP(
            a  => a,
            b  => b,
            op => op,
            s  => s
        );

    -- TestBench covering most of the ALU fonctionality. It will only display the first error.
    -- At the end of the test it will say whether the test succeded or not.
    -- Start the simulation in ModelSim and type run -all
    process
        variable expected : std_logic_vector(31 downto 0);
        variable test     : boolean;
        variable success  : boolean;
        variable n_shift  : natural;
    begin
        -- It will say wheter the test is a success
        success := TRUE;
        a       <= X"05555AAF";
        b       <= X"0AAAAC00";
        op      <= (others => '0');

        wait for 40 ns;

        for opcode in 0 to 63 loop
            op <= std_logic_vector(to_unsigned(opcode, 6));

            -- Text to say wich unit is tested
            case opcode is
                when 0 => ASSERT FALSE
                        REPORT "= Add/Sub test ==============================================================="
                        SEVERITY NOTE;
                when 16 => ASSERT FALSE
                        REPORT "= Comparator test ============================================================"
                        SEVERITY NOTE;
                when 32 => ASSERT FALSE
                        REPORT "= Logical unit test =========================================================="
                        SEVERITY NOTE;
                when 48 => ASSERT FALSE
                        REPORT "= Shift unit test ============================================================"
                        SEVERITY NOTE;
                when others =>
            end case;

            -- only modify the 2 more significant bits
            for op_a in 0 to 3 loop
                a(31 downto 30) <= std_logic_vector(to_unsigned(op_a, 2));

                -- only modify the 2 more significant bits
                for op_b in 0 to 3 loop
                    b(31 downto 30) <= std_logic_vector(to_unsigned(op_b, 2));

                    -- modify the 5 least significant bits of b (for shifts)
                    for op_low_b in 0 to 31 loop
                        b(4 downto 0) <= std_logic_vector(to_unsigned(op_low_b, 5));

                        wait for 40 ns;

                        case op(5 downto 3) is
                            -- add
                            when "000" => expected := std_logic_vector(signed(a) + signed(b));
                            -- sub
                            when "001" => expected := std_logic_vector(signed(a) - signed(b));
                            -- comparator
                            when "011" =>
---------------------------------------MODIFY HERE-------------------------------------------------------------
				ASSERT FALSE
					REPORT "Replace this ASSERT with the code to test the comparator"
                			SEVERITY ERROR;
---------------------------------------END MODIFY--------------------------------------------------------------
                            -- "010" is not valid -> ignore
                            -- logical unit
                            when "100" | "101" =>
                                case op(1 downto 0) is
                                    when "00"   => expected := a nor b;
                                    when "01"   => expected := a and b;
                                    when "10"   => expected := a or b;
                                    when "11"   => expected := a xnor b;
                                    -- we don't care for the others => ignore
                                    when others => expected := s;
                                end case;
                            --  shift unit
                            when "110" | "111" =>
                                n_shift := to_integer(unsigned(b(4 downto 0)));
                                case op(2 downto 0) is
                                    -- rol
                                    when "000"  => expected := a(31 - n_shift downto 0) & a(31 downto 32 - n_shift);
                                    -- ror
                                    when "001"  => expected := a(n_shift - 1 downto 0) & a(31 downto n_shift);
                                    -- sll
                                    when "010"  => expected := a(31 - n_shift downto 0) & (n_shift - 1 downto 0 => '0');
                                    -- srl
                                    when "011"  => expected := (n_shift - 1 downto 0 => '0') & a(31 downto n_shift);
                                    -- sra
                                    when "111"  => expected := (n_shift - 1 downto 0 => a(31)) & a(31 downto n_shift);
                                    -- we don't care for the others => ignore
                                    when others => expected := s;
                                end case;
                            -- other cases are ignored
                            when others => expected := s;
                        end case;

                        -- now we verify that s = expected
                        -- display only 1 error.
                        if ((s /= expected) and success) then
                            ASSERT FALSE
                                REPORT "Incorrect Behavior"
                                SEVERITY ERROR;
                            success := FALSE;
                            wait;       -- to stop after the first error.
                        end if;
                    end loop;           -- op_low_b
                end loop;               -- op_b
            end loop;                   -- op_a
        end loop;                       -- opcode

        if (success) then
            ASSERT FALSE
                REPORT "= Test is Successful!!! ======================================================"
                SEVERITY NOTE;
        else
            ASSERT FALSE
                REPORT "= Test detected some Errors. ================================================="
                SEVERITY ERROR;
        end if;
        wait;
    end process;

end bench;
