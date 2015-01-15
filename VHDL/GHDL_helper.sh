#!/bin/bash

function GHDLBuild {
	printf "Analysiere constantsDefinitions\n"
	ghdl -a constantsDefinitions.vhdl
	printf "Analysiere ALU\n"
	ghdl -a ALU.vhdl
	printf "Analysiere Registerbank\n"
	ghdl -a Registerbank.vhdl
	printf "Analysiere Pipeline\n"
	ghdl -a Pipeline.vhdl
	printf "Analysiere std_logic_textio\n"
	ghdl -a std_logic_textio.vhdl
	printf "Analysiere sram\n"
	ghdl -a sram.vhdl
	printf "Analysiere procTst\n"
	ghdl -a procTst.vhdl
	printf "Elaboriere und starte procTst\n"
	ghdl --elab-run procTst --vcd=waves.vcd
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

