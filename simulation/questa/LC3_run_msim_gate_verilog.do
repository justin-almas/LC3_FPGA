transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {LC3.vo}

vlog -vlog01compat -work work +incdir+C:/Users/Justin/Desktop/LC3_FPGA {C:/Users/Justin/Desktop/LC3_FPGA/tb_lc3.v}

vsim -t 1ps -L altera_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L gate_work -L work -voptargs="+acc"  tb_lc3

add wave *
view structure
view signals
run -all
