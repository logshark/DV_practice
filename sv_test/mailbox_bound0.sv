module tb();
    mailbox mbx = new(1);

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

// # t:3 put 0
// # t:5 get 0
// # t:6 put 1
// # t:10 get 1
// # t:10 put 2
// # t:15 get 2
// # t:15 put 3
// # t:20 get 3
// # t:20 put 4
// # t:25 get 4
// #  quit -f