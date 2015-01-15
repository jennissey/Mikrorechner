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
signal ID_PC, ID_IR, ID_OPA, ID_OPB, ID_MEMADRESS		: signed(31 downto 0);
--Adressen in der Registerbank von den Operanden R1 = R2 op R3
signal R1, R2, R3						: unsigned(4 downto 0);
signal EX_IR, EX_PC, EX_MEMADRESS				: signed(31 downto 0);
signal EX_ALU, EX_OPA, aluOut				: signed(31 downto 0);
signal EX_FLAG, RegisterFlag					: std_logic;
signal MEM_IR, MEM_ALU, MEM_DATA, RegisterWriteDATA	: signed(31 downto 0);
signal opA, opB						: signed(31 downto 0);
signal writeEnable						: std_logic;
--Werte der Operanden 
signal R2Value, R3Value					: signed(31 downto 0);

begin

PCout <= PCValue;

PCValueNew <= PCValue + 1;

-- R2 und R3 holen, R1 kommt später bei ME
IF_Register: process (clk, nRes) is
begin
	if nRes = '0' then
		IF_IR(5 downto 0)	<= opcNOP;
		IF_IR(31 downto 6)	<= "00000000000000000000000000";
	
	elsif rising_edge(clk)	then
		-- PC Adder
		IF_PC	<= PCValueNew;
		IF_IR	<= IR;

		R2 <= unsigned(IR(15 downto 11));

		--wenn Immediate Wert oder Vergleichsoperation
		if 	IR(5 downto 0) = opcSTORE or IR(5 downto 0) = opcLOAD or  IR(5 downto 0) = opcCEQI or IR(5 downto 0) = opcCLTUI or IR(5 downto 0) = opcCLTSI or 
			IR(5 downto 0) = opcCGTUI or IR(5 downto 0) = opcCGTSI or IR(5 downto 0) = opcJMPA or IR(5 downto 0) = opcBRA or IR(5 downto 0) = opcCEQ or  
			IR(5 downto 0) = opcCLTU or IR(5 downto 0) = opcCLTS  or  IR(5 downto 0) = opcCGTU or IR(5 downto 0) = opcCGTS   then
				R3 <= unsigned(IR(10 downto 6));
		--wenn kein Immediate Wert	
		else
				R3 <= unsigned(IR(20 downto 16));
		end if;
	end if;
end process IF_Register;

--Decodier-Phase der Pipeline
ID_Register: process (clk, nRes) is
begin
	if nRes = '0' then
		ID_IR(5 downto 0)	<= opcNOP;
		ID_IR(31 downto 6)	<= "00000000000000000000000000";
	
	elsif rising_edge(clk)	then
		ID_PC	<= IF_PC;
		ID_IR	<= IF_IR;

		--R2Value und R3Value kommen von der Registerbank
			
		if IF_IR(5 downto 0) = opcJMPA or IF_IR(5 downto 0) = opcBRA or IF_IR(5 downto 0) = opcCEQ or IF_IR(5 downto 0) = opcCEQI or IF_IR(5 downto 0) = opcCLTU or IF_IR(5 downto 0) = opcCLTS or IF_IR(5 downto 0) = opcCLTUI or IF_IR(5 downto 0) = opcCLTSI or IF_IR(5 downto 0) = opcCGTU or IF_IR(5 downto 0) = opcCGTS or IF_IR(5 downto 0) = opcCGTUI or IF_IR(5 downto 0) = opcCGTSI then
			ID_OPA <= R3Value;
			ID_OPB <= R2Value;
		else
			ID_OPA <= R2Value;
		end if;

		--R3Value könnte auch Immediate sein, dann muss er aus dem Befehl geholt werden, kann signed sein, daher auffüllen mit IR(31) auf 32 bit
		if IF_IR(0) = '1' or IF_IR(5 downto 0) = opcLOAD then
			case IF_IR(5 downto 0) is 
				-- R1, R2 und Imm
				when opcADDI | opcSUBI | opcORI | opcSHLI | opcSHRAI | opcSHRLI | opcLOAD | opcSTORE => 
					ID_OPB <= IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31 downto 16);
				-- R1 und Imm
				when opcCEQI | opcCLTUI | opcCGTUI | opcCGTSI | opcMOVI => 
					ID_OPB <= IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31 downto 11);
				-- nur Imm
	 			when opcBRR | opcJMPR => 
					ID_OPB <= IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31 downto  6);
					ID_OPA <= ID_PC;
				--muss bei case vorkommen
				when others => null;
			end case;
		else
			ID_OPB <= R3Value;
		end if;
		
		if IF_IR(5 downto 0) = opcSTORE or IF_IR(5 downto 0) = opcLOAD then
			memData <= R3Value;
		end if;
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
		else
			dnWE	<= '1';
			dnOE	<= '0';
		end if;
		EX_MEMADRESS <= aluOut;
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
		R1 <= unsigned(EX_IR(10 downto 6));
	end if;
end process MEM_Register;

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
		when opcHALT => PCr <= PCValueNew - 1;
		when others => null;
	end case;

end process PC_Multiplexer;

memAddress <= EX_MEMADRESS;

writeEnable <= '1' when 
			MEM_IR(5) = '1' or MEM_IR(5 downto 0) = opcMOVE or MEM_IR(5 downto 0) = opcMOVI or MEM_IR(5 downto 0) = opcLOAD
else '0';

RF1: RF port map (clk => clk, nRes => nRes, R2 => R2, R3 => R3, PCValue => PCValue, R1 => R1, data => RegisterWriteDATA, PCr => PCr, writeEnable => writeEnable, R2Value => R2Value, R3Value => R3Value);

ALU1: ALU port map (opA => ID_OPA, opB => ID_OPB, opCode => ID_IR(5 downto 0), aluOut => aluOut, AluFlagOut => RegisterFlag);

end architecture structure;