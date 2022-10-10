library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic; -- Slave (component) Selector --
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
    -- 4KB of data => 1024 positions in the array each of 32-bits
    -- 4KB = 1024 * 4B => 1024 words * 32-bit per word 
    type ram_type is array(0 to 1023) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    signal rd_address : std_logic_vector(9 downto 0);
    signal saved_en : std_logic;
begin
    -- Synchronous WRITE process --
    write_process: process(clk)
    begin
        -- Data ready to be written on current clock cycle --
        if rising_edge(clk) then
            if write = '1' and cs = '1' then
                -- Go to address in array to write the data
                ram(to_integer(unsigned(address))) <= wrdata; 
            end if;
        end if;
    end process write_process;

    -- Synchronous READ outputter --
    read_process: process(saved_en, rd_address)
    begin
        -- Data ready to be read on current clock cycle -- 
        if saved_en = '1' then
            -- Tri-state Buffer (Enable=1) IN --> OUT
            -- rddata <= data;
            rddata <= ram(to_integer(unsigned(rd_address)));
        else 
            -- Tri-state Buffer (Enable=0) IN --> Z
            rddata <= (others => 'Z');
        end if;
    end process read_process;

    -- Synchronous READ selector
    select_process: process(clk)
    begin 
        if (rising_edge(clk)) then
            rd_address <= address;
            saved_en <= cs and read;
        end if;
    end process select_process;

end synth;
