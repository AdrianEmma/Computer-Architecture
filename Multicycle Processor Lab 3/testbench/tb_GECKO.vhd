library ieee;
use ieee.std_logic_1164.all;

entity tb_GECKO is
end;

architecture testbench of tb_GECKO is
    constant CLK_PERIOD : time := 40 ns;

    signal clk        : std_logic := '0';
    signal reset_n    : std_logic := '0';
    signal in_buttons : std_logic_vector(3 downto 0);

begin
    gecko_0 : ENTITY work.gecko(bdf_type) port map(
            clk        => clk,
            reset_n    => reset_n,
            row1	   => open,
			row2	   => open,
			row3	   => open,
			row4	   => open,
			row5	   => open,
			row6	   => open,
			row7	   => open,
			row8	   => open,
            in_buttons => in_buttons
        );

    in_buttons <= (others => '0');

    process
    begin
        clk <= not clk;
        wait for CLK_PERIOD / 2;
    end process;

    process
    begin
        reset_n <= '0';
        wait for CLK_PERIOD / 2;
        reset_n <= '1';
        wait;
    end process;

end testbench;
