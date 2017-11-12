
destroy .wave

quit -sim

# create library
vlib work

vmap work work
####compile all  source files

vlog -cover bces -incr {../../RTL/*.v}

vlog -nocoverage -incr {../testcase.v}

vsim +ALL_TESTCASE -coverage -novopt work.testcase

log -r *


run 53ms


