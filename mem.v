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

parameter MEM_DEPTH=1048578; // 1 MB of memory
parameter MEM_WIDTH=8; // 8 bit = 1 byte

input clock;
input[0:31] address;
input wren;
input[0:31] data_in;

wire[0:31] data_in;
wire clock;
wire wren;
wire[0:31] address;

output[0:31] data_out;

reg[0:31] data_out;


reg[0:MEM_WIDTH-1] ram[0:MEM_DEPTH-1];
integer i;

reg[0:31] data;
//assign data_out = data;

initial 
begin
    $display("Initializing memory");
    for (i = 0; i < MEM_DEPTH; i = i+1) begin
        ram[i] = 0;
    end
end


// rising edge = posedge 
always @(posedge clock)
begin 
    if ((address != 0) && (address < MEM_DEPTH)) begin
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

// falling edge = negedge
always @(negedge clock)
begin
    if ((address != 0) && (address < MEM_DEPTH)) begin
        data_out = 32'h0000_0000;
        if (wren == 1'b0) begin 
            data = {ram[address], ram[address+1], ram[address+2], ram[address+3]};
        end
    end
end
endmodule
