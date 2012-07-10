// 
// writeback_stage.v
//
// Writeback Stage
//

`include "control.vh"

module writeback_stage(
    clock,
    insn,
    rdIn,
    memDataIn,
    control,                       
    rdOut,
    regWriteEnable,
    insnOut
);

    input wire clock;
    input wire[0:31] insn;
    input wire[0:31] rdIn;
    input wire[0:31] memDataIn;
    input wire[0:`CONTROL_REG_SIZE-1] control;
  
    output reg[0:31] rdOut;
    output reg		 regWriteEnable;
    output reg[0:31] insnOut;

    always @(posedge clock)
    begin
        regWriteEnable <= control[`REG_WE];
        if (control[`MEM_WB]) begin
            rdOut <= memDataIn;            
        end
        else begin
            rdOut <= rdIn;            
        end        
    end
    
    always @(posedge clock)
    begin
        insnOut <= insn;
    end
    
endmodule
