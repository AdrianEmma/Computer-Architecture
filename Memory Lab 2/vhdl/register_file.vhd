library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
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
end register_file;

architecture synth of register_file is
    ---------------------INITIALIZE ALL 0----------------------------
    type reg_type is array(0 to 31) of std_logic_vector(31 downto 0); 
    -----------------------------------------------------------------
    signal reg : reg_type := (others => (others => '0'));
begin
    -- Synchronous write process
    write : process(clk)
        variable regno : natural; -- Write Register Number 
    begin 
        if rising_edge(clk) then -- Data ready to be saved
            if wren = '1' then -- Write control signal
                regno := to_integer(unsigned(aw));
                if regno /= 0 then -- Can save data on all registers except 0
                    reg(regno) <= wrdata; -- Write data
                end if;
            end if;
        end if;
    end process write;
    
    -- Asynchronous read operations
    a <= reg(to_integer(unsigned(aa)));
    b <= reg(to_integer(unsigned(ab)));
     
end synth;
