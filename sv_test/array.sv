module tb();
    bit [3:0][7:0] packed_data; // static array
    bit [7:0]      unpacked_data[15:0]; // dynamic array

    int associative_array[int];
endmodule