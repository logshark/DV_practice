module tb();

    initial counter();
    initial counter();
    initial counter();
    initial counter_auto();
    initial counter_auto();
    initial counter_auto();

    task counter();
        // integer i = 0; //  .\task2.sv(11): (vlog-2244) Variable 'i' is implicitly static. You must either explicitly declare it as static or automatic or remove the initialization in the declaration of variable.
        automatic integer i = 0;
        i = i + 1;
        $display("time:%0d, i:%0d",$time(), i);
    endtask

    task automatic counter_auto();
        integer i = 0;
        i = i + 1;
        $display("time:%0d, i:%0d",$time(), i);
    endtask

endmodule