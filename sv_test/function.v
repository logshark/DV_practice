module tb();

    reg[7:0] result;

    function reg[7:0] sum(input  reg[7:0] a, input reg[7:0] b);
        sum = a+b;
    endfunction

    initial begin
        result = sum(3,2);
        $display("result:%0d", result);
    end

endmodule