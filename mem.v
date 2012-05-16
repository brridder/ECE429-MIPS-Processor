//
// mem.v
// 
// Single port memory. Supports reads and writes.
// 
// Write: wren = '1' 
// Read: wren = '0'
//
// Big endian
//

module mem(
	   clock,
	   address,
	   wren,
       data_in,
	   data_out 
);

    // Parameters
    parameter MEM_DEPTH=1048578; // 1 MB of memory
    parameter MEM_WIDTH=8; // 8 bit = 1 byte

    // Inputs
    input wire          clock;
    input wire[0:31]    address;
    input wire          wren;
    input wire[0:31]    data_in;

    // Outputs
    output reg[0:31]    data_out;

    // Internals
    integer             i;
    wire[0:31]          data; // Temperory data storage
    reg[0:MEM_WIDTH-1]  ram[0:MEM_DEPTH-1]; // The memory

    // Set the memory into a known inital state
    initial 
    begin
        $display("Initializing memory");
        for (i = 0; i < MEM_DEPTH; i = i+1) begin
            ram[i] = 0;
        end
    end

    // Data is put on a mux to only set on the reads
    assign data = !wren ? {ram[address], ram[address+1], 
                           ram[address+2], ram[address+3]} : 32'h0000_0000;

    // Rising edge, load the data
    always @(posedge clock)
    begin 
        if (address < MEM_DEPTH) begin
            if (wren == 1'b1) begin
                fork
                ram[address] <= data_in[0:7];         
                ram[address+1] <= data_in[7:15];         
                ram[address+2] <= data_in[16:23];         
                ram[address+3] <= data_in[24:31];         
                join
            end
        end
    end

    // Falling edge, set the output data
    always @(negedge clock)
    begin
        if (address < MEM_DEPTH) begin
            data_out = data;
        end else begin
            data_out = 32'h0000_0000;
        end
    end
endmodule
