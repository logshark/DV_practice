import uvm_pkg::*;
`include "uvm_macros.svh"

`define ADDR_WIDTH 8
`define DATA_WIDTH 16
`define ADDR_DIV   8'h3F
`define DEPTH 8

module switch
  # (parameter ADDR_WIDTH = 8,
     parameter DATA_WIDTH = 16,
     parameter ADDR_DIV = 8'h3F
    )

  ( input clk,
    input rstn,
    input vld,

   input [ADDR_WIDTH-1:0] addr,
   input [DATA_WIDTH-1:0] data,

   output reg [ADDR_WIDTH-1:0] addr_a,
   output reg [DATA_WIDTH-1:0] data_a,
   output reg [ADDR_WIDTH-1:0] addr_b,
   output reg [DATA_WIDTH-1:0] data_b
  );

  always @ (posedge clk) begin
    if (!rstn) begin
      addr_a <= 0;
      data_a <= 0;
      addr_b <= 0;
      data_b <= 0;
    end else begin
      if (vld) begin
        if (addr >= 0 & addr <= ADDR_DIV) begin
          addr_a <= addr;
          data_a <= data;
          addr_b <= 0;
          data_b <= 0;
        end else begin
          addr_a <= 0;
          data_a <= 0;
          addr_b <= addr;
          data_b <= data;
        end
      end
    end
  end
endmodule

// The interface allows verification components to access DUT signals
// using a virtual interface handle
interface switch_vif (input bit clk);
  logic rstn;
  logic vld;
  logic [7:0]   addr;
  logic [15:0]  data;

  logic [7:0]   addr_a;
  logic [15:0]  data_a;

  logic [7:0]   addr_b;
  logic [15:0]  data_b;
endinterface

// This is the base transaction object that will be used
// in the environment to initiate new transactions and
// capture transactions at DUT interface
// class switch_item extends uvm_sequence_item;
//   rand bit [7:0]    addr;
//   rand bit [15:0]   data;
//   bit [7:0]     addr_a;
//   bit [15:0]     data_a;
//   bit [7:0]     addr_b;
//   bit [15:0]     data_b;

//   // Use utility macros to implement standard functions
//   // like print, copy, clone, etc
//   `uvm_object_utils_begin(switch_item)
//     `uvm_field_int (addr, UVM_DEFAULT)
//     `uvm_field_int (data, UVM_DEFAULT)
//     `uvm_field_int (addr_a, UVM_DEFAULT)
//     `uvm_field_int (data_a, UVM_DEFAULT)
//     `uvm_field_int (addr_b, UVM_DEFAULT)
//     `uvm_field_int (data_b, UVM_DEFAULT)
//   `uvm_object_utils_end

//   function new(string name = "switch_item");
//     super.new(name);
//   endfunction
// endclass

// class driver extends uvm_driver #(switch_item);
//   `uvm_component_utils(driver)
//   function new(string name = "driver", uvm_component parent=null);
//     super.new(name, parent);
//   endfunction

//   virtual switch_if vif;

//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     if (!uvm_config_db#(virtual switch_if)::get(this, "", "switch_vif", vif))
//       `uvm_fatal("DRV", "Could not get vif")
//   endfunction

//   virtual task run_phase(uvm_phase phase);
//     super.run_phase(phase);
//     forever begin
//       switch_item m_item;
//       `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
//       seq_item_port.get_next_item(m_item);
//       drive_item(m_item);
//       seq_item_port.item_done();
//     end
//   endtask

//   virtual task drive_item(switch_item m_item);
//     vif.vld   <= 1;
//     vif.addr   <= m_item.addr;
//     vif.data    <= m_item.data;

//     @ (posedge vif.clk);
//     vif.vld   <= 0;
//   endtask
// endclass

// class monitor extends uvm_monitor;
//   `uvm_component_utils(monitor)
//   function new(string name="monitor", uvm_component parent=null);
//     super.new(name, parent);
//   endfunction

//   uvm_analysis_port  #(switch_item) mon_analysis_port;
//   virtual switch_if vif;
//   semaphore sema4;

//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     if (!uvm_config_db#(virtual switch_if)::get(this, "", "switch_vif", vif))
//       `uvm_fatal("MON", "Could not get vif")
//     sema4 = new(1);
//     mon_analysis_port = new ("mon_analysis_port", this);
//   endfunction

//   virtual task run_phase(uvm_phase phase);
//     super.run_phase(phase);
//     fork
//       sample_port("Thread0");
//       sample_port("Thread1");
//     join
//   endtask

//   virtual task sample_port(string tag="");
//     // This task monitors the interface for a complete
//     // transaction and pushes into the mailbox when the
//     // transaction is complete
//     forever begin
//       @(posedge vif.clk);
//       if (vif.rstn & vif.vld) begin
//         switch_item item = new;
//         sema4.get();
//         item.addr = vif.addr;
//         item.data = vif.data;
//         `uvm_info("MON", $sformatf("T=%0t [Monitor] %s First part over",
//                                    $time, tag), UVM_LOW)
//         @(posedge vif.clk);
//         sema4.put();
//         item.addr_a = vif.addr_a;
//         item.data_a = vif.data_a;
//         item.addr_b = vif.addr_b;
//         item.data_b = vif.data_b;
//         mon_analysis_port.write(item);
//         `uvm_info("MON", $sformatf("T=%0t [Monitor] %s Second part over, item:",
//                  $time, tag), UVM_LOW)
//         item.print();
//       end
//     end
//   endtask
// endclass

// class agent extends uvm_agent;
//   `uvm_component_utils(agent)
//   function new(string name="agent", uvm_component parent=null);
//     super.new(name, parent);
//   endfunction

