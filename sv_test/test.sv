
  class aaa;
    function new(string str);
      $display(str);
    endfunction
  endclass // a


module tb;
  real  pi;        // Declared to be of type real
  real  freq;


  reg A;
  wire B;
  // class fuckiverilog;
  //   rand int a;
  //   constraint fuck {
  //       a > 100;
  //   }
  //   function void fk(const ref f);
  //   endfunction

  // endclass

  aaa cls_a;


  initial begin
    cls_a = new("yaaaakfsjaklfjldsaaa");
    $dumpfile("inverter.vcd");
    $dumpvars(0,tb);

    pi   = 3.14;    // Store floating point number
    freq = 1e6; 	// Store expjonential number

    A = 0;
    #20;

    $display ("Value of A = %d", A);

    A = 1;
    #20;
    $display ("Value of A = %d", A);

    A = 0;
    #20;
    $display ("Value of A = %d", A);



    $display ("Value of pi = %f", pi);
    $display ("Value of pi = %0.3f", pi);
    $display ("Value of freq = %0d", freq);

    $finish();
  end
endmodule