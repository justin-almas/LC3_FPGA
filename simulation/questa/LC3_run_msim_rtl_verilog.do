transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Justin/Desktop/LC3_FPGA {C:/Users/Justin/Desktop/LC3_FPGA/DE10_LITE_Golden_Top.v}
vlog -vlog01compat -work work +incdir+C:/Users/Justin/Desktop/LC3_FPGA {C:/Users/Justin/Desktop/LC3_FPGA/LC3.v}
vlog -vlog01compat -work work +incdir+C:/Users/Justin/Desktop/LC3_FPGA {C:/Users/Justin/Desktop/LC3_FPGA/FSM.v}
vlog -vlog01compat -work work +incdir+C:/Users/Justin/Desktop/LC3_FPGA {C:/Users/Justin/Desktop/LC3_FPGA/ALU.v}
vlog -vlog01compat -work work +incdir+C:/Users/Justin/Desktop/LC3_FPGA {C:/Users/Justin/Desktop/LC3_FPGA/REGFILE.v}

vlog -vlog01compat -work work +incdir+C:/Users/Justin/Desktop/LC3_FPGA {C:/Users/Justin/Desktop/LC3_FPGA/tb_lc3.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  tb_lc3

add wave *
view structure
view signals
run -all
