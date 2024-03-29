library ieee;
use ieee.std_logic_1164.all;

entity tb_add_sub is
end tb_add_sub;

architecture testbench of tb_add_sub is
    signal a, b, r : std_logic_vector(31 downto 0);
    signal sub_mode, carry, zero : std_logic;

    -- declaration of the add_sub interface
    component add_sub is
        port(
            a        : in  std_logic_vector(31 downto 0);
            b        : in  std_logic_vector(31 downto 0);
            sub_mode : in  std_logic;
            carry    : out std_logic;
            zero     : out std_logic;
            r        : out std_logic_vector(31 downto 0);
        );
    end component;

begin

    -- logic unit instance
    add_sub_0 : add_sub port map(
            a  => a,
            b  => b,
            sub_mode => sub_mode,
            carry => carry,
            zero => zero,
            r  => r
        );

    -- process for verification of the logic unit
    check : process
    begin
        -- This is the 4 possible 2 bits combinaisons between A and B
        a <= (31 downto 4 => '0') & "1100";
        b <= (31 downto 4 => '0') & "1010";
        sub_mode <= '0';

        wait for 20 ns;                 -- wait for circuit to settle
        -- insert an ASSERT statement here
        
        -- report integer'image(unsigned(std_logic_vector)) to print values
        
        assert r(4 downto 0) = "10110"
            report "Incorrect RESULT"
            severity warning;

        assert carry = '1'
            report "Incorrect CARRY"
            severity warning;

        assert zero = '0'
            report "Incorrect ZERO"
            severity warning;

        wait;                           -- wait forever
    end process;

end testbench;
