
parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 16;
parameter ADDR_DIV = 8'h3F;

// Design
module switch
  ( input clk,
   	input rstn,
    input vld,

    input [ADDR_WIDTH-1:0] 	addr,
    input [DATA_WIDTH-1:0] 	data,

    output reg [ADDR_WIDTH-1:0] 	addr_a,
    output reg [DATA_WIDTH-1:0] 	data_a,

    output reg [ADDR_WIDTH-1:0] 	addr_b,
    output reg [DATA_WIDTH-1:0] 	data_b
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
            $display ("1[design] T:%0t addr:0x%0h data:0x%0h addr_a:0x%0h data_a:0x%0h addr_b:0x%0h data_b:0x%0h",
              	$time, addr, data, addr_a, data_a, addr_b, data_b);
      	  end
        else begin
          	addr_a <= 0;
          	data_a <= 0;
          	addr_b <= addr;
        	  data_b <= data;
            $display ("2[design] T:%0t addr:0x%0h data:0x%0h addr_a:0x%0h data_a:0x%0h addr_b:0x%0h data_b:0x%0h",
              	$time, addr, data, addr_a, data_a, addr_b, data_b);
      	  end
        end
    end
  end
endmodule


// Transaction Object
class switch_item;
  bit[ADDR_WIDTH-1:0] addr;
  bit[DATA_WIDTH-1:0] data;

  bit [ADDR_WIDTH-1:0] addr_a;
  bit [DATA_WIDTH-1:0] data_a;
  bit [ADDR_WIDTH-1:0] addr_b;
  bit [DATA_WIDTH-1:0] data_b;

  function void rand_val();
    this.addr = $urandom_range(0, (2**ADDR_WIDTH)-1);
    this.addr = (this.addr/8)*8;
    this.data = $urandom_range(0, (2**DATA_WIDTH)-1);
  endfunction

  function void display_val(string tag = "");
    $display ("[transaction] T:%0t %s addr:0x%0h data:0x%0h addr_a:0x%0h data_a:0x%0h addr_b:0x%0h data_b:0x%0h",
              	$time, tag, addr, data, addr_a, data_a, addr_b, data_b);
  endfunction
endclass

interface switch_if(input bit clk);
   	logic rstn;
    logic vld;

    logic [ADDR_WIDTH-1:0] 	addr;
    logic [DATA_WIDTH-1:0] 	data;

    logic [ADDR_WIDTH-1:0] 	addr_a;
    logic [DATA_WIDTH-1:0] 	data_a;

    logic [ADDR_WIDTH-1:0] 	addr_b;
    logic [DATA_WIDTH-1:0] 	data_b;
endinterface

class generator;
  mailbox mbx;
  event drv_event;
  function new(mailbox mbx, event drv_event);
    this.mbx = mbx;
    this.drv_event = drv_event;
  endfunction

  task run();
    $display("generator running");
    for (int i = 0; i < 20; i++) begin
      switch_item item = new();
      item.rand_val();
      item.display_val();
      mbx.put(item);
      @(drv_event);
    end

    $display("generator done");
  endtask
endclass

class driver;
  mailbox mbx;
  event drv_event;
  virtual switch_if vif;

  function new(mailbox mbx, event drv_event);
    this.mbx = mbx;
    this.drv_event = drv_event;
  endfunction

  task run();
    $display("driver running");
    // @(posedge vif.clk);

    $display("drv detect clk rising");
    forever begin
      switch_item item;
      @(posedge vif.clk);
      mbx.get(item);
      item.display_val("driver");
      vif.addr <= item.addr;
      vif.data <= item.data;
      vif.vld <= 1;
      $display("t:%0t drv detect clk rising", $time());
      ->drv_event;

      // @(negedge vif.clk);
      #1
      vif.vld <= 0;

      #1
      vif.vld <= 1;
    end
  endtask
endclass

class scoreboard;
  mailbox mbx;
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction

  task run();
    $display("scoreboard running");
    forever begin
      switch_item item;
      mbx.get(item);

      if (item.addr inside {[0:'h3f]}) begin
        if (item.addr_a != item.addr | item.data_a != item.data)
          $display ("T:%0t [scoreboard] ERROR addr:0x%0h data:0x%0h addr_a:0x%0h data_a:0x%0h", $time, item.addr, item.data, item.addr_a, item.data_a);
        else
          $display ("T:%0t [scoreboard] PASS  addr:0x%0h data:0x%0h addr_a:0x%0h data_a:0x%0h", $time, item.addr, item.data, item.addr_a, item.data_a);
      end
      else begin
        if (item.addr_b != item.addr | item.data_b != item.data)
          $display ("T:%0t [scoreboard] ERROR addr:0x%0h data:0x%0h addr_b:0x%0h data_b:0x%0h", $time, item.addr, item.data, item.addr_b, item.data_b);
        else
          $display ("T:%0t [scoreboard] PASS  addr:0x%0h data:0x%0h addr_b:0x%0h data_b:0x%0h", $time, item.addr, item.data, item.addr_b, item.data_b);
      end
    end
  endtask
endclass

class monitor;
  mailbox mbx;
  virtual switch_if vif;
  semaphore sema4;

  function new(mailbox mbx);
    this.mbx = mbx;
    sema4 = new(1);
  endfunction

  task run();
    $display("t:%0t monitor running", $time);
    forever begin
      switch_item item;
      @(posedge vif.clk);
      if (vif.clk && vif.vld) begin
        item = new();
        item.addr = vif.addr;
        item.data = vif.data;

        @(posedge vif.clk);
        item.addr_a = vif.addr_a;
        item.data_a = vif.data_a;
        item.addr_b = vif.addr_b;
        item.data_b = vif.data_b;
        mbx.put(item);
        $display ("T=%0t monitor put data to scoreboard", $time);
      end
    end
  endtask
endclass

class environment;

  driver     driver0;
  generator  generator0;
  event      drv_event;

  monitor    monitor0;
  scoreboard scoreboard0;

  mailbox    drv_mbx;
  mailbox    scb_mbx;

  virtual switch_if vif; 	// Virtual interface handle

  function new();
      drv_mbx = new();
      scb_mbx = new();

      driver0 = new(drv_mbx, drv_event);
      generator0 = new(drv_mbx, drv_event);

      monitor0 = new(scb_mbx);
      scoreboard0 = new(scb_mbx);
  endfunction

  task run();
      $display("env running");
      monitor0.vif = vif;
      driver0.vif = vif;

      fork
        driver0.run();
        generator0.run();
        monitor0.run();
        scoreboard0.run();
      join
  endtask
endclass

class test;
  environment env0;

  function new();
      env0 = new();
  endfunction

  task run();
      $display("test running");
      env0.run();
  endtask
endclass


// TB top
module tb;
  // switch_item item;
  bit clk;
  always #10 clk = ~clk;

  switch_if if0(clk);
  switch dut( .clk(if0.clk),
              .rstn(if0.rstn),
              .vld(if0.vld),
              .addr(if0.addr),
              .data(if0.data),
              .addr_a(if0.addr_a),
              .data_a(if0.data_a),
              .addr_b(if0.addr_b),
              .data_b(if0.data_b));
  test t0;

  int i = 0;

  switch_item item;

  initial begin
    $display("tb top running");
    clk <= 0;
    if0.rstn <= 1;
    t0 = new();
    t0.env0.vif = if0; // important
    t0.run();
    #10 if0.rstn <= 1;

    $display("tb top finished");
    #200 $finish();
  end
endmodule