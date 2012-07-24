// 
// writeback_stage.v
//
// Writeback Stage
//

`include "control.vh"
`define WIRED_OUTPUTS
module writeback_stage(
    clock,
    rdIn,
    rdDataIn,
    memDataIn,
    control,                       
    rdOut,
    regWriteEnable,
    writeBackData
);

    input wire clock;
    input wire[0:4] rdIn;
    input wire[0:31] rdDataIn;
    input wire[0:31] memDataIn;
    input wire[0:`CONTROL_REG_SIZE-1] control;
 
`ifdef WIRED_OUTPUTS
    output wire[0:4] rdOut;
    output wire regWriteEnable;
    output wire[0:31] writeBackData;
   
    assign rdOut = rdIn;
    assign writeBackData = control[`MEM_WB] ? memDataIn : rdDataIn;
    assign regWriteEnable = control[`REG_WE];

`else 
    output reg[0:4] rdOut;
    output reg regWriteEnable;
    output reg[0:31] writeBackData;

    always @(posedge clock)
    begin
        regWriteEnable <= control[`REG_WE];
        if (control[`MEM_WB]) begin
            writeBackData <= memDataIn;            
        end
        else begin
            writeBackData <= rdDataIn;            
        end  
        rdOut <= rdIn;        
    end
`endif    
endmodule
