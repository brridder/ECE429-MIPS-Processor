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
    wren,
    stall,
    pcIn,
    jump
);

    input wire clock; // Clock signal for module. 
    // Make module sensitive to the positive edge of the clock
    input wire[0:31] insn; // this receives the instruction 
    // word from the main memory associated with the supplied PC
    input wire stall; // When asserted, the fetch effectively
    //  does a NOP. Data supplied to any of the outputs do not change, 
    // and the PC is not incremented by 4.
    input wire[0:31] pcIn; // this receives a pc to do branches
    input wire       jump; // this indicates if pcIn should be used
    // to read the next insn, i.e. do a jump
    
    output reg[0:31] address; // Output address supplied to the address input of the main memory. This signal transmits the PC for the instruction we are going to fetch
    output wire[0:31] insn_decode; // This transmits the instruction received from the main memory from insn
    output reg[0:31] pc; // 
    output reg wren; // indicates whether the fetch stage is performing a read or write to the main memory. Should always be asserted to a read for the fetch stage.

    assign insn_decode = stall ? 32'h0000_0000 : insn;
    initial begin
        $display("Initializing Fetch module"); 
        pc = 32'h8002_0000;
        wren = 1'b0;
    end

    always @(posedge clock) begin


        if (stall != 1'b1) begin
            if (jump) begin
                address <= pcIn;                
                pc <= pcIn + 4;
            end
            else begin
                address <= pc;
                pc <= pc + 4;
            end            
        end
    end

endmodule
