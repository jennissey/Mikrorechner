-- Registerbank.vhd
--
-- entity		RF	- Register File	
-- architecture		behave	- lesen und schreiben von Registern
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Work.CONSTANT_DEFINITIONS.all;

--Mäder sagt, hier nichts mehr ändern

-- Register File entity
entity RF is
port	( clk, nRes			: in 	std_logic;
	  R2, R3, R1			: in	unsigned(4 downto 0);
	  data, PCr			: in	signed(31 downto 0);
	  writeEnable			: in	std_logic;
	  R2Value, R3Value, PCValue	: out	signed(31 downto 0));
end entity RF;

-- Register File architecture
architecture behave of RF is

type Registers_t is array (31 downto 0) of signed(31 downto 0);
signal Registers : Registers_t;

begin
	write_P: process (clk, nRes) is
	begin
		if nRes = '0' then
			Registers(31) <= (others => '0');
		
		elsif rising_edge(clk)	then
			if writeEnable = '1' then 
				Registers(to_integer(R1)) <= data;
			end if;
			Registers(31) <= PCr;
		end if;
	end process write_P;

-- Register werden gelesen
R2Value <= Registers(to_integer(R2));
R3Value <= Registers(to_integer(R3));
PCValue <= Registers(31);

end architecture behave;
