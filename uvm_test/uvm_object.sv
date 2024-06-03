import uvm_pkg::*;

`include "uvm_macros.svh"

// class my_obj extends uvm_object;

//     // `uvm_object_utils (my_obj)

//     virtual function uvm_object create(string name="my_obj");
//         uvm_object obj;
//         obj = new(name);
//         return obj;
//     endfunction

// 	static function string type_name();
// 		return "my_obj";
// 	endfunction

// 	virtual function string get_type_name();
// 		return type_name;
// 	endfunction

// endclass


class my_obj extends uvm_object;

    `uvm_object_utils(my_obj)

	function new(string name = "my_obj");
		super.new(name);
	endfunction


endclass

class ABC extends uvm_object;
	`uvm_object_utils(ABC)

	function new(string name = "ABC");
		super.new(name);
	endfunction
endclass


class base_test extends uvm_test;
	`uvm_component_utils(base_test)

	function new(string name = "base_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);

		// An object of class "ABC" is instantiated in UVM by calling
		// its "create()" function which has been defined using a macro
		// as shown above
		ABC abc = ABC::type_id::create("abc_inst");
	endfunction
endclass



class base_obj extends uvm_object;
	function new(string name = "base_obj");
		super.new(name);
		$display("base_obj new name %s", name);
	endfunction
endclass

class base_obj2 extends base_obj;
	// function new(string name = "base_obj2");
	// 	super.new(name);
	// 	$display("base_obj2 new name %s", name);
	// endfunction
endclass

class A;
	virtual function print();
		$display("aaa");
	endfunction
endclass

class B extends A;
	function print();
		$display("bbb");
	endfunction
endclass

class C;
	function print();
		$display("ccc");
	endfunction
endclass

class D extends C;
	function print();
		$display("ddd");
	endfunction
endclass


module tb;
    // my_obj obj;
	base_obj obj;
	A a;
	B b;

	C c;
	D d;


	// base_obj2 obj2;
    initial begin
		b = new();
		// b.print();

		a = b;
		a.print();

		d = new();
		d.print();


		$display("tb");
		obj = new("obj");
        // obj2 = new("obj2");

        // obj = new();
        $display("tb_end");
    end
endmodule