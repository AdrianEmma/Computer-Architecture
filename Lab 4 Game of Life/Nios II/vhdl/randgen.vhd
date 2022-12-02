library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity randgen is
port(address   : in  std_logic_vector(15 downto 0);
     read      : in  std_logic;
     rddata    : out std_logic_vector(31 downto 0);
     clk       : in  std_logic;
     reset_n   : in std_logic);
end entity randgen;

architecture rtl of randgen is
constant addr_map : std_logic_vector(15 downto 0) := x"2010";
signal rand_q     : std_logic_vector(31 downto 0);
signal rand_next  : std_logic_vector(31 downto 0);
signal cs         : std_logic;
begin
   reg:process(clk, reset_n) is
   begin
      if(reset_n = '0') then
         rand_q <= (others => '0');
      elsif(rising_edge(clk)) then
         rand_q <= rand_next;
      end if;
   end process reg;

   lfsr:process(rand_q) is
   begin
      if rand_q = x"00000000" then
         rand_next <= x"55555555";
      else
         rand_next <= rand_q(30 downto 0) & rand_q(31);
         rand_next(2)  <= rand_q(1) xor rand_q(31);
         rand_next(6)  <= rand_q(5) xor rand_q(31);
         rand_next(7)  <= rand_q(6) xor rand_q(31);
      end if;
   end process lfsr;

   chipsel:process(clk, reset_n) is
   --One cycle latency.
   begin
      if(reset_n = '0') then
         cs <= '0';
      elsif(rising_edge(clk)) then
         if(address = addr_map and read = '1') then
            cs <= '1';
         else
            cs <= '0';
         end if;
      end if;
   end process chipsel;

   rddata <= rand_q when cs = '1' else (others => 'Z'); 
end architecture rtl;
