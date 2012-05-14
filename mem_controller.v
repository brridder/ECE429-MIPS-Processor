//
// mem_controller.v
//
// Memory Controller Unit. 
//
// Currently, it only converts the program code addresses (logical addresses)
// into physical addresses.
//
// In the future, it will be able to load half words from memory appropriately
//


module mem_controller(
    clock,
    address,
    wren,
    data_in,
    data_out
);

parameter START_ADDRESS = 32'h80020000;
parameter MAX_ADDRESS = 32'hFFFF_FFFF;
input wire clock;
input wire[0:31] address;
input wire wren;
input wire[0:31] data_in;
 
output wire[0:31] data_out;

wire[0:31] mem_address;
assign mem_address = (address < START_ADDRESS) ? MAX_ADDRESS : address - START_ADDRESS;

mem memory0( 
    .clock (clock),
    .address (mem_address),
    .wren (wren),
    .data_in (data_in),
    .data_out (data_out)
    );

/*
always @(posedge clock)
begin
    if (address < START_ADDRESS) begin
        mem_address = MAX_ADDRESS;
    end else begin
        mem_address = address - START_ADDRESS;
    end
end
*/

endmodule
