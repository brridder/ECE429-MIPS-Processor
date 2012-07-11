// 
// mem_stage.v
//
// Memory Stage
//

`include "control.vh"

module mem_stage(
    clock,
    address,
    data_in,
    address_out,

    mem_data_out,
    data_out,
    control,
    control_out,

    rdIn,
    rdOut
);

    input wire clock; 
    input wire[0:31] address;
    input wire[0:31] data_in;
    input wire[0:`CONTROL_REG_SIZE-1] control;
    input wire[0:4] rdIn;

    output reg[0:31] address_out;
    output reg[0:31] data_out;
    output wire[0:31] mem_data_out;
    output reg[0:`CONTROL_REG_SIZE-1] control_out;
    output reg[0:4] rdOut;

    wire wren_mem;

    assign wren_mem = control[`MEM_WE];

    mem_controller mcu1(
        .clock (clock),
        .address (address),
        .wren (wren_mem),
        .data_in (data_in),
        .data_out (mem_data_out)
    );

    always @(posedge clock)
    begin
	  rdOut <= rdIn;
    end

    always @(posedge clock)
    begin
        //$display("TIME: %d, address %X, wren %b", $time, address, wren_mem);
        address_out = address;
    end
    
    always @(posedge clock)
    begin
        data_out = address;
    end
    
    always @(posedge clock)
    begin
        control_out = control;
    end

endmodule
