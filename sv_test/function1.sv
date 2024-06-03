module tb();

    // int result;
    int inputa;
    int inputb;
    int res;

    function int sum1(int a, int b);
        return a+b;
    endfunction

    function int sum2(int a, int b);
        sum2=a+b;
    endfunction

    function sum3(int a, int b);
        sum3=a+b;
    endfunction

    function int sum4;
        input int a, b;
        // output sum4; // Error (suppressible): .\function1.sv(21): (vlog-2388) 'sum4' already declared in this scope (sum4) at .\function1.sv(19).
        sum4=a+b;
    endfunction

    function int sum5(input int a, b, output int res);
      	res = a+b+1;
    	return a + b;
    endfunction

    initial begin
        inputa=3;
        inputb=3;
        // result = sum1(inputa, inputb);
        $display("sum1:%0d", sum1(inputa, inputb));
        $display("sum2:%0d", sum2(inputa, inputb));
        $display("sum3:%0d", sum3(inputa, inputb)); // output is 0
        $display("sum4:%0d", sum4(inputa, inputb));

        $display("sum5:%0d", sum5(inputa, inputb, res));
        $display("res:%0d", res);

        $display("inputa:%0d", inputa);
        $display("inputb:%0d", inputb);
    end
endmodule