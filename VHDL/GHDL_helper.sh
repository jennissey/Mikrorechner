#!/bin/bash

function GHDLBuild {
	printf "Analysiere constantsDefinitions\n"
	ghdl -a --workdir=work --ieee=synopsys constantsDefinitions.vhdl
	printf "Analysiere ALU\n"
	ghdl -a --workdir=work --ieee=synopsys  ALU.vhdl
	printf "Analysiere Registerbank\n"
	ghdl -a --workdir=work --ieee=synopsys  Registerbank.vhdl
	printf "Analysiere Pipeline\n"
	ghdl -a --workdir=work --ieee=synopsys  Pipeline.vhdl
	#printf "Analysiere std_logic_textio\n"
	#ghdl -a std_logic_textio.vhdl
	printf "Analysiere sram\n"
	ghdl -a --workdir=work --ieee=synopsys  sram.vhdl
	printf "Analysiere procTst\n"
	ghdl -a --workdir=work --ieee=synopsys  procTst.vhdl
	printf "Elaboriere von procTst\n"
	ghdl -e --workdir=work --ieee=synopsys procTst
	printf "Simulation von procTst\n"
	./proctst --wave=procsim.ghw
}

function GHDLClean {
	ghdl --clean
}

if [ $# -lt 1 ] || [ $1 == '' ]; then
        printf "Benutzung: ./GHDL_helper.sh build|clean\n\n"
        exit

elif [ $1 == build ]; then
	GHDLBuild

elif [ $1 == clean ]; then
        GHDLClean
fi

