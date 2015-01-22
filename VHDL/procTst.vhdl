-- procTst.vhd
--
-- entity	procTst			-testbench for pipeline processor
-- architecture	testbench		-
------------------------------------------------------------------------------
library ieee;						-- packages:
use ieee.std_logic_1164.all;				--   std_logic
use ieee.numeric_std.all;				--   (un)signed
use work.sramPkg.all;					--   sram

-- entity	--------------------------------------------------------------
------------------------------------------------------------------------------
entity procTst is
generic(clkPeriod	: time		:= 20 ns;	-- clock period
	clkCycles	: positive	:= 3000);	-- clock cycles
end entity procTst;


-- architecture	--------------------------------------------------------------
------------------------------------------------------------------------------
architecture tb of procTst is
  signal clk, nRst					: std_logic;
  signal const0, const1					: std_logic;
  signal dnWE, dnOE					: std_logic;
  signal iAddr, dAddr					: signed( 31 downto 0);
  signal iData, dData					: std_logic_vector(31 downto 0);
  signal iCtrl, dCtrl					: fileIOty;
  signal Data, memData, memAdress, PCout 		: signed(31 downto 0);
  signal dBus 						: std_logic_vector (31 downto 0);
  signal iAddr2, dAddr2					: std_logic_vector(7 downto 0);

component Pipeline is
port	( clk, nRes				: in	std_logic;
	  IR, DATA				: in	signed(31 downto 0);
	  memAddress, memData, PCout	: out	signed(31 downto 0);
	  dnWE, dnOE				: out	std_logic);
end component Pipeline;

begin
  const0 <= '0';
  const1 <= '1';

iAddr2 <= std_logic_vector(iAddr(7 downto 0));
dAddr2 <= std_logic_vector(dAddr(7 downto 0));
  -- memories		------------------------------------------------------
  instMemI: sram	generic map (	addrWd=> 8,
					dataWd=> 32,
					fileID	=> "fib.program")
			port map    (	nCS	=> const0,
					nWE	=> const1,
					nOE	=> const0,
					addr	=> iAddr2,
					data	=> iData,
					fileIO	=> iCtrl);
  dataMemI: sram	generic map (	addrWd=> 8,
					dataWd=> 32,
					fileID	=> "dataMem.dat")
			port map    (	nCS	=> const0,
					nWE	=> dnWE,
					nOE	=> dnOE,
					addr	=> dAddr2,
					data	=> dBus,
					fileIO	=> dCtrl);

dBus <= std_logic_vector(dData) when dnWE = '0' else (others => 'Z');

  -- pipe processor	------------------------------------------------------
  pipeProcI: Pipeline	port map    (	clk				=> clk,
					nRes				=> nRst,
					PCout				=> iAddr,
					IR				=> signed(iData),
					Data 				=> signed(dBus),
					dnWE				=> dnWE,
					dnOE				=> dnOE,
					memAddress			=> dAddr,
					std_logic_vector(memData)	=> dData);


  -- stimuli		------------------------------------------------------
  stiP: process is
  begin
    clk	<= '0';
    nRst	<= '0',   '1'  after 5 ns;
    iCtrl	<= load,  none after 5 ns;
    dCtrl	<= none;
    wait for clkPeriod/2;
    for n in 1 to clkCycles loop
	clk <= '0', '1' after clkPeriod/2;
	wait for clkPeriod;
    end loop;
    wait for 5*clkPeriod;
    dCtrl <= dump;
    wait;
  end process stiP;

end architecture tb;
------------------------------------------------------------------------------
-- procTst.vhd	- end
