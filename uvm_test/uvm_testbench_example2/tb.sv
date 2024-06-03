import uvm_pkg::*;
`include "uvm_macros.svh"

`define ADDR_WIDTH 8
`define DATA_WIDTH 16
`define ADDR_DIV   8'h3F
`define DEPTH 256

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
    end
    else begin
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

interface switch_if (input bit clk);
  logic rstn;
  logic vld;
  logic [7:0] addr;
  logic [15:0] data;
  logic [7:0] addr_a;
  logic [15:0] data_a;
  logic [7:0] addr_b;
  logic [15:0] data_b;
endinterface

class switch_item extends uvm_sequence_item;
    bit [7:0]  addr;
    bit [15:0] data;
    bit [7:0]  addr_a;
    bit [15:0] data_a;
    bit [7:0]  addr_b;
    bit [15:0] data_b;

    `uvm_object_utils_begin(switch_item)
        `uvm_field_int(addr, UVM_DEFAULT)
        `uvm_field_int(data, UVM_DEFAULT)
        `uvm_field_int(addr_a, UVM_DEFAULT)
        `uvm_field_int(data_a, UVM_DEFAULT)
        `uvm_field_int(addr_b, UVM_DEFAULT)
        `uvm_field_int(data_b, UVM_DEFAULT)
    `uvm_object_utils_end

    virtual function string convert2str();
        return $sformatf("addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h addr_b=0x%0h data_b=0x%0h",
                          addr, data, addr_a, data_a, addr_b, data_b);
    endfunction

    function new(string name = "switch_item");
        super.new(name);
    endfunction
endclass

class driver extends uvm_driver#(switch_item);
    `uvm_component_utils(driver)
    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual switch_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual switch_if)::get(this, "", "switch_if", vif))
            `uvm_fatal("DRV", "Could NOT get vif");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            switch_item m_item;
            `uvm_info("DRV", $sformatf("wait for item from sequencer"), UVM_LOW);
            seq_item_port.get_next_item(m_item);
            drive_item(m_item);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_item(switch_item m_item);
        vif.vld <= 1;
        vif.addr <= m_item.addr;
        vif.data <= m_item.data;
        @(posedge vif.clk);
        // while (!vif.vld) begin
        //     `uvm_info("DRV", "wait until vld is high", UVM_LOW)
        //     @(posedge vif.clk);
        // end

        vif.vld <= 0;
    endtask
endclass

