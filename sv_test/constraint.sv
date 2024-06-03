class rand_cls;
    rand bit[2:0] rand_val;

    constraint c_rand_val;

    function display_val();
        $display("rand_val:%0d", rand_val);
        return 0;
    endfunction
endclass

constraint rand_cls::c_rand_val { rand_val <= 3; }

module tb;
    rand_cls rand_pkg;

    initial begin
        rand_pkg = new();
        for (int i = 0; i < 10; i++) begin
            rand_pkg.randomize();
            rand_pkg.display_val();
        end
    end
endmodule

// # KERNEL: rand_val:3
// # KERNEL: rand_val:2
// # KERNEL: rand_val:1
// # KERNEL: rand_val:2
// # KERNEL: rand_val:3
// # KERNEL: rand_val:2
// # KERNEL: rand_val:1
// # KERNEL: rand_val:0
// # KERNEL: rand_val:3
// # KERNEL: rand_val:0