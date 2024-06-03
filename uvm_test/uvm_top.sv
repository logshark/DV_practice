import uvm_pkg::*;
`include "uvm_macros.svh"

module tb;
  bit clk;
  always #10 clk <= ~clk;

  dut_if dut_if1(clk);
  dut_wrapper dut_wr0(._if (dut_if1));

  initial begin
    $display("start");
    uvm_config_db #(virtual dut_if)::set (null, "uvm_test_top", "dut_if", dut_if1);
    run_test("base_test");
  end

  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
endmodule