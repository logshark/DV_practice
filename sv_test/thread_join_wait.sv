module tb;
    initial begin
        #5 $display("t:%0d started", $time);

        fork
            #20 $display("t:%0d thread1-step1", $time);

            begin
                #5 $display("t:%0d thread2-step1", $time);
                #10 $display("t:%0d thread2-step2", $time);
            end
            #5 $display("t:%0d thread3-step1", $time);

        join_any

        fork
            #20 $display("t:%0d thread4", $time);
            #100 $display("t:%0d thread5", $time);
        join_any

        $display("t:%0d wait join", $time);
        wait fork;

        $display("t:%0d finished", $time);
    end
endmodule