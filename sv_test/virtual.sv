class BaseA;
    virtual function void printA();
        $display("BaseA virtual function print A");
    endfunction

    function void printAA();
        $display("BaseA non-virtual function print AA");
    endfunction

    virtual task printTaskA();
        $display("BaseA virtual task print A");
    endtask

    task printTaskAA();
        $display("BaseA non-virtual task print AA");
    endtask
endclass

class ChildA extends BaseA;

    virtual function void printA();
        $display("ChildA virtual function print A");
    endfunction

    function void printAA();
        $display("ChildA non-virtual function print AA");
    endfunction

    virtual task printTaskA();
        $display("ChildA virtual task print A");
    endtask

    task printTaskAA();
        $display("ChildA non-virtual task print AA");
    endtask
endclass


module tb;
    BaseA base_a;
    ChildA child_a;

    initial begin
        $display("start");
        child_a = new();
        $display("start print base_a = child_a");
        base_a = child_a;
        base_a.printA();
        base_a.printAA();
        $display("start task");
        base_a.printTaskA();
        base_a.printTaskAA();
    end

endmodule