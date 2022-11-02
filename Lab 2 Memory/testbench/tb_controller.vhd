library ieee;
use ieee.std_logic_1164.all;

entity tb_controller is
end;

architecture testbench of tb_controller is
    constant CLK_PERIOD : time := 40 ns;

    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '0';

begin
    memories_0 : ENTITY work.fpga4u_with_controller(bdf_type) port map(
            clk      => clk,
            reset_n  => reset_n,
            out_LEDs => open
        );

    process
    begin
        reset_n <= '0';
        wait for CLK_PERIOD * 3 / 2;
        reset_n <= '1';
        wait;
    end process;

    process
    begin
        clk <= not clk;
        wait for CLK_PERIOD / 2;
    end process;

end testbench;
