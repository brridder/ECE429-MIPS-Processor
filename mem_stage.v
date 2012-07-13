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
    output reg[0:31] mem_data_out;
    output reg[0:`CONTROL_REG_SIZE-1] control_out;
    output reg[0:4] rdOut;
    wire[0:31] mcu_data_out;
    reg print_stack;
    wire wren_mem;

    assign wren_mem = control[`MEM_WE];

    mem_controller mcu1(
        .clock (clock),
        .address (address),
        .wren (wren_mem),
        .data_in (data_in),
        .data_out (mcu_data_out),
        .print_stack (print_stack) // Debugging
    );
    
    initial begin
        print_stack = 0;
    end

    always @(posedge clock)
    begin
	  rdOut <= rdIn;
    end
    
    always @(posedge clock)
    begin
        mem_data_out = mcu_data_out;
    end

    always @(posedge clock)
    begin
        //$display("TIME: %d, address %X, wren %b,mem_data_in %X,  mem_data out : %X", $time, address, wren_mem,data_in, mem_data_out);
        address_out = address;
    end
    
    always @(posedge clock)
      //hehehe I know this is terrible but it was a really easy way to
      //implement JAL ...
      begin
	if (control[`LINK] == 1) begin
	    data_out <= data_in;
	end
	else begin
            data_out <= address;
	end
        //$display("TIME: %d, data_out = %X", $time, data_out);
    end
    
    always @(posedge clock)
    begin
        control_out = control;
    end

endmodule
