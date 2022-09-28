library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
    signal sop : std_logic_vector(31 downto 0);
    signal cin : std_logic;
    signal inter : std_logic_vector(32 downto 0);
    signal tmp : std_logic_vector(31 downto 0);
begin
    process (a, b, sub_mode)
    begin
        sop <= b xor (31 downto 0 => sub_mode);
        cin <= sub_mode;
        tmp <= (31 downto 0 => '0');
        inter <= std_logic_vector(unsigned('0' & sop) + unsigned(tmp & cin) + unsigned('0' & a));
        if (inter(31 downto 0) = (31 downto 0 => '0')) then
            zero <= '1';
        else 
            zero <= '0';
        end if;
        carry <= inter(32);
        r <= inter(31 downto 0);
    end process;
end synth;
