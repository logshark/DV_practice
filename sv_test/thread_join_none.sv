module tb;
    initial begin
        $display("t:%0d started", $time);

        fork
            #20 $display("t:%0d thread1-step1", $time);

            begin
                #5 $display("t:%0d thread2-step1", $time);
                #10 $display("t:%0d thread2-step2", $time);
            end
            #5 $display("t:%0d thread3-step1", $time);

        join_none

        $display("t:%0d finished", $time);
    end
endmodule

// # run 10000
// # t:0 started
// # t:0 finished
// # t:5 thread2-step1
// # t:5 thread3-step1
// # t:15 thread2-step2
// # t:20 thread1-step1
// #  quit -f