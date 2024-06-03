import uvm_pkg::*;
`include "uvm_macros.svh"

module tb_top;
	bit clk;
	always #10 clk <= ~clk;

	
endmodule