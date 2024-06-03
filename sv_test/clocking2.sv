interface _if (input bit clk);
  logic gnt;
  logic req;

  clocking cb @(posedge clk);
    input #1ns gnt;
    output #2  req;
  endclocking
endinterface

module des (input req, clk, output reg gnt);
  always @ (posedge clk)
    if (req)
      gnt <= 1;
  	else
      gnt <= 0;
endmodule

module tb;
  bit clk;

  // Create a clock and initialize input signal
  always #10 clk = ~clk;
  initial begin
    clk <= 0;
    if0.cb.req <= 0; // locking block output if0.cb.req is not legal in this or another expression.
    // if0.cb.gnt <= 0;
  end

  // Instantiate the interface
  _if if0 (.clk (clk));

  // Instantiate the design
  des d0 ( .clk (clk),
           .req (if0.req),
           .gnt (if0.gnt));

  // Drive stimulus
  initial begin
    for (int i = 0; i < 10; i++) begin
    //   automatic bit[3:0] delay = $random;
      // automatic bit[3:0] delay = i;
      // repeat (delay) @(posedge if0.clk);
      #3
      if0.cb.req <= ~ if0.cb.req;
      $display("t:%0d, req:%b", $time(), if0.cb.req);
    end
    #200 $finish;
  end
endmodule