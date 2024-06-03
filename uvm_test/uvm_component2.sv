import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_monitor extends uvm_component;
  `uvm_component_utils(apb_monitor)
  string name = "apb_monitor";

  function new(string name = "apb_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info (name, $sformatf("get_depth = %0d", get_depth()), UVM_LOW)
  endfunction
endclass

class apb_agent extends uvm_component;
  `uvm_component_utils(apb_agent)

  string name = "apb_agent";
  apb_monitor apb_monitor_obj;

  function new(string name = "apb_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    apb_monitor_obj = apb_monitor::type_id::create("apb_monitor_obj", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info (name, $sformatf("get_depth = %0d", get_depth()), UVM_LOW)
  endfunction
endclass

class child_comp extends uvm_component;
  `uvm_component_utils(child_comp)

  function new(string name = "child_comp", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

class top_comp extends uvm_component;
  `uvm_component_utils(top_comp)

  child_comp child_comp_obj[3];
  apb_agent apb_agent_obj;
  string name = "top_comp";

  function new(string name = "top_comp", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    foreach(child_comp_obj[i])
      child_comp_obj[i] = child_comp::type_id::create($sformatf("child_comp_obj_%0d", i), this);

    apb_agent_obj = apb_agent::type_id::create("apb_agent_obj", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    //super.end_of_elaboration_phase(phase);
    uvm_component temp_comp;
    uvm_component temp_comp_queue[$];

    temp_comp = get_parent();
    `uvm_info(name, $sformatf("get_parent=%s", temp_comp.get_name()), UVM_LOW)

    get_children(temp_comp_queue);
    foreach (temp_comp_queue[i])
      `uvm_info(name, $sformatf("child[%0d] = %s", i, temp_comp_queue[i].get_name()), UVM_LOW)
    
    `uvm_info (name, $sformatf("number of children = %0d", get_num_children()), UVM_LOW)
    `uvm_info (name, $sformatf("has_child('123') = %0d", has_child("123")), UVM_LOW)
    `uvm_info (name, $sformatf("has_child('apb_agent') = %0d", has_child("apb_agent_obj")), UVM_LOW)
    `uvm_info (name, $sformatf("get_depth = %0d", get_depth()), UVM_LOW)

    temp_comp = lookup("apb_monitor_obj");
    if (temp_comp) // Cannot find child apb_monitor_obj
        `uvm_info (name, $sformatf("1Found %s", temp_comp.get_full_name()), UVM_LOW)

    temp_comp = lookup("apb_agent_obj.apb_monitor_obj");
    if (temp_comp) // Found uvm_test_top.top_comp_obj.apb_agent_obj.apb_monitor_obj
        `uvm_info (name, $sformatf("2Found %s", temp_comp.get_full_name()), UVM_LOW)
  endfunction
endclass

class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  top_comp top_comp_obj;
  string name = "base_test";

  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    top_comp_obj = top_comp::type_id::create("top_comp_obj", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info (name, $sformatf("get_depth = %0d", get_depth()), UVM_LOW)
  endfunction
endclass

module tb;
  initial begin
    $display("start");
    run_test("base_test");
  end
endmodule


