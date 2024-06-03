import uvm_pkg::*;
`include "uvm_macros.svh"


class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  string name = "base_test";

  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
    name = name;
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(name, $sformatf("%s build phase", name), UVM_LOW)
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);

  endfunction
endclass

class base_test2 extends uvm_test;
  `uvm_component_utils(base_test2)

  string name = "base_test2";

  function new(string name = "base_test2", uvm_component parent);
    super.new(name, parent);
    name = name;
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(name, $sformatf("%s build phase", name), UVM_LOW)
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);

  endfunction
endclass

module tb;
  initial begin
    $display("start33");
    // run_test("base_test");
    run_test();
  end
endmodule


