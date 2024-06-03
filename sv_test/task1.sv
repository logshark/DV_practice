
// global task
task sum1(input [7:0] a, b, output [7:0] sum);
    sum = a + b;
    #1 $display("time:%0d, a:%0d, b:%0d, sum:%0d",$time(), a, b, sum);
endtask

// global task
task sum2;
    input [7:0] a, b;
    output [7:0] sum;
    begin
        sum = a + b;
    end
    #1 $display("time:%0d, a:%0d, b:%0d, sum:%0d",$time(), a, b, sum);
endtask

module testModule();
    // task in a testModule
    task sum3(input [7:0] a, b, output [7:0] sum);
        sum = a + b;
        #1 $display("time:%0d, a:%0d, b:%0d, sum:%0d",$time(), a, b, sum);
    endtask
endmodule

module tb();
    int outSum;
    testModule mod();
    task sum4(input [7:0] a, b, output [7:0] sum);
        sum = a + b;
        #1 $display("time:%0d, a:%0d, b:%0d, sum:%0d",$time(), a, b, sum);
    endtask

    initial begin
        sum1(1, 2, outSum);
        $display("time:%0d, sum1 output:%0d",$time(), outSum);

        sum2(3, 4, outSum);
        $display("time:%0d, sum2 output:%0d",$time(), outSum);

        mod.sum3(5, 6, outSum);
        $display("time:%0d, sum3 output:%0d",$time(), outSum);

        sum4(7, 8, outSum);
        $display("time:%0d, sum4 output:%0d",$time(), outSum);
    end
endmodule