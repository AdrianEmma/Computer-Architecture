library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buttons is
    port(
        -- bus interface
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic;
        wrdata  : in  std_logic_vector(31 downto 0);
        buttons : in  std_logic_vector(3 downto 0);

        -- irq     : out std_logic;
        rddata  : out std_logic_vector(31 downto 0)
    );
end buttons;

architecture synth of buttons is
    constant REG_DATA : std_logic := '0';
    constant REG_EDGE : std_logic := '1';

    signal address_reg : std_logic;
    signal read_reg    : std_logic;
    signal buttons_reg : std_logic_vector(3 downto 0);
    signal edges       : std_logic_vector(3 downto 0);

begin
    --irq <= '0' when unsigned(edges) = 0 else '1';

    -- address_reg & button_reg
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            address_reg <= '0';
            read_reg    <= '0';
            buttons_reg <= (others => '1');
        elsif (rising_edge(clk)) then
            address_reg <= address;
            read_reg    <= read and cs;
            buttons_reg <= buttons;
        end if;
    end process;

    -- read
    process(read_reg, address_reg, edges, buttons)
    begin
        rddata <= (others => 'Z');
        if (read_reg = '1') then
            rddata <= (others => '0');
            case address_reg is
                when REG_DATA =>
                    rddata(3 downto 0) <= buttons;
                when REG_EDGE =>
                    rddata(3 downto 0) <= edges;
                when others =>
            end case;
        end if;
    end process;

    -- edges
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            edges <= (others => '0');
        elsif (rising_edge(clk)) then
            -- edge detection
            edges <= edges or (not buttons and buttons_reg);
            -- clear edges
            if (cs = '1' and write = '1') then
                if (address = REG_EDGE) then
                    edges <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end synth;
