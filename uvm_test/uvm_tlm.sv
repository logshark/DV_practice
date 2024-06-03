import uvm_pkg::*;
`include "uvm_macros.svh"

class packet extends uvm_object;
  bit[7:0] addr;
  bit[7:0] data;

  `uvm_object_utils_begin(packet)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "packet");
    super.new(name);
  endfunction
endclass

class comp_A extends uvm_component;

  `uvm_component_utils(comp_A)
  int m_num_tx;
  uvm_blocking_put_port #(packet) m_put_port;

  function new(string name = "comp_A", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_put_port = new("m_put_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    repeat (m_num_tx) begin
      packet pkt = packet::type_id::create("pkt");
      // assert(pkt.randomize());

      `uvm_info("comp_A", "packet send to compB", UVM_LOW);
      pkt.print(uvm_default_line_printer);

      m_put_port.put(pkt);
    end
    phase.drop_objection(this);
  endtask
endclass

class comp_B extends uvm_component;
  `uvm_component_utils(comp_B)
  uvm_blocking_put_imp #(packet, comp_B) m_put_imp;

  function new(string name = "comp_B", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_put_imp = new("m_put_imp", this);
  endfunction

  virtual task put(packet pkt);
    // `uvm_info("comp_B", "pkt received from compA", UVM_LOW);
    // pkt.print(uvm_default_line_printer);

    `uvm_info("COMPB", $sformatf("Processing packet"), UVM_LOW)
    #20;
    `uvm_info("COMPB", $sformatf("Processing packet finished ..."), UVM_LOW)

    `uvm_info ("COMPB", "Packet received from CompA", UVM_LOW)
    pkt.print(uvm_default_line_printer);
  endtask
endclass

class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  comp_A comp_a;
  comp_B comp_b;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("aaa");
    comp_a = comp_A::type_id::create("comp_a", this);
    $display("bbb");
    comp_b = comp_B::type_id::create("comp_b", this);
    $display("ccc");
    comp_a.m_num_tx = 2;
    $display("ddd");
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    $display("eee");
    comp_a.m_put_port.connect(comp_b.m_put_imp);
    $display("fff");
  endfunction

endclass

module tb;
  initial begin;
    $display("tb");
    run_test("base_test");
  end

endmodule
