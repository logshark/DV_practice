import uvm_pkg::*;
`include "uvm_macros.svh"

`define ADDR_WIDTH 8
`define DATA_WIDTH 16
`define DEPTH 256

module reg_ctrl
  # (
     parameter ADDR_WIDTH 	= 8,
     parameter DATA_WIDTH 	= 16,
     parameter DEPTH 		    = 256,
     parameter RESET_VAL  	= 16'h1234
  )
  ( input clk,
  	input rstn,
    input [ADDR_WIDTH-1:0] 	addr,
    input sel,
  	input wr,
    input [DATA_WIDTH-1:0] 	wdata,
    output reg [DATA_WIDTH-1:0] 	rdata,
    output reg ready);

  reg [DATA_WIDTH-1:0] ctrl [DEPTH];
  reg  ready_dly;
  wire ready_pe;

  always @ (posedge clk) begin
    if (!rstn) begin
      for (int i = 0; i < DEPTH; i += 1) begin
        ctrl[i] <= RESET_VAL;
      end
    end else begin
    	if (sel & ready & wr) begin
      		ctrl[addr] <= wdata;
    	end

    	if (sel & ready & !wr) begin
          rdata <= ctrl[addr];
  		end else begin
          rdata <= 0;
        end
    end
  end

  always @ (posedge clk) begin
    if (!rstn) begin
      ready <= 1;
    end else begin
      if (sel & ready_pe) begin
      	ready <= 1;
      end
	 if (sel & ready & !wr) begin
       ready <= 0;
     end
    end
  end

  always @ (posedge clk) begin
    if (!rstn) ready_dly <= 1;
   	else ready_dly <= ready;
  end

  assign ready_pe = ~ready & ready_dly;
endmodule

interface reg_if (input bit clk);
    logic rstn;
    logic [7:0] addr;
    logic [15:0] wdata;
    logic [15:0] rdata;
    logic wr;
    logic sel;
    logic ready;
endinterface

