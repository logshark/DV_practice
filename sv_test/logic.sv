module tb();
    logic [7:0] logic_array;
    logic logic_bit1;
    logic logic_bit2;

    assign logic_bit2 = 0;
    assign logic_bit1 = logic_array[0];

    initial begin
        $display("time:%0d logic_array:%0x logic_bit1:%0b logic_bit2:",$time, logic_array, logic_bit1, logic_bit2);
        logic_array = 8'hFF;
        $display("time:%0d logic_array:%0x logic_bit1:%0b logic_bit2:",$time, logic_array, logic_bit1, logic_bit2);
        #1
        $display("time:%0d logic_array:%0x logic_bit1:%0b logic_bit2:",$time, logic_array, logic_bit1, logic_bit2);
        $finish;
    end
endmodule