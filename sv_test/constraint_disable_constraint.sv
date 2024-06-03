class rand_cls;
    rand bit[2:0] rand_val;

    constraint c_rand_val {rand_val == 1;}
endclass

module tb;
    rand_cls rand_pkg;

    initial begin
        rand_pkg = new();

        $display("default constraint_mode:%0d", rand_pkg.c_rand_val.constraint_mode());
        for (int i = 0; i < 10; i++) begin
            rand_pkg.randomize();
            $display("rand_val:%0d", rand_pkg.rand_val);
        end

        $display("disable constraint mode");
        rand_pkg.c_rand_val.constraint_mode(0);
        $display("constraint_mode:%0d", rand_pkg.c_rand_val.constraint_mode());

        for (int i = 0; i < 10; i++) begin
            rand_pkg.randomize();
            $display("rand_val:%0d", rand_pkg.rand_val);
        end
    end
endmodule

// # KERNEL: default constraint_mode:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: rand_val:1
// # KERNEL: disable constraint mode
// # KERNEL: constraint_mode:0
// # KERNEL: rand_val:6
// # KERNEL: rand_val:5
// # KERNEL: rand_val:3
// # KERNEL: rand_val:4
// # KERNEL: rand_val:7
// # KERNEL: rand_val:5
// # KERNEL: rand_val:3
// # KERNEL: rand_val:0
// # KERNEL: rand_val:7
// # KERNEL: rand_val:0