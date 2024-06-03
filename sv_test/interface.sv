interface busInterface(input clk);
    logic [7:0] data;
    logic enable;

    modport TB(input data, clk, output enable);
    modport DUT(input enable, clk, output data);
endinterface

module dut(busInterface busIf);
    always @(posedge busIf.clk) begin
        if (busIf.enable)
            busIf.data <= busIf.data+1;
        else
            busIf.data <=0;
    end
endmodule

module tb;
    bit clk;
    always #1 clk = ~clk;

    busInterface busIf(clk);

    dut dut0(busIf.DUT);

    initial begin
        clk = 0;
        busIf.enable=0;
        #4 busIf.data=8'h1; busIf.enable =1;
        #4 busIf.enable=0;
        #4 busIf.data=8'h2; busIf.enable =1;
        #50 $finish;
    end
endmodule