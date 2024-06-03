module tb();

    int result;
    int inputa;
    int inputb;

    // function int sum(int a, ref int b); // ** Error (suppressible): .\function2.sv(9): (vlog-2244) Variable 'sumab' is implicitly static. You must either explicitly declare it as static or automatic or remove the initialization in the declaration of variable.
    function automatic int sum(int a, ref int b);
        int sumab = a+b;
        a = a+1;
        b = b+1;
        return sumab;
    endfunction

    initial begin
        inputa=3;
        inputb=3;
        result = sum(inputa, inputb);
        $display("result:%0d", result);
        $display("inputa:%0d", inputa);
        $display("inputb:%0d", inputb);
    end
endmodule