-- EX.vhd
--
-- entity	ALU		- ALU
-- architecture	behave		- ALU Operationen durchführen
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all
use Work.constantDefinitions.all

-- ALU entity
entity ALU is
port    (	opA, opB	: in	std_logic_vector(31 downto 0);
		opCode		: in	signed(5 downto 0);
		aluOut		: out	signed(31 downto 0));
		AluFlagOut	: out	std_logic;
		AluFlagIn	: in	std_logic;			
end entity ALU;

-- ALU architecture
architecture behave of ALU is

function myshiftLeftL(signal opA, opB : signed(31 downto 0)) return signed is
begin
	if opB = 0 then return opA(30 downto 0) & '0';
	else return opA(23 downto 0) & "00000000";
end function myshiftLeftL;

function myshiftRightL(signal opA, opB : signed(31 downto 0)) return signed is
begin
	if opB = 0 then return '0' & opA(31 downto 1);
	else return "00000000" & opA(31 downto 8);
end function myshiftRightL;

function myshiftRightA(signal opA, opB : signed(31 downto 0)) return signed is
begin
	if opB = 0 then return opA(31) & opA(31 downto 1);
	else return opA(31) & opA(31) & opA(31) & opA(31) & opA(31) & opA(31) & opA(31) & opA(31) & opA(31 downto 8);
end function myshiftRightA;

Signal opAsigned, opBsigned : signed(31 downto 0);
Signal opAunsigned, opBunsigned : unsigned(31 downto 0);

opAsigned <= to_signed(opA);
opBsigned <= to_signed(opB);
opAunsigned <= to_unsigned(opA);
opBunsigned <= to_unsigned(opB);

begin
	with opCode select
	aluOut <=	opAsigned + opBsigned when opcADD | opcADDI | opcJMPR | opcBRR;
			opAsigned - opBsigned when opcSUB | opcSUBI;
			opA and opB when opcAND | opcANDI;
			opA or opB when opcOR | opcORI;
			opA not opB when opcNOT;
			-- myShift mit Register, wenn 0 im Register Shift um 1, wenn anderer Wert als 0 Shift um 8
			myshiftLeftL(opA, opB) when opcSHL or opcSHLI;
			myshiftRightL(opA, opB) when opcSHRL or opcSHRLI;
			myshiftRightA(opA, opB) when opcSHRA or opcSHRAI;

	AluFlagOut <= 	opA == opB when opcCEQ | opcCEQI;
		   	opAsigned < opBsigned when opcCLTS | CLTSI;
			opAsigned > opBsigned when opcCGTS | opcCGTSI;
			opAunsigned < opBunsigned when opcCLTU | opcCLTUI;
			opAunsigned > opBunsigned when opcCGTU | opcCGTU;

-- Zweiten Ausgang setzen, falls nicht vorher geschehen.
if opCode != opcCEQ | opcCEQI | opcCLTS | CLTSI | opcCGTS | opcCGTSI | opcCLTU | opcCLTUI | opcCGTU | opcCGTU then 
AluFlagOut <= AluFlagIn;
else
aluOut <= opA;		
		   
end architecture behave;


