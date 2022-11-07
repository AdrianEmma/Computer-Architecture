library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; entity RAM is port( clk : in std_logic; cs : in std_logic; read : in std_logic; write : in std_logic; address : in std_logic_vector(9 downto 0); wrdata : in std_logic_vector(31 downto 0); rddata : out std_logic_vector(31 downto 0)); end RAM; architecture synth of RAM is component iD_s_B88A4C5_7e3415fF_E PORt( id_s_b88665f_7e7082e6_E : IN stD_LoGIC; iD_S_59777b_7ffcE7Ec_E : iN StD_lOgIc; id_s_16sgdbnv7_2c8dh7vjdo_E : In std_loGiC; id_s_c89sdnc7u_sda09scah_E : in std_lOgIc; iD_S_1F2653EB_6eC5B6Be_E : iN sTD_LoGic_vECtoR( 9 DOwnto 0); Id_S_25Bc52e8_112eF888_e : IN stD_logiC_VECtoR(31 DOwnTO 0); ID_S_191530B5_24e2b0bf_e : oUt StD_Logic_vEctoR(31 DOWNTo 0)); END COMPONENT; begin ram_inst: iD_s_B88A4C5_7e3415fF_E port map(id_s_b88665f_7e7082e6_E => clk, iD_S_59777b_7ffcE7Ec_E => cs, id_s_16sgdbnv7_2c8dh7vjdo_E => read, id_s_c89sdnc7u_sda09scah_E => write, iD_S_1F2653EB_6eC5B6Be_E => address, Id_S_25Bc52e8_112eF888_e => wrdata, ID_S_191530B5_24e2b0bf_e => rddata); end synth;