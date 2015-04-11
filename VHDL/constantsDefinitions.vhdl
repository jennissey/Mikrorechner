-- constantsDefinitions.vhdl
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package CONSTANT_DEFINITIONS is
	-- OpCodes definition
	constant opcADD	: signed(5 downto 0) := "100000";
	constant opcADDI	: signed(5 downto 0) := "100001";
	constant opcSUB	: signed(5 downto 0) := "100010";
	constant opcSUBI	: signed(5 downto 0) := "100011";
	constant opcAND	: signed(5 downto 0) := "100100";
	constant opcANDI	: signed(5 downto 0) := "100101";
	constant opcOR	: signed(5 downto 0) := "100110";
	constant opcORI	: signed(5 downto 0) := "100111";
	constant opcNOT	: signed(5 downto 0) := "101000";
	constant opcSHL	: signed(5 downto 0) := "101010";
	constant opcSHLI	: signed(5 downto 0) := "101011";
	constant opcSHRA	: signed(5 downto 0) := "101100";
	constant opcSHRL	: signed(5 downto 0) := "101110";
	constant opcSHRAI	: signed(5 downto 0) := "101101";
	constant opcSHRLI	: signed(5 downto 0) := "101111";
	constant opcJMPA	: signed(5 downto 0) := "000000";
	constant opcJMPR	: signed(5 downto 0) := "000001";
	constant opcBRA	: signed(5 downto 0) := "000010";
	constant opcBRR	: signed(5 downto 0) := "000011";
	constant opcCEQ 	: signed(5 downto 0) := "000100";
	constant opcCEQI	: signed(5 downto 0) := "000101";
	constant opcCLTU	: signed(5 downto 0) := "000110";
	constant opcCLTS	: signed(5 downto 0) := "001000";
	constant opcCLTUI	: signed(5 downto 0) := "000111";
	constant opcCLTSI	: signed(5 downto 0) := "001001";
	constant opcCGTU	: signed(5 downto 0) := "001010";
	constant opcCGTS	: signed(5 downto 0) := "001100";
	constant opcCGTUI	: signed(5 downto 0) := "001011";
	constant opcCGTSI	: signed(5 downto 0) := "001101";
	constant opcMOVE	: signed(5 downto 0) := "001110";
	constant opcMOVI	: signed(5 downto 0) := "001111";
	constant opcLOAD	: signed(5 downto 0) := "010000";
	constant opcSTORE	: signed(5 downto 0) := "010001";
	constant opcNOP	: signed(5 downto 0) := "010010";
	constant opcHALT	: signed(5 downto 0) := "010011";

-- ALU Component
component ALU is
port    (	opA, opB	: in	signed(31 downto 0);
	opCode	: in	signed(5 downto 0);
	aluOut		: out	signed(31 downto 0);
	AluFlagOut	: out	std_logic);		
end component ALU;

-- Register File component
component RF is
port	( clk, nRes			: in 	std_logic;
	  R2, R3, R1			: in	unsigned(4 downto 0);
	  data, PCr			: in	signed(31 downto 0);
	  writeEnable			: in	std_logic;
	  R2Value, R3Value, PCValue	: out	signed(31 downto 0));
end component RF;

end package CONSTANT_DEFINITIONS;