class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)
    function new(string name = "Monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(switch_item) mon_analysis_port;
    virtual switch_if vif;
    semaphore sema4;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual switch_if)::get(this, "", "switch_if", vif)) begin
          `uvm_fatal("MON", "Could not get vif");
        end
        else begin
            `uvm_info("MON", "Could get vif", UVM_LOW);
        end
        sema4 = new(1);
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    // virtual task run_phase(uvm_phase phase);
    //     super.run_phase(phase);

    //     forever begin
    //       @ (posedge vif.clk);
    //       if (vif.vld) begin
    //         switch_item item = new;
    //         item.addr = vif.addr;
    //         item.data = vif.data;

    //         @ (posedge vif.clk);
    //         item.addr_a = vif.addr_a;
    //         item.data_a = vif.data_a;
    //         item.addr_b = vif.addr_b;
    //         item.data_b = vif.data_b;

    //         `uvm_info(get_type_name(), $sformatf("Monitor found packet %s", item.convert2str()), UVM_LOW)
    //         mon_analysis_port.write(item);
    //       end
    //     end
    // endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);

      fork
        sample_port("Thread1");
        sample_port("Thread2");
      join
    endtask

    virtual task sample_port(string tag);
      `uvm_info("MON", $sformatf("thread:%s start", tag), UVM_LOW)
      forever begin
        @ (posedge vif.clk);
        if (vif.vld) begin
          switch_item item = new;
          sema4.get();
          item.addr = vif.addr;
          item.data = vif.data;
          `uvm_info("MON", $sformatf("%s 1st step", tag), UVM_LOW)
          @ (posedge vif.clk);
          item.addr_a = vif.addr_a;
          item.data_a = vif.data_a;
          item.addr_b = vif.addr_b;
          item.data_b = vif.data_b;
          `uvm_info("MON", $sformatf("%s 2nd step", tag), UVM_LOW)
          mon_analysis_port.write(item);
          sema4.put();
        end
      end
    endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  function new(string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  monitor m0;
  driver d0;
  uvm_sequencer #(switch_item) s0;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m0 = monitor::type_id::create("m0", this);
    d0 = driver::type_id::create("d0", this);
    s0 = uvm_sequencer#(switch_item)::type_id::create("s0", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d0.seq_item_port.connect(s0.seq_item_export);
  endfunction
endclass

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // switch_item refq[`DEPTH];
  uvm_analysis_imp #(switch_item, scoreboard) m_analysis_imp;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function write(switch_item item);
    // if(!item.rstn) begin
    //   if (item.addr_a == 0 && item.data_a != 0 && item.addr_b != 0 && item.data_b != 0) begin
    //     `uvm_info(get_type_name(), $sformatf("rst addr_a data_a addr_b data_b are all zero"), UVM_LOW);
    //   end
    //   else begin
    //     `uvm_error(get_type_name(),
    //               $sformatf("In rst state. but not all data are zero addr_a=0x%0h data_a=0x%0h addr_b=0x%0h addr_b=0x%0h",
    //               item.addr_a, item.data_a, item.addr_b, item.data_b)
    //               );
    //   end
    // end
    // else begin
      if (item.addr <= 8'h3F) begin
        if (item.addr == item.addr_a && item.data == item.data_a && 0 == item.addr_b && 0 == item.data_b) begin
          `uvm_info(get_type_name(), $sformatf("item.addr <= ADDR_DIV expected result"), UVM_LOW);
        end
        else begin
          `uvm_error(get_type_name(),
                    $sformatf("item.addr <= ADDR_DIV result error addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h addr_b=0x%0h addr_b=0x%0h",
                    item.addr, item.data, item.addr_a, item.data_a, item.addr_b, item.data_b)
                    );
        end
      end
      else begin
        if (item.addr == item.addr_b && item.data == item.data_b && 0 == item.addr_a && 0 == item.data_a) begin
          `uvm_info(get_type_name(), $sformatf("item.addr > ADDR_DIV expected result"), UVM_LOW);
        end
        else begin
          `uvm_error(get_type_name(),
                     $sformatf("item.addr > ADDR_DIV result error addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h addr_b=0x%0h addr_b=0x%0h",
                     item.addr, item.data, item.addr_a, item.data_a, item.addr_b, item.data_b)
                    );
        end
      end
    // end
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  agent a0;
  scoreboard sb0;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a0 = agent::type_id::create("a0", this);
    sb0 = scoreboard::type_id::create("sb0", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
  endfunction
endclass

class gen_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_item_seq)
  function new(string name = "gen_item_seq");
    super.new(name);
  endfunction

  int num = 10;

  virtual task body();
    for (int i = 0; i < num; i++) begin
      switch_item m_item = switch_item::type_id::create("m_item");
      start_item(m_item);
      m_item.addr = (i + 8'h38);
      m_item.data = $random;
      `uvm_info("SEQ", $sformatf("Generate1 new item: "), UVM_LOW)
      m_item.print();
      finish_item(m_item);
    end

    `uvm_info("SEQ", $sformatf("done %0d time", num), UVM_LOW)
  endtask
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  function new(string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  env e0;
  virtual switch_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e0 = env::type_id::create("e0", this);
    if (!uvm_config_db#(virtual switch_if)::get(this, "", "switch_if", vif))
      `uvm_fatal("TEST", "Did not get vif")

    uvm_config_db#(virtual switch_if)::set(this, "e0.a0.*", "switch_if", vif);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    gen_item_seq seq = gen_item_seq::type_id::create("seq");
    phase.raise_objection(this);

    apply_reset();
    seq.num = 25;
    $display("seq.start");
    seq.start(e0.a0.s0);
    $display("seq gogo");
    #1000
    phase.drop_objection(this);
  endtask

  virtual task apply_reset();
    vif.rstn <= 0;
    $display("apply_reset vif.rstn:%0b", vif.rstn);
    repeat(5) @(posedge vif.clk);
    $display("apply_reset vif.rstn:%0b", vif.rstn);
    vif.rstn <= 1;
    repeat(10) @(posedge vif.clk);
    $display("apply_reset vif.rstn:%0b", vif.rstn);
  endtask
endclass

module tb;
    reg clk = 0;
    always #10 clk = ~clk;
    switch_if _if(clk);

    switch u0(.clk(clk),
              .rstn(_if.rstn),
              .vld(_if.vld),
              .addr(_if.addr),
              .data(_if.data),
              .addr_a(_if.addr_a),
              .data_a(_if.data_a),
              .addr_b(_if.addr_b),
              .data_b(_if.data_b)
               );
    initial begin
        $display("tb_start");
        uvm_config_db #(virtual switch_if)::set (null, "uvm_test_top", "switch_if", _if);
        run_test("test");
        $display("tb_end");
    end

    initial begin
      $dumpvars;
      $dumpfile("dump.vcd");
    end
endmodule