class reg_item extends uvm_sequence_item;
    bit [`ADDR_WIDTH-1:0] addr;
    bit [`DATA_WIDTH-1:0] wdata;
    bit wr;
    bit [`DATA_WIDTH-1:0] rdata;

    `uvm_object_utils_begin(reg_item)
        `uvm_field_int(addr, UVM_DEFAULT)
        `uvm_field_int(wdata, UVM_DEFAULT)
        `uvm_field_int(wr, UVM_DEFAULT)
        `uvm_field_int(rdata, UVM_DEFAULT)
    `uvm_object_utils_end

    virtual function string convert2str();
        return $sformatf("addr=0x%0h wr=0x%0h wdata=0x%0h rdata=0x%0h", addr, wr, wdata, rdata);
    endfunction

    function new(string name = "reg_item");
        super.new(name);
    endfunction
endclass

class driver extends uvm_driver#(reg_item);
    `uvm_component_utils(driver)
    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual reg_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual reg_if)::get(this, "", "reg_if", vif))
            `uvm_fatal("DRV", "Could NOT get vif");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            reg_item m_item;
            `uvm_info("DRV", $sformatf("wait for item from sequencer"), UVM_LOW);
            seq_item_port.get_next_item(m_item);
            drive_item(m_item);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_item(reg_item m_item);
        vif.sel <= 1;
        vif.addr <= m_item.addr;
        vif.wr <= m_item.wr;
        vif.wdata <= m_item.wdata;
        @(posedge vif.clk);
        while (!vif.ready) begin
            `uvm_info("DRV", "wait until ready is high", UVM_LOW)
            @(posedge vif.clk);
        end

        vif.sel <= 0;
    endtask
endclass


class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)
    function new(string name = "Monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(reg_item) mon_analysis_port;
    virtual reg_if vif;
    semaphore sema4;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual reg_if)::get(this, "", "reg_if", vif)) begin
          `uvm_fatal("MON", "Could not get vif");
        end
        else begin
            `uvm_info("MON", "Could get vif", UVM_LOW);
        end
        sema4 = new(1);
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
          @ (posedge vif.clk);
          if (vif.sel) begin
            reg_item item = new;
            item.addr = vif.addr;
            item.wr = vif.wr;
            item.wdata = vif.wdata;

            if (!vif.wr) begin
              @(posedge vif.clk);
              item.rdata = vif.rdata;
            end
            `uvm_info(get_type_name(), $sformatf("Monitor found packet %s", item.convert2str()), UVM_LOW)
            mon_analysis_port.write(item);
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
  uvm_sequencer #(reg_item) s0;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m0 = monitor::type_id::create("m0", this);
    d0 = driver::type_id::create("d0", this);
    s0 = uvm_sequencer#(reg_item)::type_id::create("s0", this);
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

  reg_item refq[`DEPTH];
  uvm_analysis_imp #(reg_item, scoreboard) m_analysis_imp;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function write(reg_item item);
    if (item.wr) begin
      if (refq[item.addr] == null)
        refq[item.addr] = new();

      refq[item.addr] = item;
      `uvm_info(get_type_name(), $sformatf("store addr=0x%0h wr=0x%0h data=0x%0h", item.addr, item.wr, item.wdata), UVM_LOW);
    end

    if (!item.wr) begin
      if (refq[item.addr] == null) begin
        if (item.rdata != 'h1234) begin
          `uvm_error(get_type_name(), $sformatf("first read addr=0x%0h exp=0x1234h act=0x%0h", item.addr, item.rdata));
        end
        else begin
          `uvm_info(get_type_name(), $sformatf("PASS! first read addr=0x%0h exp=0x1234h act=0x%0h", item.addr, item.rdata), UVM_LOW);
        end
      end
      else begin
        if (item.rdata != refq[item.addr].wdata) begin
          `uvm_error(get_type_name(), $sformatf("read addr=0x%0h exp=0x%0h act=0x%0h", item.addr, refq[item.addr].wdata, item.rdata));
        end
        else begin
          `uvm_info(get_type_name(), $sformatf("PASS! read addr=0x%0h exp=0x%0h act=0x%0h", item.addr, refq[item.addr].wdata, item.rdata), UVM_LOW);
        end
      end
    end
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

  int num = 1;

  virtual task body();

    for (int i = 0; i < 5; i++) begin
      reg_item m_item = reg_item::type_id::create("m_item");
      start_item(m_item);
      m_item.addr = i;
      m_item.wr = 0;
      m_item.wdata = $random;
      m_item.rdata = $random;

      `uvm_info("SEQ", $sformatf("Generate1 new item: "), UVM_LOW)
      m_item.print();
      finish_item(m_item);
    end

    for (int i = 0; i < num; i++) begin
      reg_item m_item = reg_item::type_id::create("m_item");
      start_item(m_item);
      m_item.addr = i;
      m_item.wr = 1;
      m_item.wdata = $random;
      m_item.rdata = $random;

      `uvm_info("SEQ", $sformatf("Generate2 new item: "), UVM_LOW)
      m_item.print();
      finish_item(m_item);
    end

    for (int i = 0; i < num; i++) begin
      reg_item m_item = reg_item::type_id::create("m_item");
      start_item(m_item);
      m_item.addr = i;
      m_item.wr = 0;
      m_item.wdata = $random;
      m_item.rdata = $random;

      `uvm_info("SEQ", $sformatf("Generate3 new item: "), UVM_LOW)
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
  virtual reg_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e0 = env::type_id::create("e0", this);
    if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_if", vif))
      `uvm_fatal("TEST", "Did not get vif")

    uvm_config_db#(virtual reg_if)::set(this, "e0.a0.*", "reg_if", vif);
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
    seq.start(e0.a0.s0);
    #10000
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
    reg_if _if(clk);

    reg_ctrl u0(.clk(clk),
                .rstn(_if.rstn),
                .addr(_if.addr),
                .sel(_if.sel),
                .wr(_if.wr),
                .wdata(_if.wdata),
                .rdata(_if.rdata),
                .ready(_if.ready)
               );
    initial begin
        $display("tb_start");
        uvm_config_db #(virtual reg_if)::set (null, "uvm_test_top", "reg_if", _if);
        run_test("test");
        $display("tb_end");
    end
endmodule
