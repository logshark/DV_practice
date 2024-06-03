import uvm_pkg::*;
`include "uvm_macros.svh"

class Packet extends uvm_object;
  bit [3:0] addr;
  bit [3:0] wdata;
  bit [3:0] rdata;
  bit 		  wr;

  `uvm_object_utils_begin(Packet)
  	`uvm_field_int(addr, 	UVM_DEFAULT)
  	`uvm_field_int(wdata, UVM_DEFAULT)
  	`uvm_field_int(rdata, UVM_DEFAULT)
  	`uvm_field_int(wr,		UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "Packet");
    super.new(name);
  endfunction
endclass

class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  bit bits[];
  byte unsigned bytes[];
  int unsigned ints[];

  int val1, val2, val3;

  function void build_phase(uvm_phase phase);
    Packet pkt = Packet::type_id::create("pkt");
    Packet pkt2 = Packet::type_id::create("pkt2");
    pkt.addr = 4'hA;
    pkt.wdata = 4'hB;
    pkt.rdata = 4'hC;
    pkt.wr = 1'b1;
    pkt.print();

    pkt.pack(bits);
    pkt.pack_bytes(bytes);
    pkt.pack_ints(ints);

    `uvm_info(get_type_name(), $sformatf("bits=%p", bits), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("bytes=%p", bytes), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("ints=%p", ints), UVM_LOW)

    val1 = pkt2.unpack(bits);
    `uvm_info(get_type_name(), $sformatf("Actual number of bits unpacked from the given array. unpacked val1=0x%0h", val1), UVM_LOW)
    pkt2.print();

    val2 = pkt2.unpack_bytes(bytes);
    `uvm_info(get_type_name(), $sformatf("Actual number of bits unpacked from the given array. unpacked val2=0x%0h", val2), UVM_LOW)
    pkt2.print();

    val3 = pkt2.unpack_ints(ints);
    `uvm_info(get_type_name(), $sformatf("Actual number of bits unpacked from the given array. unpacked val3=0x%0h", val3), UVM_LOW)
    pkt2.print();

  endfunction
endclass

module tb;
  initial begin
    $display("start");
    run_test("base_test");
  end
endmodule

// # start
// # UVM_INFO @ 0: reporter [RNTST] Running test base_test...
// # ------------------------------
// # Name     Type      Size  Value
// # ------------------------------
// # pkt      Packet    -     @473
// #   addr   integral  4     'ha
// #   wdata  integral  4     'hb
// #   rdata  integral  4     'hc
// #   wr     integral  1     'h1
// # ------------------------------
// # UVM_INFO .\uvm_object_pack_unpack.sv(45) @ 0: uvm_test_top [base_test] bits='{1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1}
// # UVM_INFO .\uvm_object_pack_unpack.sv(46) @ 0: uvm_test_top [base_test] bytes='{171, 200}
// # UVM_INFO .\uvm_object_pack_unpack.sv(47) @ 0: uvm_test_top [base_test] ints='{2882011136}
// #

