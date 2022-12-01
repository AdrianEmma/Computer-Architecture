library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_adder_sequential is
end tb_adder_sequential;

architecture test of tb_adder_sequential is 
    --- generics --- 
    constant CLK_PERIOD : time := 100 ns;
    constant RST_TIME : time := 100 ns;

    --- interrupt signal ---
    signal sim_finished : boolean := false;

    constant N_BITS : positive := 4;
    signal CLK : std_logic;
    signal RST : std_logic;
    signal START: std_logic;
    signal OP1 : std_logic_vector(N_BITS - 1 downto 0);
    signal OP2 : std_logic_vector(N_BITS - 1 downto 0);
    signal SUM : std_logic_vector(N_BITS downto 0);
    signal DONE : std_logic;

begin 
    --- Instantiate DUT ---
    dut : entity work.adder_sequential
    generic map(N_BITS => N_BITS)
    port map(CLK => CLK, 
        RST => RST,
        START => START,
        OP1 => OP1,
        OP2 => OP2,
        SUM => SUM,
        DONE => DONE);

    clk_generation : process
    begin 
        if not sim_finished then
            CLK <= '1';
            wait for CLK_PERIOD / 2;
            CLK <= '0';
            wait for CLK_PERIOD / 2;
        else
            wait;
        end if;
    end process clk_generation;
    
    --- TEST ---
    simulation : process
        procedure async_reset is
        begin 
            RST <= '1';
            wait for RST_TIME;
            RST <= '0';
        end procedure async_reset;

        procedure check_add(constant in1 : in natural; 
                            constant in2 : in natural;
                            constant expct : in natural) is
            variable res : natural;
        begin
        wait until rising_edge(CLK);
        OP1 <= std_logic_vector(to_unsigned(in1, OP1'length));
        OP2 <= std_logic_vector(to_unsigned(in2, OP2'length));
        START <= '1';

        wait until rising_edge(CLK);        
        OP1 <= (others => '0');
        OP2 <= (others => '0');
        START <= '0';

        wait until DONE = '1';

        res := to_integer(unsigned(SUM));
        assert res = expct
        report "Unexpected result: " &
                "OP1 = " & integer'image(in1) & "; " &
                "OP2 = " & integer'image(in2) & "; " &
                "SUM = " & integer'image(res) & "; " &
                "SUM_expected = " & integer'image(expct)
        severity error;

        wait until DONE = '0';
    end procedure check_add; 

    begin 
        --- Default ---
        OP1 <= (others => '0');
        OP2 <= (others => '0');
        RST <= '0';
        START <= '0';
        wait for CLK_PERIOD;

        --- Reset the circuit ---
        async_reset;

        -- Check test --
        check_add(12,8,20);
        check_add(12,3,15);
        sim_finished <= true;
        wait;
    end process simulation;

end architecture test;