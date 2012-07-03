//
// alu.v
//
//

`include "control.vh"

module alu (
    clock,
    rsData,
    rtData,
    control,
    funct,
);

    input wire clock;
    input wire [0:31] rsData;
    input wire [0:31] rtData;

    input wire [0:`CONTROL_REG_SIZE-1] control;
    input wire [5:0] funct;

endmodule

    