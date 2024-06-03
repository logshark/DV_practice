import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum {FALSE, TRUE} e_bool;

class Object extends uvm_object;
    e_bool   bool;
    bit[3:0] bit_var;
    byte     byte_arr[4];
    int      int_queue[$];
    string   str;

    `uvm_object_utils_begin(Object)
        `uvm_field_enum(e_bool, bool, UVM_DEFAULT)
        `uvm_field_int(bit_var, UVM_DEFAULT)
        `uvm_field_sarray_int(byte_arr, UVM_DEFAULT)
        `uvm_field_queue_int(int_queue, UVM_DEFAULT)
        `uvm_field_string(str, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name = "Object");
        super.new(name);
        str = name;
        bit_var = $random;
    endfunction
endclass

// class Object extends uvm_object;
//     e_bool   bool;
//     bit[3:0] bit_var;
//     byte     byte_arr[4];
//     int      int_queue[$];
//     string   str;

//     `uvm_object_utils(Object)
//     function new(string name = "Object");
//         super.new(name);
//         str = name;
//         // bit_var = $random;
//     endfunction

//     virtual function void do_print(uvm_printer printer);
//       super.do_print(printer);
//       printer.print_string("1bool", bool.name());
//       printer.print_field("2bit_var", bit_var, $bits(bit_var), UVM_HEX);
//       printer.print_string("3str", str);
//     endfunction
// endclass

class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    Object obj = Object::type_id::create("obj");
    // obj.print();
    // obj.randomize();
    `uvm_info(get_type_name(), $sformatf("Ojbect Contents is in below:\n %s", obj.sprint()), UVM_LOW)
  endfunction
endclass

module tb;
  initial begin
    $display("start");
    run_test("base_test");
  end
endmodule


