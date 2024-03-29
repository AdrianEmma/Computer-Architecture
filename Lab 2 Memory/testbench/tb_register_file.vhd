library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_register_file is
end;

architecture bench of tb_register_file is
    signal aa, ab, aw   : std_logic_vector(4 downto 0);
    signal a, b, wrdata : std_logic_vector(31 downto 0);
    signal wren         : std_logic := '0';
    -- clk initialization
    signal clk, stop    : std_logic := '0';
    -- clk period definition
    constant CLK_PERIOD : time      := 40 ns;

    -- declaration of register_file interface
    -- INSERT COMPONENT DECLARATION HERE
    component register_file is 
        port(
            clk    : in  std_logic;
            aa     : in  std_logic_vector(4 downto 0);
            ab     : in  std_logic_vector(4 downto 0);
            aw     : in  std_logic_vector(4 downto 0);
            wren   : in  std_logic;
            wrdata : in  std_logic_vector(31 downto 0);
            a      : out std_logic_vector(31 downto 0);
            b      : out std_logic_vector(31 downto 0)
        );
    end component;
begin

    -- register_file instance
    -- INSERT REGISTER FILE INSTANCE HERE
    register_file0 : register_file port map(
        a => a,
        b => b,
        clk => clk,
        aa => aa,
        ab => ab,
        aw => aw,
        wren => wren,
        wrdata => wrdata
    );

    clock_gen : process
    begin
        -- it only works if clk has been initialized
        if stop = '0' then
            clk <= not clk;
            wait for (CLK_PERIOD / 2);
        else
            wait;
        end if;
    end process;

    process
    begin
        -- init
        wren   <= '0';
        aa     <= "00000";
        ab     <= "00111";
        aw     <= "00000";
        wrdata <= (others => '0');
        wait for 5 ns;

        -- write in the register file
        wren <= '1';
        for i in 0 to 31 loop
            -- std_logic_vector(to_unsigned(number, bitwidth))
            -- Update ports to be loaded on current clock cycle
            aw     <= std_logic_vector(to_unsigned(i, 5)); 
            wrdata <= std_logic_vector(to_unsigned(i + 1, 32));
            wait for CLK_PERIOD; -- Wait for next clock cycle
        end loop;

        -- read in the register file
        -- INSERT CODE THAT READS THE REGISTER FILE HERE
        -- Value in register 0 should be 0
        assert to_integer(unsigned(a)) = 0
            report "Unexpected value in register AA"
            severity ERROR;
        
        -- Value in register i should be i+1
        for i in 1 to 31 loop
            ab <= std_logic_vector(to_unsigned(i, 5));
            -- Wait for address values to propagate
            wait for CLK_PERIOD;

            -- Check the value inside the register
            assert(to_integer(unsigned(b))) = i+1
                report "Unexpected value in register AB"
                severity ERROR;
        end loop;

        stop <= '1';
        wait;
    end process;
end bench;
