module tb();
    bit foo[]; // dynamic array of 1-bit, A dynamic array is an unpacked array whose size can be set or changed at run time
    bit foo2[5]; // single dimemsional unpacked array
    bit bar[$];
    bit dog[string]; // Associative Array. An bit array with string index
    // bit [7:0][15:0] cats;
    // bit [0:7][15:0] cats;
    // bit [0:7][0:15] cats;
    bit [0:7][15:0] cats; // a 2D packed array that occupies 8*16-bits or 15words
    bit [7:0][15:0] birds[8]; // single dimemsional unpacked array of 2D packed array

    bit [7:0] 	m_data; 	// A vector or 1D packed array

    bit m_data2 [8]; 	// unpacked packed array

    initial begin;
        foo = new[5];
        foo[0] = 1;
        foo[1] = 1;
        foo[2] = 0;
        foo[3] = 1;
        foo[4] = 0;



        for (int i = 0; i < $size(foo); i++) begin
            foo[i] = 1'b0;
        end

        for (int i = 0; i < $size(foo); i++) begin
            $display("foo[%d]:%b",i, foo[i]);
        end

        for (int i = 0; i < $size(foo2); i++) begin
            foo2[i] = 1'b1;
        end

        for (int i = 0; i < $size(foo2); i++) begin
            $display("foo2[%d]:%b",i, foo2[i]);
        end

        foreach(foo2[i]) begin
            foo2[i] = 1'b0;
        end

        for (int i = 0; i < $size(foo2); i++) begin
            $display("foo2[%d]:%b",i, foo2[i]);
        end

        $display("dog size[%d]", $size(dog));

        // bit dog[string];
        dog = '{"adog": 1, "bdog":0};
        $display("dog size[%d] adog %b, bdog %b", $size(dog), dog["adog"], dog["bdog"]);

        m_data = 8'hA2;
		for (int i = 0; i < $size(m_data); i++) begin
			$display ("m_data[%0d] = %b", i, m_data[i]);
		end

        // m_data2 = 8'hA2; // Cannot assign a packed type 'bit[7:0]' to an unpacked type 'bit $[0:7]'.

        // bit bar[$];
        // bit [7:0][15:0] cats;
        // bit [7:0][15:0] birds[8];

        cats = {16'h1110, 16'h2220, 16'h3330, 16'h4440, 16'h5550, 16'h6660, 16'h7770, 16'h8880};

        foreach(cats[i]) begin
            // cats[i] = i;
			$display ("cats[%0d] = %x", i, cats[i]);
		end

        // dog[]


    end
endmodule