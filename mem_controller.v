//
// mem_controller.v
//
// Memory Controller Unit. 
//


module mem_controller(
    clock,
    address,
    wren,
    data_in,
    data_out
);


input wire clock;
input wire[0:31] address;
input wire wren;
input wire[0:31] data_in;
 
output wire[0:31] data_out;

reg[0:31] mem_address;

mem memory0( 
    .clock (clock),
    .address (mem_address),
    .wren (wren),
    .data_in (data_in),
    .data_out (data_out)
    );


endmodule
