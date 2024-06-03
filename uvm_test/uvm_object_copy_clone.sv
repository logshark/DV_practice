import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum {FALSE, TRUE} e_bool;

class Packet extends uvm_object;
    bit[31:0] addr;

    `uvm_object_utils_begin(Packet)
      `uvm_field_int(addr, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "Packet");
      super.new(name);
      addr = $random;
    endfunction
endclass

class Object extends uvm_object;
    e_bool   bool;
    bit[3:0] bit_var;
    int      int_var;
    string   str;
    Packet   pkt;

    `uvm_object_utils_begin(Object)
        `uvm_field_enum(e_bool, bool, UVM_DEFAULT)
        `uvm_field_int(bit_var, UVM_DEFAULT)
        `uvm_field_int(int_var, UVM_DEFAULT)
        `uvm_field_string(str, UVM_DEFAULT)
        `uvm_field_object(pkt, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "Object");
        super.new(name);
        str = name;
        bit_var = $random;
        int_var= $random;
        pkt = Packet::type_id::create("pkt");
    endfunction
endclass



class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    Object obj1 = Object::type_id::create("obj1");
    Object obj2;
    // Object obj2 = Object::type_id::create("obj2");
    obj1.print();
    //obj2.print();
    //obj2.copy(obj1);
    $cast(obj2, obj1.clone());
    `uvm_info("base_test", "After copy", UVM_LOW)
    obj2.print();

    if (obj2.compare(obj1))
      `uvm_info("base_test", "obj1 and obj2 are same", UVM_LOW)
    else
      `uvm_info("base_test", "obj1 and obj2 are different", UVM_LOW)
  endfunction
endclass

module tb;
  initial begin
    $display("start");
    run_test("base_test");
  end
endmodule


