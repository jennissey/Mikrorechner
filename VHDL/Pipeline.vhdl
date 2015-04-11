-- Pipeline.vhdl
-- enthält alle Pipeline Stufen, so wie die verknüpfungen zwischen diesen
-- 
-- entity: Pipeline		: Pipeline
-- architecture: structure	: Verhalten der Pipeline
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

signal IF_IR, IF_PC, PCValue, PCValueNew, PCr				: signed(31 downto 0);
signal ID_PC, ID_IR, ID_OPA, ID_OPB, ID_MEMADRESS, ID_MEMDATA	: signed(31 downto 0);
--Adressen in der Registerbank von den Operanden R1 = R2 op R3
signal R1, R2, R3							: unsigned(4 downto 0);
signal EX_IR, EX_PC							: signed(31 downto 0);
signal EX_ALU, EX_OPA, aluOut					: signed(31 downto 0);
signal EX_FLAG, RegisterFlag						: std_logic;
signal MEM_IR, MEM_ALU, MEM_DATA, RegisterWriteDATA		: signed(31 downto 0);
signal opA, opB							: signed(31 downto 0);
signal writeEnable							: std_logic;
--Werte der Operanden 
signal R2Value, R3Value						: signed(31 downto 0);

begin

PCout <= PCValue;
PCValueNew <= PCValue + 1;

-- Instruction Fetch Stufe der Pipeline
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
		if	IR(5 downto 0) = opcSTORE
		or	IR(5 downto 0) = opcLOAD
		or	IR(5 downto 0) = opcCEQI
		or	IR(5 downto 0) = opcCLTUI
		or	IR(5 downto 0) = opcCLTSI
		or	IR(5 downto 0) = opcCGTUI
		or	IR(5 downto 0) = opcCGTSI
		or	IR(5 downto 0) = opcJMPA
		or	IR(5 downto 0) = opcBRA
		or	IR(5 downto 0) = opcCEQ
		or	IR(5 downto 0) = opcCLTU
		or	IR(5 downto 0) = opcCLTS  
		or	IR(5 downto 0) = opcCGTU 
		or	IR(5 downto 0) = opcCGTS	then
				R3 <= unsigned(IR(10 downto 6));
		--wenn kein Immediate Wert	
		else
				R3 <= unsigned(IR(20 downto 16));
		end if;
	end if;
end process IF_Register;

-- Instruction Decode Phase der Pipeline
ID_Register: process (clk, nRes) is
begin
	if nRes = '0' then
		ID_IR(5 downto 0)	<= opcNOP;
		ID_IR(31 downto 6)	<= "00000000000000000000000000";
	
	elsif rising_edge(clk)	then
		ID_PC		<= IF_PC;
		ID_IR		<= IF_IR;
		ID_MEMDATA	<= R3Value;
		
		--R2Value und R3Value kommen von der Registerbank
		--R3Value könnte auch Immediate sein, dann muss er aus dem Befehl geholt werden, kann signed sein, daher auffüllen mit IR(31) auf 32 bit
		case IF_IR(5 downto 0) is 
			when opcADD | opcSUB | opcAND | opcOR | opcNOT | opcSHL | opcSHRA | opcSHRL =>
				ID_OPA <= R2Value;
				ID_OPB <= R3Value;
			-- R1, R2 und Imm
			when opcADDI | opcSUBI | opcORI | opcSHLI | opcSHRAI | opcSHRLI | opcLOAD | opcSTORE => 
				ID_OPA <= R2Value;
				ID_OPB <= IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31 downto 16);
			-- R1 und Imm
			when opcCEQI | opcCLTUI | opcCGTUI | opcCGTSI | opcMOVI | opcCLTSI  => 
				ID_OPA <= R3Value;
				ID_OPB <= IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31 downto 11);
			-- nur Imm
 			when opcBRR | opcJMPR => 
				ID_OPA <= ID_PC;
				ID_OPB <= IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31) & IF_IR(31 downto  6);
			when opcMOVE =>
				ID_OPB <= R2Value;
			when opcJMPA | opcBRA |  opcCEQ | opcCLTU | opcCLTS | opcCGTU |  opcCGTS =>
				ID_OPA <= R3Value;
				ID_OPB <= R2Value;
			-- muss bei case vorkommen
			when others => null;
		end case;
	end if;
