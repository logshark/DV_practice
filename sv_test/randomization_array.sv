class cls;
    rand bit [3:0] arr[];
    rand bit [3:0] queue[$];

    constraint c_arr { arr.size() > 3; arr.size() < 5;}
    constraint c_queue { queue.size() == 4;}
endclass

module tb;
    cls rand_pkg;

    initial begin
        rand_pkg = new();
        rand_pkg.randomize();
        for (int i = 0; i < rand_pkg.arr.size(); i++) begin
          $display("arr[%0d] value:%0h", i, rand_pkg.arr[i]);
        end

        $display("arr: %p", rand_pkg.arr);
        $display("Queue: %p", rand_pkg.queue);
    end
endmodule
// random的array size 限制>3 <5 所以是4
// # KERNEL: arr[0] value:5
// # KERNEL: arr[1] value:3
// # KERNEL: arr[2] value:4
// # KERNEL: arr[3] value:f
// # KERNEL: arr: '{5, 3, 4, 15}
// # KERNEL: Queue: '{13, 11, 8, 7}