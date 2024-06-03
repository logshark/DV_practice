module tb_top();

  reg r;
  wire w;
  integer i;
  real re;
  time t;
  realtime rt;
  logic log;
  bit ba;
  byte bb;

  initial begin
    r = 1;
    // w = 0;
    i = 123;
    re = 123456789.12;
    t = $time;
    rt = 123456789.56;
    log = 0;
  end

  initial begin
    $display("reg = %d", r);
    $display("integer i = %d", i);
    $display("real = %f", re);
    $display("time = %f", t);
    #20 t = $time;
    $display("time = %f", t);
    $display("realtime = %f", rt);
    $finish;
  end

endmodule