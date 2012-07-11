// 
// writeback_stage.v
//
// Writeback Stage
//

`include "control.vh"

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
  
    output reg[4:0] rdOut;
    output reg		 regWriteEnable;
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
    
endmodule
