// Memory implementation

module mem(
	   clock,
	   address,
       data,
	   wren,
	   q
);

parameter MEM_DEPTH=1048578; // 1 MB of memory 
parameter MEM_WIDTH=8; // 8 bit = 1 byte

input clock;
input[31:0] address;
input wren;
input q;

inout[31:0] data;

reg[MEM_WIDTH-1:0] ram[0:MEM_DEPTH-1];

initial 
begin

end

always @(posedge clock)
begin // rising edge = posedge 
    // falling edge = negedge
end

always @(negedge clock)
begin

end

endmodule
