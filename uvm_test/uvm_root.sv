import uvm_pkg::*;
`include "uvm_macros.svh"

class my_env extends uvm_env;
	`uvm_component_utils (my_env)

	function new(string name = "my_env", uvm_component parent = null);
		super.new(name, parent);
	endfunction
endclass

class my_test extends uvm_test;
	`uvm_component_utils (my_test)

	my_env m_env_1;
	my_env m_env_2;
	my_env m_env_3;
	my_env m_env_4;

	function new(string name = "my_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Parent is my_test
		m_env_1 = my_env::type_id::create("m_env_1", this);
		m_env_2 = my_env::type_id::create("m_env_2", this);

		// Parent is uvm_top
		m_env_3 = my_env::type_id::create("m_env_3", null);
		m_env_4 = my_env::type_id::create("m_env_4", null);

		uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_component 	comp;
		uvm_component 	comp_q [$];
		uvm_component 	comp_q2 [$];

		super.end_of_elaboration_phase(phase);

		// # UVM_WARNING @ 0: reporter [CMPNFD] Component matching 'm_env.m_agent.m_driver' was not found in the list of uvm_components
		comp = uvm_top.find("m_env.m_agent.m_driver");

		// # UVM_WARNING @ 0: reporter [CMPNFD] Component matching '*apb_driver*' was not found in the list of uvm_components
		comp = uvm_top.find("*apb_driver*");

		comp = uvm_top.find("uvm_test_top.m_env_2");

		// # UVM_WARNING @ 0: reporter [CMPNFD] Component matching 'uvm_test_top.m_env_4' was not found in the list of uvm_components
		comp = uvm_top.find("uvm_test_top.m_env_4");

		// Returns the component handle (find) or list of components handles matching a given string.
		uvm_top.find_all("uvm_test_top.*", comp_q);

		foreach (comp_q[i]) begin
			`uvm_info (get_type_name(), $sformatf("Found component %s", comp_q[i].get_full_name()), UVM_LOW)
		end

		`uvm_info (get_type_name(), "------------------------------------------", UVM_LOW)

		uvm_top.find_all("*", comp_q2);
		foreach (comp_q2[i]) begin
			`uvm_info (get_type_name(), $sformatf("Found component %s", comp_q2[i].get_full_name()), UVM_LOW)
		end

		`uvm_info (get_type_name(), "------------------------------------------", UVM_LOW)
		uvm_top.print_topology();
	endfunction
endclass

module tb;
  initial begin
    $display("start");
    run_test("my_test");
  end
endmodule