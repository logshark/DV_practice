module tb();
    mailbox mbx = new(3);

    initial begin
        for( int i = 0; i < 5; i++) begin
            #3 mbx.put(i);
            $display("t:%0d put %0d", $time(), i);
        end
    end

    initial begin
        forever begin
            automatic int i;
            #5 mbx.get(i);
            $display("t:%0d get %0d", $time(), i);
        end
    end
endmodule

// # run 10000
// # t:3 put 0
// # t:5 get 0
// # t:6 put 1
// # t:9 put 2
// # t:10 get 1
// # t:12 put 3
// # t:15 get 2
// # t:15 put 4
// # t:20 get 3
// # t:25 get 4
// #  quit -f