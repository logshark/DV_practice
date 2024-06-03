module tb;
    reg [7:0] a, b, c, d, e;

    initial begin
      a <= 8'hAA;
      $display ("1 t:%0d a:0x%x b:0x%x c:0x%x", $time, a, b, c);
      #10
      b <= 8'hBB;
      $display ("2 t:%0d a:0x%x b:0x%x c:0x%x", $time, a, b, c);
      #10
      c <= 8'hCC;
      $display ("3 t:%0d a:0x%x b:0x%x c:0x%x", $time, a, b, c);
    end

    initial begin
      d <= 8'hDD;
      #5
      $display ("4 t:%0d d:0x%x e:0x%x", $time, d, e);
      #5
      e <= 8'hEE;
      $display ("5 t:%0d d:0x%x e:0x%x", $time, d, e);
    end
endmodule