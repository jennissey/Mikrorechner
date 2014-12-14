-- EX.vhd
--
-- entity	ALU		- ALU
-- architecture	behave		- ALU Operationen durchführen
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Work.CONSTANT_DEFINITIONS.all;

-- ALU entity
entity ALU is
port    (	opA, opB	: in	signed(31 downto 0);
	opCode		: in	signed(5 downto 0);
	aluOut		: out	signed(31 downto 0);
	AluFlagOut	: out	std_logic);		
end entity ALU;

-- ALU architecture
architecture behave of ALU is

function myshiftLeftL(signal opA, opB : signed(31 downto 0)) return signed is
begin
	if opB = 0 then 
		return opA(30 downto 0) & '0';
	else 
		return opA(23 downto 0) & "00000000";
	end if;
end function myshiftLeftL;

function myshiftRightL(signal opA, opB : signed(31 downto 0)) return signed is
begin
	if opB = 0 then 
		return '0' & opA(31 downto 1);
	else 
		return "00000000" & opA(31 downto 8);
	end if;
end function myshiftRightL;

function myshiftRightA(signal opA, opB : signed(31 downto 0)) return signed is
begin
	if opB = 0 then 
		return opA(31) & opA(31 downto 1);
	else 
		return opA(31) & opA(31) & opA(31) & opA(31) & opA(31) & opA(31) & opA(31) & opA(31) & opA(31 downto 8);
	end if;
end function myshiftRightA;

function toSTDLogic(bool : boolean) return std_logic
is
begin
	if bool then
		return '1';
	else
		return '0';
	end if;
end function toSTDLogic;

Signal opAunsigned, opBunsigned : unsigned(31 downto 0);

begin

opAunsigned <= unsigned(opA);
opBunsigned <= unsigned(opB);

with opCode select
aluOut <=	opA + opB when opcADD | opcADDI | opcJMPR | opcBRR,
		opA - opB when opcSUB | opcSUBI,
		opA and opB when opcAND | opcANDI,
		opA or opB when opcOR | opcORI,
		not opA when opcNOT,
		-- myShift mit Register, wenn 0 im Register Shift um 1, wenn anderer Wert als 0 Shift um 8
		myshiftLeftL(opA, opB) when opcSHL | opcSHLI,
		myshiftRightL(opA, opB) when opcSHRL | opcSHRLI,
		myshiftRightA(opA, opB) when opcSHRA | opcSHRAI,
		opB when opcMOVE | opcMOVI,
		opA when others;

with opCode select
AluFlagOut <=	toSTDLogic(opA = opB) when opcCEQ | opcCEQI,
	   	toSTDLogic(opA < opB) when opcCLTS | opcCLTSI,
		toSTDLogic(opA > opB) when opcCGTS | opcCGTSI,
		toSTDLogic(opAunsigned < opBunsigned) when opcCLTU | opcCLTUI,
		toSTDLogic(opAunsigned > opBunsigned) when opcCGTU | opcCGTUI,
		-- dont care
		'-' when others;

end architecture behave;