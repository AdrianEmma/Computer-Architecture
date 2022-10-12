library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
        cs_BUTT : out std_logic
    );
end decoder;

architecture synth of decoder is
begin
    decode : process(address)
    begin 
        if address >= x"0000" and address <= x"0FFC" then
            cs_ROM <= '1';
            cs_LEDS <= '0';
            cs_RAM <= '0';
            cs_BUTT <= '0';
        else 
            if address >= x"1000" and address <= x"1FFF" then
                cs_RAM <= '1';
                cs_LEDS <= '0';
                cs_ROM <= '0';
                cs_BUTT <= '0';
            else 
                if address >= x"2000" and address <= x"200C" then
                    cs_LEDS <= '1';
                    cs_RAM <= '0';
                    cs_ROM <= '0';
                    cs_BUTT <= '0';
                else 
                    if address >= x"2030" and address <= x"2034" then
                        cs_LEDS <= '0';
                        cs_RAM <= '0';
                        cs_ROM <= '0';
                        cs_BUTT <= '1';
                    else
                        cs_LEDS <= '0';
                        cs_RAM <= '0';
                        cs_ROM <= '0';
                        cs_BUTT <= '0';   
                    end if;
                end if;
            end if;
        end if;
    end process decode;
end synth;
