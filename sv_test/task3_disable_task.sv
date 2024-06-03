module tb;

    initial begin
        $display("t:%0t Start disable task block", $time);
        #5 disable display.BLOCK_1;
        $display("t:%0t End disable task block", $time);

        $display("t:%0t Start disable task", $time);
        #15 disable display;
        $display("t:%0t End disable task", $time);
    end

    initial display();

    task display();
        begin: BLOCK_1
            $display("t:%0t BLOCK_1 start", $time);
            #10;
            $display("t:%0t BLOCK_1 end", $time);
        end

        begin: BLOCK_2
            #10;
            $display("t:%0t BLOCK_2 start", $time);
            #10;
            $display("t:%0t BLOCK_2 end", $time);
        end

        begin: BLOCK_3
            #10;
            $display("t:%0t BLOCK_3 start", $time);
            #10;
            $display("t:%0t BLOCK_3 end", $time);
        end
    endtask
endmodule