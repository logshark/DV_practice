class A;
	int varA;

	function new(int varA);
		this.varA = varA;
	endfunction

	function print();
		$display("non virtual classA varA:%0d", varA);
	endfunction

	virtual function virtual_print();
		$display("virtual classA varA:%0d", varA);
	endfunction
endclass

class B extends A;
	int varB;

	function new(int varA, int varB);
		super.new(varA);
		this.varB = varB;
	endfunction

	function print();
		$display("non virtual classB varA:%0d varB:%0d", varA, varB);
	endfunction

	virtual function virtual_print();
		$display("virtual classB varA:%0d varB:%0d", varA, varB);
	endfunction
endclass

// class B extends A;
// 	function print();
// 		$display("non virtual BBB");
// 	endfunction

// 	virtual function virtual_print();
// 		$display("virtual BBB");
// 	endfunction
// endclass

module tb;
	A a = new(123);
	B b = new(123, 456);
	// A a;
	// B b;
    initial begin
		a.print();
		b.print();

		a = b;
		a.print();
		b.print();

		a.virtual_print();
		b.virtual_print();

	// 	a = new();
	// 	b = new();

	// 	$display("a = b");
	// 	a = b;
	// 	a.print();
	// 	b.print();
	// 	a.virtual_print();
	// 	b.virtual_print();
    end
endmodule