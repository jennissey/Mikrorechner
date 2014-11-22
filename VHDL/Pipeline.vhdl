-- .vhdl
--
-- entity	
-- architecture	behave		- 
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all
use Work.constantDefinitions.all

entity Pipeline is
port	( clk, reset		: in 	std_logic;
	  IR, DATA		: in	unsigned(31 downto 0)
	  memAdress, memData	: out unsigned(31 downto 0));
end entity Pipeline;

entity TrueFlag is
port (  clk, input	: in 	std_logic;
	output		: out	std_logic;)
end entity TrueFlag;

architecture behave of TrueFlag is
signal flag : std_logic;

begin
writeFlag : process (clk, input) is
begin
	if rising_edge(clk)	then
		flag <= input;
	end if;
end process writeFlag;

output <= flag;
end architecture behave of TrueFlag;

architecture structure of Pipeline is

signal IF_IR, IF_PC, PCr : unsigned(31 downto 0);
signal ID_PC, ID_IR, ID_OPA, ID_OPB, outR1, outR2 : unsigned(31 downto 0);
signal EX_IR, EX_PC : unsigned(31 downto 0);
signal EX_ALU, aluOut : signed(31 downto 0);
signal RegisterFlagOut, RegisterFlagIn : std_logic;
signal MEM_IR, MEM_ALU, MEM_DATA : signed(31 downto 0);
signal opA, opB : std_logic_vector(31 downto 0);

begin

IF_Register: process (clk) is
begin
	if rising_edge(clk)	then
		IF_PC <= PCr + 1;
		IF_IR <= IR;
	end if;
end process IF_Register;


ID_Register: process (clk) is
begin
	if rising_edge(clk)	then
		ID_PC <= IF_PC;
		ID_IR <= IF_IR;
		ID_OPA <= outR1;
		ID_OPB <= outR2;
	end if;
end process ID_Register;

EX_Register: process (clk) is
begin
	if rising_edge(clk)	then
		EX_PC <= ID_PC;
		EX_IR <= ID_IR;
		EX_OPA <= ID_OPA;
		EX_ALU <= aluOut;
		EX_FLAG <= RegisterFlagOut;
	end if;
end process EX_Register;

MEM_Register: process (clk) is
begin
	if rising_edge(clk)	then
		MEM_IR <= EX_IR;
		MEM_ALU <= EX_ALU;
		MEM_DATA <= DATA;
	end if;
end process MEM_Register;

-- Alu Multiplexer 1
opA <= ID_PC when ID_IR(5 downto 0) = JMPR or ID_IR(5 downto 0) = BRR
else R2;

-- Alu Multiplexer 2
opB <= R3 when ID_IR(0) = '0' and ID_IR(5 downto 0) != opcLOAD
else "000000" & ID_IR(31 downto 6) when ID_IR(5 downto 0) = opcJMPR or ID_IR(5 downto 0) = opcBRR
else "00000000000" & ID_IR(31 downto 11) when ID_IR(5 downto 0) = opcCEQI or ID_IR(5 downto 0) = opcCLTUI or ID_IR(5 downto 0) = opcCLTSI or ID_IR(5 downto 0) = opcCGTUI or ID_IR(5 downto 0) = opcCGTSI or ID_IR(5 downto 0) = opcMOVI
else "0000000000000000" & ID_IR(31 downto 16)

-- Register Multiplexer
R1 <= MEM_DATA when MEM_IR(5 downto 0) = opcLOAD
else MEM_ALU;

-- PC Multiplexer
PC_Multiplexer : process (opCode, RegisterFlagOut, EX_OPA, EX_ALU, EX_IR) is
begin
	if EX_IR(5 downto 0) = opcJMPA | opcJMPR | opcBRA | opcBRR then
	case opCode is
		when opcJMPA => PC <= EX_OPA;
		when opcJMPR => PC <= EX_ALU;
		when opcBRA =>
			if RegisterFlagOut = '1' then
				PC <= EX_OPA;
			end if;
		when opcBRR =>
			if RegisterFlagOut = '1' then
				PC <= EX_ALU;
			end if;
	end case;
	end if;
end process;
			
RF1: RF port map (clk => clk, R2 => R2, R3 => R3, PCr => PCr, R1 => R1, data => data, writeEnable => writeEnable, R2Value => R2Value, R3Value => R3Value);
ALU1: ALU port map (opA => opA, opB => opB, opCode => ID_IR(5 downto 0), aluOut => aluOut, AluFlagOut => RegisterFlagIn, AluFlagIn => RegisterFlagOut);
TRUEFLAG1: TrueFlag port map (clk => clk, input => AluFlagIn, output => RegisterFlagOut)

end architecture structure;
