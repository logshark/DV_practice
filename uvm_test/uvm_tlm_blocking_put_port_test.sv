import uvm_pkg::*;
`include "uvm_macros.svh"

class packet extends uvm_object;
    bit [7:0] addr;
    bit [7:0] data;

    `uvm_object_utils_begin(packet)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "packet");
        super.new(name);
        addr = $urandom();
        data = $urandom();
    endfunction
endclass

class compA extends uvm_component;
    `uvm_component_utils(compA)
    uvm_blocking_put_port #(packet) put_port;
    int num_tx;

    function new (string name = "compA", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        put_port = new("put_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        repeat (num_tx) begin
            packet pkt = packet::type_id::create("pkt");
            
            `uvm_info("compA", "packet sent to compB", UVM_LOW)
            pkt.print (uvm_default_line_printer);
            
            put_port.put(pkt);
        end
        phase.drop_objection(this);
    endtask
endclass

class compB extends uvm_component;
    `uvm_component_utils(compB)

    uvm_blocking_put_imp #(packet, compB) put_imp;

    function new(string name = "compB", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        put_imp = new("put_imp", this);
    endfunction

    virtual task put(packet pkt);
        `uvm_info("compB", "packet received from compA", UVM_LOW)
        pkt.print(uvm_default_line_printer);
    endtask
endclass

class my_test extends uvm_test;

    `uvm_component_utils(my_test)

    compA comp_a;
    compB comp_b;

    function new(string name = "my_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        comp_a = compA::type_id::create("comp_a", this);
        comp_b = compB::type_id::create("comp_b", this);
        comp_a.num_tx = 2;
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        comp_a.put_port.connect(comp_b.put_imp);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
        // factory.print();
    endfunction

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        uvm_top.print_topology();
        // factory.print();      
    endfunction
endclass

module tb;
    // my_test test;
    
    initial begin;
        // test = new();
        $display("aaa");
        run_test("my_test");
        #50;
        $display("bbb");
    end
endmodule
