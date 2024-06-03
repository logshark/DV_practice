class sender;
    mailbox mbx;

    task send();
        for( int i = 0; i < 5; i++) begin
            #3 mbx.put(i);
            $display("t:%0d sender put %0d", $time(), i);
        end
    endtask
endclass

class receiver;
    mailbox mbx;

    task receive();
        forever begin
            automatic int i;
            #5 mbx.get(i);
            $display("t:%0d receiver get %s", $time(), i);
        end
    endtask
endclass

module tb();
    mailbox mbx = new();
    sender sender = new();
    receiver receiver = new();

    initial begin
        sender.mbx = mbx;
        receiver.mbx = mbx;
        sender.send();
        receiver.receive();
    end
endmodule
