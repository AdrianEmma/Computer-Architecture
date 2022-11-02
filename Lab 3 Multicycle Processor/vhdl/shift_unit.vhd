library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(4 downto 0);
        op : in  std_logic_vector(2 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end shift_unit;

architecture synth of shift_unit is
    signal rotate, shift_left, shift_right : std_logic_vector(31 downto 0);

begin

    -- selection between the operations
    sel : process(op, rotate, shift_left, shift_right)
    begin
        case op(1 downto 0) is
            when "00" | "01" => r <= rotate;
            when "10"        => r <= shift_left;
            when "11"        => r <= shift_right;
            when others      =>
        end case;
    end process;

    -- rotate left or right
    ror_rol : process(a, b, op)
        variable b_s      : std_logic_vector(4 downto 0);
        variable v        : std_logic_vector(31 downto 0);
        variable op_0_vec : std_logic_vector(4 downto 0);
    begin
        -- we invert b if we want to rotate to the right:
        -- (a rol b <=> a ror (-b))
        -- When we rotate to the right op(0) = '1'
        op_0_vec := (4 downto 1 => '0') & op(0);
        b_s      := std_logic_vector(unsigned(b xor (4 downto 0 => op(0))) + unsigned(op_0_vec));
        v        := a;
        for i in 0 to 4 loop
            if (b_s(i) = '1') then
                v := v(31 - (2 ** i) downto 0) & v(31 downto 32 - (2 ** i));
            end if;
        end loop;
        rotate <= v;
    end process;

    -- shift_right
    srl_sra : process(a, b, op)
        variable sign : std_logic;
        variable v    : std_logic_vector(31 downto 0);
    begin
        -- if op(2)='1' we have to replicate the sign of the operand a.
        sign := op(2) and a(31);
        v    := a;
        for i in 0 to 4 loop
            if (b(i) = '1') then
                v := ((2 ** i) - 1 downto 0 => sign) & v(31 downto 2 ** i);
            end if;
        end loop;
        shift_right <= v;
    end process;

    -- shift_left
    sh_left : process(a, b)
        variable v : std_logic_vector(31 downto 0);
    begin
        v := a;
        for i in 0 to 4 loop
            if (b(i) = '1') then
                v := v(31 - (2 ** i) downto 0) & ((2 ** i) - 1 downto 0 => '0');
            end if;
        end loop;
        shift_left <= v;
    end process;

end synth;
