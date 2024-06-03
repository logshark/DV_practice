interface _if(input bit clk);
  bit [7:0] sig1_input;
  bit [7:0] sig2_output;

  clocking cb @(posedge clk);
    input #1 sig1_input;
    output #2 sig2_output;
  endclocking
endinterface

module tb;

  bit clk;
  always #3 clk = ~clk;

  _if if0(clk);

  initial begin
    clk <=0;
    if0.sig1_input = 8'h12;
    if0.cb.sig2_output <= 8'h34;
    $display("sig1_input:%0h", if0.cb.sig1_input);
    @if0.cb;
    if0.sig1_input = 8'h56;
    if0.cb.sig2_output <= 8'h78;
    #1
    if0.cb.sig2_output <= 8'hAA;
    $display("sig1_input:%0h", if0.cb.sig1_input);
    @if0.cb;
    if0.sig1_input = 8'h9A;
    if0.cb.sig2_output <= 8'hBC;
    #1
    if0.cb.sig2_output <= 8'hDD;
    $display("sig1_input:%0h", if0.cb.sig1_input);

    #100 $finish();
  end
endmodule