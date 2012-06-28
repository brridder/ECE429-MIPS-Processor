//
// reg_file.v
//
// Register File
//
//
// Register outputs are the values stored in the regs
// Register inputs are pointers for the specific reg to use
//

module reg_file (
    clock,
    rsOut,
    rtOut,
    //rsIn,
    //rtIn,
    rdIn,
    //regWriteEnable,
    writeBackData,
    pcIn,
    irIn,
    pcOut,
    irOut
);
   
    parameter REG_WIDTH = 32;
    parameter NUM_REGS = 32;

    input wire clock;
    input wire[4:0] rdIn;
    input wire[0:31] pcIn;
    input wire[0:31] irIn;
    input wire[0:31] writeBackData;

    output reg[0:31] rsOut;
    output reg[0:31] rtOut;
    output reg[0:31] pcOut;
    output reg[0:31] irOut;

    wire[4:0] rs;
    wire[4:0] rt;
    wire regWriteEnable;
    reg[0:REG_WIDTH-1] registers[0:NUM_REGS-1];

    integer i;

    assign rs = irIn[6:10];
    assign rt = irIn[11:15];
    
    // Zero out all of the registers.
    initial 
    begin
        for (i = 0; i < NUM_REGS; i = i + 1) begin
            registers[i] = 0;
        end // for ()
    end // initial

    always @(posedge clock)
    begin
        fork
            rsOut <= registers[rs];
            rtOut <= registers[rt];
        join
        registers[rdIn] = writeBackData;
    end // always @(posedge clock) 

endmodule

