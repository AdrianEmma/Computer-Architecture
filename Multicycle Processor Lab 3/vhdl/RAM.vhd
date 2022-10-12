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
    signal sv_address : std_logic_vector(9 downto 0);
    signal sv_csread : std_logic;
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

    -- Synchronous READ retriever (cycle #1 of READ) --
    read_process: process(sv_csread, sv_address)
    begin
        -- Data ready to be retrieved on current clock cycle -- 
        if sv_csread = '1' then
            -- Tri-state Buffer (Enable=1) IN --> OUT
            rddata <= ram(to_integer(unsigned(sv_address)));
        else 
            -- Tri-state Buffer (Enable=0) IN --> Z
            rddata <= (others => 'Z');
        end if;
    end process read_process;

    -- Synchronous READ selector (cycle #0 of READ) --
    select_process: process(clk)
    begin 
        -- Address and cs, read signals are ready to be saved
        if (rising_edge(clk)) then
            -- Save address and (cs and read) --
            sv_address <= address;
            sv_csread <= cs and read;
        end if;
    end process select_process;

end synth;
