
# NC-Sim Command File
# TOOL:	ncsim(64)	14.10-s004
#
#
# You can restore this configuration with:
#
#      ncsim -cdslib /informatik2/students/home/2regenth/Mikrorechner/VHDL/cds.lib -logfile ncsim.log -errormax 15 -status work.proctst:tb -input restore.tcl
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
alias . run
alias iprof profile
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves :clk :nRst :dnWE :dnOE :dAddr :dBus :dData :pipeProcI:memAddress :pipeProcI:memData :pipeProcI:R1 :pipeProcI:R2 :pipeProcI:R2Value :pipeProcI:R3 :pipeProcI:R3Value :pipeProcI:IF_IR :pipeProcI:ID_OPA :pipeProcI:ID_OPB :pipeProcI:ID_IR :pipeProcI:EX_IR :pipeProcI:MEM_IR :pipeProcI:EX_FLAG :pipeProcI:RF1:Registers :dataMemI:data :pipeProcI:MEM_ALU :pipeProcI:RegisterWriteDATA
probe -create -database waves :pipeProcI:IR

simvision -input restore.tcl.svcf
