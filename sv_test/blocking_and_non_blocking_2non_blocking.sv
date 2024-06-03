module tb;
    reg [7:0] a, b, c, d, e;

    initial begin
      a <= 8'hAA;
      $display ("1 t:%0d a:0x%x b:0x%x c:0x%x", $time, a, b, c);
      b <= 8'hBB;
      $display ("2 t:%0d a:0x%x b:0x%x c:0x%x", $time, a, b, c);
      c <= 8'hCC;
      $display ("3 t:%0d a:0x%x b:0x%x c:0x%x", $time, a, b, c);
      #1
      $display ("#1 t:%0d a:0x%x b:0x%x c:0x%x", $time, a, b, c);
    end

    initial begin
      d <= 8'hDD;
      $display ("4 t:%0d d:0x%x e:0x%x", $time, d, e);
      e <= 8'hEE;
      $display ("5 t:%0d d:0x%x e:0x%x", $time, d, e);
      #1
      $display ("#1 t:%0d d:0x%x e:0x%x", $time, d, e);
    end
endmodule