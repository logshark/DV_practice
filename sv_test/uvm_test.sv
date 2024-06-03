import uvm_pkg::*;
// `include "uvm_macros.svh"

// class my_sequence extends uvm_sequence();
//   environment env0;

//   function new();
//     // MUST BE SET when using ModelSim
//     do_not_randomize = 1'b1;
//   endfunction

//   task run();
//       $display("test running");
//   endtask
// endclass


// TB top
module tb;
  // switch_item item;
  bit clk;
  always #10 clk = ~clk;

  // my_sequence my_seq;

  initial begin
    $display("tb top running");
    // my_seq = new();

    $display("tb top finished");
    #200 $finish();
  end
endmodule