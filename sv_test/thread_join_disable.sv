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

        $display("t:%0d finished", $time);

        disable fork;
    end
endmodule

// # run 10000
// # t:5 started
// # t:10 thread2-step1
// # t:10 thread3-step1
// # t:10 finished
// #  quit -f