end process ID_Register;

--Execute Phase der Pipeline
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

		-- Flag Ausgang der Alu zwischenspeichern, wenn benötigt
		if	ID_IR(5 downto 0) = opcCEQI 
		or	ID_IR(5 downto 0) = opcCLTUI 
		or	ID_IR(5 downto 0) = opcCLTSI 
		or	ID_IR(5 downto 0) = opcCGTUI 
		or	ID_IR(5 downto 0) = opcCGTSI
		or	ID_IR(5 downto 0) = opcJMPA 
		or	ID_IR(5 downto 0) = opcCEQ 
		or	ID_IR(5 downto 0) = opcCLTU
		or	ID_IR(5 downto 0) = opcCLTS
		or	ID_IR(5 downto 0) = opcCGTU 
		or	ID_IR(5 downto 0) = opcCGTS		then
				EX_FLAG	<= RegisterFlag;
		end if;

		-- Write Enable setzen, wenn gespeichert werden soll
		if ID_IR(5 downto 0) = opcSTORE then
			dnWE		<= '0';
			dnOE		<= '1';
			memData	<= ID_MEMDATA;
		else
			dnWE	<= '1';
			dnOE	<= '0';
		end if;
	end if;
end process EX_Register;

-- Write Back Phase der Pipeline
MEM_Register: process (clk, nRes) is
begin
	if nRes = '0' then
		MEM_IR(5 downto 0)	<= opcNOP;
		MEM_IR(31 downto 6)	<= "00000000000000000000000000";
	
	elsif rising_edge(clk)	then
		MEM_IR	<= EX_IR;
		MEM_ALU	<= EX_ALU;
		MEM_DATA	<= DATA;
		R1 		<= unsigned(EX_IR(10 downto 6));
	end if;
end process MEM_Register;

-- Register Multiplexer
RegisterWriteDATA <= MEM_DATA when 
					MEM_IR(5 downto 0) = opcLOAD
			else MEM_ALU;

-- PC Multiplexer
PC_Multiplexer : process (EX_FLAG, EX_OPA, EX_ALU, EX_IR, PCValueNew) is
begin
	-- Programmcounter einfrieren, wenn Halt
	if MEM_IR(5 downto 0) = opcHALT then
		PCr <= PCValueNew - 1;
	else
		PCr <= PCValueNew;
	end if;

	-- if(EX_IR(5 downto 0) == opcJMPA); then PCr = EX_OPA, usw.
	case EX_IR(5 downto 0) is
		when opcJMPA => PCr <= EX_OPA;
		when opcJMPR => PCr <= EX_ALU;
		when opcBRA	=>
			if EX_FLAG	= '1' then
				PCr <= EX_OPA;
			end if;
		when opcBRR =>
			if EX_FLAG = '1' then
				PCr	<= EX_ALU;
			end if;
		when others => null;
	end case;

end process PC_Multiplexer;

memAddress <= EX_ALU when
	EX_IR(5 downto 0) = opcSTORE or EX_IR(5 downto 0) = opcLOAD else (others => '1');

-- Register Write Enable setzen wenn nötig
writeEnable <= '1' when 
			MEM_IR(5) = '1' or MEM_IR(5 downto 0) = opcMOVE or MEM_IR(5 downto 0) = opcMOVI or MEM_IR(5 downto 0) = opcLOAD
else '0';

-- Verbinden der Ports der Entities
RF1: RF port map (clk => clk, nRes => nRes, R2 => R2, R3 => R3, PCValue => PCValue, R1 => R1, data => RegisterWriteDATA, PCr => PCr, writeEnable => writeEnable, R2Value => R2Value, R3Value => R3Value);

ALU1: ALU port map (opA => ID_OPA, opB => ID_OPB, opCode => ID_IR(5 downto 0), aluOut => aluOut, AluFlagOut => RegisterFlag);

end architecture structure;