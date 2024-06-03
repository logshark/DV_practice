class rand_cls;
    rand bit[1:0] mode;
    rand bit[2:0] rand_val;

    constraint c_rand_val { if (mode == 2)
                                rand_val == 3;}
endclass

module tb;
    rand_cls rand_pkg;

    initial begin
        rand_pkg = new();
        for (int i = 0; i < 20; i++) begin
            rand_pkg.randomize();
            $display("mode:%0d, rand_val:%0d", rand_pkg.mode, rand_pkg.rand_val);
        end
    end
endmodule

// ramdon到的機率變低
// # KERNEL: mode:1, rand_val:1
// # KERNEL: mode:0, rand_val:5
// # KERNEL: mode:1, rand_val:3
// # KERNEL: mode:1, rand_val:5
// # KERNEL: mode:3, rand_val:6
// # KERNEL: mode:1, rand_val:2
// # KERNEL: mode:0, rand_val:3
// # KERNEL: mode:0, rand_val:1
// # KERNEL: mode:3, rand_val:7
// # KERNEL: mode:3, rand_val:4
// # KERNEL: mode:1, rand_val:7
// # KERNEL: mode:0, rand_val:2
// # KERNEL: mode:2, rand_val:3
// # KERNEL: mode:1, rand_val:1
// # KERNEL: mode:3, rand_val:2
// # KERNEL: mode:1, rand_val:5
// # KERNEL: mode:3, rand_val:6
// # KERNEL: mode:0, rand_val:4
// # KERNEL: mode:0, rand_val:1
// # KERNEL: mode:0, rand_val:7