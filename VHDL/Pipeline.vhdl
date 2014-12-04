-- .vhdl
--
-- entity	
-- architecture	behave		- 
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Work.CONSTANT_DEFINITIONS.all;

entity Pipeline is
port	( clk, nRes				: in	std_logic;
	  IR, DATA				: in	signed(31 downto 0);
	  memAddress, memData, PCout	: out	signed(31 downto 0);
	  dnWE, dnOE				: out	std_logic);
end entity Pipeline;

architecture structure of Pipeline is

signal IF_IR, IF_PC, PCValue, PCValueNew, PCr		: signed(31 downto 0);
signal ID_PC, ID_IR, ID_OPA, ID_OPB				: signed(31 downto 0);
signal R1, R2, R3						: unsigned(4 downto 0);
signal EX_IR, EX_PC						: signed(31 downto 0);
signal EX_ALU, EX_OPA, aluOut				: signed(31 downto 0);
signal EX_FLAG, RegisterFlag					: std_logic;
signal MEM_IR, MEM_ALU, MEM_DATA, RegisterWriteDATA	: signed(31 downto 0);
signal opA, opB						: signed(31 downto 0);
signal writeEnable						: std_logic;
signal R2Value, R3Value					: signed(31 downto 0);

begin

PCout <= PCValue;

PCValueNew <= PCValue + 1;

IF_Register: process (clk, nRes) is
begin
	if nRes = '0' then
		IF_IR(5 downto 0)	<= opcNOP;
		IF_IR(31 downto 6)	<= "00000000000000000000000000";
	
	elsif rising_edge(clk)	then
		-- PC Adder
		IF_PC	<= PCValueNew;
		IF_IR	<= IR;

		if IR(5) = '1'  then
			R2 <= unsigned(IR(15 downto 11));
			R3 <= unsigned(IR(20 downto 16));
		else
			R2 <= unsigned(IR(10 downto 6));
			R3 <= unsigned(IR(15 downto 11));
		end if;
		
	end if;
end process IF_Register;

ID_Register: process (clk, nRes) is
begin
	if nRes = '0' then
		ID_IR(5 downto 0)	<= opcNOP;
		ID_IR(31 downto 6)	<= "00000000000000000000000000";
	
	elsif rising_edge(clk)	then
		ID_PC	<= IF_PC;
		ID_IR	<= IF_IR;
		ID_OPA <= R2Value;
		ID_OPB <= R3Value;
	end if;
end process ID_Register;

EX_Register: process (clk, nRes) is
begin
	if nRes = '0' then
		EX_IR(5 downto 0)	<= opcNOP;
		EX_IR(31 downto 6)	<= "00000000000000000000000000";
		EX_FLAG		<= '0';
		EX_PC			<= "00000000000000000000000000000000";
	
	elsif rising_edge(clk)	then
		EX_PC		<= ID_PC;
		EX_IR		<= ID_IR;
		EX_OPA	<= ID_OPA;
		EX_ALU	<= aluOut;
		EX_FLAG	<= RegisterFlag;

		if ID_IR(5 downto 0) = opcSTORE then
			dnWE	<= '0';
			dnOE	<= '1';

			memData <= aluOut;
		else
			dnWE	<= '1';
			dnOE	<= '0';
		end if;
	end if;
end process EX_Register;

MEM_Register: process (clk, nRes) is
begin
	if nRes = '0' then
		MEM_IR(5 downto 0)	<= opcNOP;
		MEM_IR(31 downto 6)	<= "00000000000000000000000000";
	
	elsif rising_edge(clk)	then
		MEM_IR	<= EX_IR;
		MEM_ALU	<= EX_ALU;
		MEM_DATA	<= DATA;
	end if;
end process MEM_Register;

-- Alu Multiplexer 1
opA <= ID_PC	when 
			ID_IR(5 downto 0) = 	opcJMPR or ID_IR(5 downto 0) = opcBRR
		else 
			R2Value;

-- Alu Multiplexer 2
opB <= R3Value	when
				ID_IR(0) = '0' and ID_IR(5 downto 0) /= opcLOAD
			-- Sign Extend Immediate Wert einfügen von 6 Vorzeichen Bits
			else 	ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31 downto 6) 
				when
					ID_IR(5 downto 0) = opcJMPR or ID_IR(5 downto 0) = opcBRR
			-- Sign Extend Immediate Wert einfügen von 11 Vorzeichen Bits
			else	ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31 downto 11) 
				when 
					ID_IR(5 downto 0) = opcCEQI or ID_IR(5 downto 0) = opcCLTUI or ID_IR(5 downto 0) = opcCLTSI or ID_IR(5 downto 0) = opcCGTUI or ID_IR(5 downto 0) = opcCGTSI or ID_IR(5 downto 0) = opcMOVI
			-- Sign Extend Immediate Wert einfügen von 16 Vorzeichen Bits
			else	ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31) & ID_IR(31 downto 16);

-- Register Multiplexer
RegisterWriteDATA <= MEM_DATA when 
					MEM_IR(5 downto 0) = opcLOAD
			else MEM_ALU;
-- PC Multiplexer
PC_Multiplexer : process (RegisterFlag, EX_OPA, EX_ALU, EX_IR, PCValueNew) is
begin
	PCr <= PCValueNew;
	case EX_IR(5 downto 0) is
		when opcJMPA => PCr <= EX_OPA;
		when opcJMPR => PCr <= EX_ALU;
		when opcBRA	=>
			if RegisterFlag	= '1' then
				PCr <= EX_OPA;
			end if;
		when opcBRR =>
			if RegisterFlag = '1' then
				PCr	<= EX_ALU;
			end if;
		when others => null;
	end case;

end process PC_Multiplexer;

memAddress <= EX_ALU;

writeEnable <= '1' when 
			MEM_IR(5) = '1' or MEM_IR(5 downto 0) = opcMOVE or MEM_IR(5 downto 0) = opcMOVI or MEM_IR(5 downto 0) = opcLOAD
else '0';

RF1: RF port map (clk => clk, nRes => nRes, R2 => R2, R3 => R3, PCValue => PCValue, R1 => R1, data => RegisterWriteDATA, PCr => PCr, writeEnable => writeEnable, R2Value => R2Value, R3Value => R3Value);

ALU1: ALU port map (opA => opA, opB => opB, opCode => ID_IR(5 downto 0), aluOut => aluOut, AluFlagOut => RegisterFlag);

end architecture structure;
