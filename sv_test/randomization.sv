class rand_cls;
    rand bit[2:0] rand_val;
    randc bit[2:0] randc_val;

    constraint c_rand_val { rand_val <= 3; }
    constraint c_randc_val { randc_val >= 1; randc_val <= 3; }

    function display_val();
        $display("rand_val:%0d, ranc_val:%0d", rand_val, randc_val);
        return 0;
    endfunction
endclass

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

// # rand_val:3, ranc_val:2
// # rand_val:2, ranc_val:3
// # rand_val:2, ranc_val:1
// # rand_val:0, ranc_val:3
// # rand_val:0, ranc_val:1
// # rand_val:1, ranc_val:2
// # rand_val:2, ranc_val:1
// # rand_val:0, ranc_val:2
// # rand_val:0, ranc_val:3
// # rand_val:3, ranc_val:2