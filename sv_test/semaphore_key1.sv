module tb();
    semaphore key = new(1);

    initial begin
        fork
            customerA();
            customerB();
        join
    end

    task customerA();
        getRoom(1);
        #5
        rtnRoom(1);
    endtask

    task customerB();
        getRoom(2);
        #10
        rtnRoom(2);
    endtask

    task getRoom(bit[0:1] id);
        $display("t:%0d start  get room id:%0d", $time, id);
        key.get();
        $display("t:%0d finish get room id:%0d", $time, id);
    endtask

    task rtnRoom(bit[0:1] id);
        $display("t:%0d start  return room id:%0d", $time, id);
        key.put();
        $display("t:%0d finish return room id:%0d", $time, id);
    endtask
endmodule

// output:
// # run 10000
// # t:0 start  get room id:1
// # t:0 finish get room id:1
// # t:0 start  get room id:2
// # t:5 start  return room id:1
// # t:5 finish return room id:1
// # t:5 finish get room id:2
// # t:15 start  return room id:2
// # t:15 finish return room id:2
// #  quit -f