import uvm_pkg::*;
`include "uvm_macros.svh"

class base_obj extends uvm_object;
	`uvm_object_utils(base_obj)

	function new(string name = "base_obj");
		super.new(name);
		`uvm_info ("ENV", $sformatf ("test_compaaaaabbbbb"), UVM_MEDIUM)
	endfunction
endclass

class test_comp extends uvm_component;
	`uvm_component_utils(test_comp)
	function new(string name = "test_comp", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		$display("test_comp build_phase start");

		$display("test_comp build_phase end");


	endfunction
endclass

class base_env extends uvm_env;
	`uvm_component_utils(base_env)
	string name;
	test_comp test_comp1;

	function new(string name="base_env", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase (uvm_phase phase);
		// super.build_name ();
		super.build_phase(phase);
		$display("base_env build_phase");

		test_comp1 = test_comp::type_id::create("test_comp1", this);

		// Retrieve the string that was set in config_db from the test class
		if (uvm_config_db#(string)::get (null, "uvm_test_top", "Friend", name))
			`uvm_info ("ENV", $sformatf ("base_env Found %s", name), UVM_MEDIUM)
		else
			`uvm_info ("ENV", $sformatf ("base_env Not Found %s", name), UVM_MEDIUM)

		uvm_config_db#(string)::set(this, "", "TEST_STRING", "AAA");

		$display("base_env build_phase done");
	endfunction

endclass

class base_test extends uvm_test;
	`uvm_component_utils(base_test)
	function new(string name="base_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	base_env 	m_env;
	base_env 	m_env2;
	string name;

	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		$display("base_test build_phase");
		m_env = base_env::type_id::create("m_env", this);

		// Set this string into config_db
		// uvm_config_db#(string)::set (null, "uvm_test_top", "Friend", "Joey");
		// uvm_config_db#(string)::set (null, "", "Friend", "Joey");
		uvm_config_db #(string) :: set (null, "uvm_test_top", "Friend", "Joey");

		// if (uvm_config_db#(string)::get (null, "uvm_test_top", "Friend", name))
		if (uvm_config_db#(string)::get (null, "uvm_test_top.tb", "Friend", name))
			`uvm_info ("base_test", $sformatf ("aaabase_test Found %s", name), UVM_MEDIUM)
		else
			`uvm_info ("base_test", $sformatf ("aaabase_test Not Found %s", name), UVM_MEDIUM)

		m_env2 = base_env::type_id::create("m_env2", this);
		$display("base_test build_phase end");

	endfunction

	virtual task run_phase(uvm_phase phase);
		// super.run_phase(phase);
		phase.raise_objection(this);
		$display("base_test run_test");
		phase.drop_objection(this);
	endtask

	virtual function void end_of_elaboration_phase(uvm_phase phase);
    	uvm_component 	l_comp_h;
    	uvm_component 	l_comp_q [$];

		uvm_component parent_comp;
		uvm_component child_comp_q [$];
		string strT;

		$display("end of elaboration phase");

		parent_comp = get_parent();
		`uvm_info("tag", $sformatf("parent=%s",  get_parent().get_name()), UVM_LOW);

		// Get all children and print them
    	get_children(l_comp_q);
    	foreach (l_comp_q[i])
      		`uvm_info ("tag", $sformatf("child_%0d = %s", i, l_comp_q[i].get_name()), UVM_LOW)


		if (uvm_config_db#(string)::get(this, "m_env", "TEST_STRING", strT))
			`uvm_info("tag", $sformatf("found %s", strT), UVM_LOW)
		else
			`uvm_info("tag", $sformatf("NOT found %s", strT), UVM_LOW)

	endfunction
endclass

module tb;
	base_obj obj;

    initial begin
        $display("tb");
		obj = new();
		run_test("base_test");
        $display("tb_end");

    end
endmodule