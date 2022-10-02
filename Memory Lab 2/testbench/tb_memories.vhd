library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memories is
end;

architecture testbench of tb_memories is
    constant CLK_PERIOD : time := 40 ns;

    signal clk            : std_logic := '0';
    signal reset_n        : std_logic := '0';
    signal write, read    : std_logic := '0';
    signal address        : std_logic_vector(15 downto 0);
    signal wrdata, rddata : std_logic_vector(31 downto 0);

    signal finished : std_logic := '0';

begin
    memories_0 : ENTITY work.fpga4u_without_controller(bdf_type) port map(
            clk      => clk,
            reset_n  => reset_n,
            write    => write,
            read     => read,
            address  => address,
            wrdata   => wrdata,
            rddata   => rddata,
            out_LEDs => open
        );

    process
    begin
        clk <= not clk;
        wait for CLK_PERIOD / 2;
        if (finished = '1') then
            wait;
        end if;
    end process;

    process
    begin
        --init
        write   <= '0';
        address <= (others => '0');
        wrdata  <= (others => '0');
        reset_n <= '0';
        wait for CLK_PERIOD * 3 / 2;
        reset_n <= '1';

        -- read some values in the ROM
        -- verify that it corresponds to the data that is in your .hex file.
        read <= '1';
        for i in 0 to 31 loop
            address <= std_logic_vector(to_unsigned(i * 4, 16));
            wait for CLK_PERIOD;
        end loop;
        read <= '0';

        -- write on the LEDs
        write <= '1';
        for i in 0 to 2 loop
            address <= std_logic_vector(to_unsigned(i * 4, 16) + X"2000");
            wrdata  <= std_logic_vector(to_unsigned(i, 32) + X"AA55AA54");
            wait for CLK_PERIOD;
        end loop;
        write <= '0';

        -- read back in the LEDs
        read <= '1';
        for i in 0 to 2 loop
            address <= std_logic_vector(to_unsigned(i * 4, 16) + X"2000");
            wait for CLK_PERIOD;
            ASSERT rddata = (std_logic_vector(to_unsigned(i, 32) + X"AA55AA54"))
                REPORT "Did not read or write correctly in LEDs"
                SEVERITY ERROR;
        end loop;
        read <= '0';

        -- write some values in the RAM
        write <= '1';
        for i in 0 to 31 loop
            address <= std_logic_vector(to_unsigned(i * 4, 16) + X"1000");
            wrdata  <= std_logic_vector(to_unsigned(i, 32) + X"AAAA0000");
            wait for CLK_PERIOD;
        end loop;
        write <= '0';

        -- read back in the RAM
        read <= '1';
        for i in 0 to 31 loop
            address <= std_logic_vector(to_unsigned(i * 4, 16) + X"1000");
            wait for CLK_PERIOD;
            ASSERT rddata = (std_logic_vector(to_unsigned(i, 32) + X"AAAA0000"))
                REPORT "Did not read or write correctly in RAM"
                SEVERITY ERROR;
        end loop;

        -- going from the ROM to the RAM address space
        for i in 0 to 31 loop
            address <= std_logic_vector(to_unsigned(i * 4, 16) + X"0960");
            wait for CLK_PERIOD;
        end loop;

        finished <= '1';
        wait;
    end process;

end testbench;
