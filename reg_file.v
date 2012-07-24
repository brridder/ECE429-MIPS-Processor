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
    rsIn,
    rtIn,
    rdIn,
    regWriteEnable,
    writeBackData,
    dumpRegs
);
   
    parameter REG_WIDTH = 32;
    parameter NUM_REGS = 32;

    input wire clock;
    input wire[0:4] rdIn;
    input wire[0:31] writeBackData;
    input wire dumpRegs; // Display the contents of the registers. For testing and report purposes.

    output reg[0:31] rsOut;
    output reg[0:31] rtOut;

    input wire[0:4] rsIn;
    input wire[0:4] rtIn;
    input wire regWriteEnable;

    reg[0:REG_WIDTH-1] registers[0:NUM_REGS-1];

    integer i;

    // Zero out all of the registers.
    initial 
    begin
        for (i = 0; i < NUM_REGS; i = i + 1) begin
            registers[i] = i;
        end 
        registers[29] <= 32'h80020200;
    end // initial

    always @(posedge clock)
    begin
        if (dumpRegs) begin
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                $display("Register %d, value: %X", i, registers[i]);
            end
        end
    end

    always @(posedge clock)
    begin
	if(rdIn == 0 && regWriteEnable == 1) begin
	    $display("+============ TRYING TO WRITE TO $ZERO ===========+");
	end

	if(regWriteEnable == 1) begin
	    $display("writing: %d to register #: %d", writeBackData, rdIn);
	end
    end

    always @(posedge clock)
    begin
        fork
            rsOut <= registers[rsIn];
            rtOut <= registers[rtIn];
            //$display("time: %d Rs %d, RT: %d", $time, registers[rsIn], registers[rtIn]);
        join
        if (regWriteEnable) begin
            registers[rdIn] = writeBackData;
        end        
    end // always @(posedge clock) 

endmodule

