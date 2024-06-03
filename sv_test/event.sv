module tb();

    event evt;

    initial begin
        #10
        ->evt;
        $display("1 t:%0t event triggered", $time);
    end

    initial begin
        $display("2 t:%0t start to polling event", $time);
        #10
        @evt;
        // wait(evt.triggered);
        $display("2 t:%0t reveived event trigger", $time);
    end

    initial begin
        $display("3 t:%0t start to polling event", $time);
        #10
        // @evt;
        wait(evt.triggered);
        $display("3 t:%0t reveived event trigger", $time);
    end
endmodule