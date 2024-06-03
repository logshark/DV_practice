module tb();
    bit [7:0] bit_array;
    bit bit_a;
    bit bit_b;

    initial begin
        $display("11time:%0d bit_array:%0b bit_a:%0b bit_b:",$time, bit_array, bit_a, bit_b);
        bit_array = 8'hFF;
        bit_a = 1'b0;
        bit_b = 1'b1;
        $display("12time:%0d bit_array:%0b bit_a:%0b bit_b:",$time, bit_array, bit_a, bit_b);
        #1
        bit_array = 8'b000100xz;
        $display("13time:%0d bit_array:%0b bit_a:%0b bit_b:",$time, bit_array, bit_a, bit_b);
        // $display("1inta:%0d",inta);
        // $finish;
    end

    initial begin
        $display("21time:%0d bit_array:%0b bit_a:%0b bit_b:",$time, bit_array, bit_a, bit_b);
        bit_array = 8'hFF;
        bit_a = 1'b0;
        bit_b = 1'b1;
        $display("22time:%0d bit_array:%0b bit_a:%0b bit_b:",$time, bit_array, bit_a, bit_b);
        #1
        bit_array = 8'b000100xz;
        $display("23time:%0d bit_array:%0b bit_a:%0b bit_b:",$time, bit_array, bit_a, bit_b);
        // $display("2inta:%0d",inta);
        // $finish;
    end

endmodule