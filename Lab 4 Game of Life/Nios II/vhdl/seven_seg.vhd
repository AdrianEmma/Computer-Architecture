library ieee;
use ieee.std_logic_1164.all;

entity seven_seg is
port(address : in std_logic_vector(15 downto 0);
     wrdata  : in std_logic_vector(7 downto 0);
     clk     : in std_logic;
     reset_n : in std_logic;
     seg_out : out std_logic_vector(31 downto 0));
end entity seven_seg;

architecture rtl of seven_seg is
type addr_t is array(3 downto 0) of std_logic_vector(15 downto 0);
type reg_t is array(3 downto 0) of std_logic_vector(7 downto 0);
constant addr_map : addr_t := (x"1198", x"119C", x"11A0", x"11A4");
signal reg : reg_t;
begin
   digits:for i in 3 downto 0 generate
      beh:process(clk, reset_n) is
      begin
         if(reset_n = '0') then
            reg(i) <= (others => '0');
         elsif(rising_edge(clk)) then
            if(address = addr_map(i)) then
               reg(i) <= wrdata;
	         end if;
	      end if;
      end process beh;
      seg_out(8 * (i + 1) - 1 downto 8 * i) <= reg(i);
   end generate;
end architecture rtl;
   
