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
    signal sh_left : std_logic_vector(31 downto 0);
    signal sh_right : std_logic_vector(31 downto 0);
    signal ash_right : std_logic_vector(31 downto 0);
    signal rot_left : std_logic_vector(31 downto 0);
    signal rot_right : std_logic_vector(31 downto 0);
begin
    -- Shift-Left Logical --
    process(a, b, op)
        variable v : std_logic_vector(31 downto 0);
    begin
        v := a; -- Intermediate value
        for i in 0 to 4 loop
            if (b(i) = '1') then
                v := v(31-(2**i) downto 0) & ((2**i)-1 downto 0 => '0');
            end if;
        end loop;
        sh_left <= v;
    end process;

    -- Shift-Right Logical --
    process(a, b, op)
        variable v : std_logic_vector(31 downto 0);
    begin
        v := a; -- Intermediate value
        for i in 0 to 4 loop
            if (b(i) = '1') then
                v := ((2**i)-1 downto 0 => '0') & v(31 downto (2**i));
            end if;
        end loop;
        sh_right <= v;
    end process;

    -- Shift-Right Arithmetic --
    process(a, b, op)
        variable v : std_logic_vector(31 downto 0);
    begin 
        v := a;
        for i in 0 to 4 loop
            if (b(i) = '1') then
                v := ((2**i)-1 downto 0 => a(31)) & v(31 downto (2**i));
            end if;
        end loop;
        ash_right <= v;
    end process;

    -- Rotate Left --
    process(a, b, op)
        variable v : std_logic_vector(31 downto 0);
    begin
        v := a; -- Intermediate value
        for i in 0 to 4 loop
            if (b(i) = '1') then
                v := v(31-(2**i) downto 0) & v(31 downto 31-(2**i)+1);
            end if;
        end loop;
        rot_left <= v;
    end process;

    -- Rotate Right --
    process(a, b, op)
        variable v : std_logic_vector(31 downto 0);
    begin
        v := a; -- Intermediate value
        for i in 0 to 4 loop
            if (b(i) = '1') then
                v := v((2**i)-1 downto 0) & v(31 downto (2**i));
            end if;
        end loop;
        rot_right <= v;
    end process;

    comp : process(sh_left, sh_right, ash_right, rot_left, rot_right) 
    begin 
        case op is 
            when "010" => r <= sh_left;
            when "011" => r <= sh_right;
            when "111" => r <= ash_right;
            when "000" => r <= rot_left;
            when "001" => r <= rot_right;
            when others => NULL;
        end case;
    end process;

end synth;
