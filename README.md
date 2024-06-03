https://www.microsemi.com/document-portal/doc_view/131619-modelsim-user

Step 1 — Collect Files and Map Libraries
Creating the Logical Library (vlib)
$vlib work
$vmap work work


Step 2 — Compile the Design
• vlog — Verilog
• vcom — VHDL
• sccom — SystemC

vlog  +incdir+C:/intelFPGA/22.1std/questa_fse/uvm-1.2/ .\uvm_test.sv

vlog <xxx.v> <yyy.v> +define+macro=value

vlog tb_top.sv d_ff.sv


vsim -c tb -do "run -all; quit -f"
vsim -c tb -do "run 10000; quit -f"



Run the batch-mode simulation.
a. Enter the following command at the DOS/UNIX prompt:
vsim -c -do sim.do counter -wlf counter.wlf
The -c argument instructs ModelSim not to invoke the GUI. The -wlf argument
saves the simulation results in a WLF file. This allows you to view the simulation
results in the GUI for debugging purposes.