//   driver     d0;     // Driver handle
//   monitor     m0;     // Monitor handle
//   uvm_sequencer #(switch_item)  s0;     // Sequencer Handle

//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     s0 = uvm_sequencer#(switch_item)::type_id::create("s0", this);
//     d0 = driver::type_id::create("d0", this);
//     m0 = monitor::type_id::create("m0", this);
//   endfunction

//   virtual function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     d0.seq_item_port.connect(s0.seq_item_export);
//   endfunction
// endclass

// class scoreboard extends uvm_scoreboard;
//   `uvm_component_utils(scoreboard)
//   function new(string name="scoreboard", uvm_component parent=null);
//     super.new(name, parent);
//   endfunction

//   uvm_analysis_imp #(switch_item, scoreboard) m_analysis_imp;

//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     m_analysis_imp = new("m_analysis_imp", this);
//   endfunction

//   virtual function write(switch_item item);
//       if (item.addr inside {[0:'h3f]}) begin
//         if (item.addr_a != item.addr | item.data_a != item.data)
//           `uvm_error("SCBD", $sformatf("ERROR! Mismatch addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h", item.addr, item.data, item.addr_a, item.data_a))
//         else
//           `uvm_info("SCBD", $sformatf("PASS! Match addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h", item.addr, item.data, item.addr_a, item.data_a), UVM_LOW)

//       end else begin
//         if (item.addr_b != item.addr | item.data_b != item.data)
//           `uvm_error("SCBD", $sformatf("ERROR! Mismatch addr=0x%0h data=0x%0h addr_b=0x%0h data_b=0x%0h", item.addr, item.data, item.addr_b, item.data_b))
//         else
//           `uvm_info("SCBD", $sformatf("PASS! Match addr=0x%0h data=0x%0h addr_b=0x%0h data_b=0x%0h", item.addr, item.data, item.addr_b, item.data_b), UVM_LOW)
//       end
//   endfunction
// endclass

// class env extends uvm_env;
//   `uvm_component_utils(env)
//   function new(string name="env", uvm_component parent=null);
//     super.new(name, parent);
//   endfunction

//   agent     a0;     // Agent handle
//   scoreboard  sb0;     // Scoreboard handle

//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     a0 = agent::type_id::create("a0", this);
//     sb0 = scoreboard::type_id::create("sb0", this);
//   endfunction

//   virtual function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
//   endfunction
// endclass


// class gen_item_seq extends uvm_sequence;
//   `uvm_object_utils(gen_item_seq)
//   function new(string name="gen_item_seq");
//     super.new(name);
//   endfunction

//   rand int num;   // Config total number of items to be sent

//   constraint c1 { num inside {[2:5]}; }

//   virtual task body();
//     for (int i = 0; i < num; i ++) begin
//       switch_item m_item = switch_item::type_id::create("m_item");
//       start_item(m_item);
//       m_item.randomize();
//       `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
//       m_item.print();
//         finish_item(m_item);
//     end
//     `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
//   endtask
// endclass


class c1 extends uvm_component;
  `uvm_component_utils(c1);

  function new(string name = "c1", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("c1 build");
  endfunction

  virtual task run_phase(uvm_phase phase);
    $display("c1 run");
  endtask
endclass




// mytestenv
class env extends uvm_env;
  `uvm_component_utils(env)

  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("env build");
  endfunction

  virtual task run_phase(uvm_phase phase);
    $display("env run");
  endtask

endclass



class test extends uvm_test;
  `uvm_component_utils(test)
  function new(string name = "test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  env e0;
  virtual switch_if vif;
  c1 c1_ins;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("test build_phase start");
    e0 = env::type_id::create("e0", this);

    if (uvm_config_db #(string) :: get (null, "uvm_test_top", "Friend", name))
      `uvm_info ("ENV", $sformatf ("Found %s", name), UVM_MEDIUM)

    if (!uvm_config_db#(virtual switch_if)::get(this, "", "switch_vif", vif))
      `uvm_fatal("TEST", "Did not get vif")

    c1_ins = c1::type_id::create("c1_ins", this);
    // uvm_config_db#(virtual switch_if)::set(this, "e0.a0.*", "switch_vif", vif);
    // uvm_config_db#(virtual switch_if)::set(this, "e0.*", "switch_vif", vif);
    $display("test build_phase end");
  endfunction

  virtual task run_phase(uvm_phase phase);
    $display("test run_phase start");
    // gen_item_seq seq = gen_item_seq::type_id::create("seq");
    // phase.raise_objection(this);
    // apply_reset();

    // seq.randomize();
    // seq.start(e0.a0.s0);
    // phase.drop_objection(this);
    $display("test run_phase end");
  endtask

  virtual task apply_reset();
    // vif.rstn <= 0;
    // repeat(5) @ (posedge vif.clk);
    // vif.rstn <= 1;
    // repeat(10) @ (posedge vif.clk);
    $display("test apply_reset");
  endtask
endclass

module tb;
  reg clk;

  always #10 clk =~ clk;
  switch_vif vif (clk);
  switch u0 (   .clk(clk),
             .rstn(vif.rstn),
             .addr(vif.addr),
             .data(vif.data),
             .vld (vif.vld),
             .addr_a(vif.addr_a),
             .data_a(vif.data_a),
             .addr_b(vif.addr_b),
             .data_b(vif.data_b));
  // test t0;

  initial begin
    $display("tb start");
    // t0 = new;
    uvm_config_db #(virtual switch_vif)::set(null, "*", "switch_vif", vif);

    uvm_config_db #(string) :: set (null, "uvm_test_top", "Friend", "Joey");
    run_test ("test");
    $display("tb end");
  end

  // System tasks to dump VCD waveform file
  // initial begin
  //   $dumpvars;
  //   $dumpfile ("dump.vcd");
  // end
endmodule