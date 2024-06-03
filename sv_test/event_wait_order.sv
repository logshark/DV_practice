// ** Error: (vlog-13069) .\event_wait_order.sv(14): near "wait_order": syntax error, unexpected "SystemVerilog keyword 'wait_order'".
module tb();

    event a, b, c;

    initial begin
        #10 ->a;
        #10 ->b;
        #10 ->c;
    end


    initial begin
        wait_order (a,b,c)
            $display ("Events were executed in the correct order");
        else
            $display ("Events were NOT executed in the correct order !");
    end
endmodule