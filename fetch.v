//
// fetch.v
//
//

module fetch (
    clock,
    address,
    insn,
    insn_decode,
    pc,
    pc_out,
    wren,
    stall
);

    input wire clock; // Clock signal for module. Make module sensitive to the positive edge of the clock
    input wire[0:31] insn; // this receives the instruction word from the main memory associated with the supplied PC
    input wire stall; // When asserted, the fetch effectively does a NOP. Data supplied to any of the outputs do not change, and the PC is not incremented by 4.

    output reg[0:31] address; // Output address supplied to the address input of the main memory. This signal transmits the PC for the instruction we are going to fetch
    output reg[0:31] insn_decode; // This transmits the instruction received from the main memory from insn
    output reg[0:31] pc; // transmits PC to the decode stage
    output reg[0:31] pc_out; 
    output reg wren; // indicates whether the fetch stage is performing a read or write to the main memory. Should always be asserted to a read for the fetch stage.
    reg[2:0] stage;

    initial
    begin
        $display("Initializing Fetch module"); 
        pc = 32'h8002_0000;
        wren = 1'b0;
    end

    always @(posedge clock)
    begin
        if (stall != 1'b1) begin
            address <= pc;
            insn_decode <= insn;
            pc <= pc +4;
        end
    end

    always @(posedge clock)
    begin 
        if (stall != 1'b1) begin
            pc_out <= pc;
        end
    end
endmodule
