//
// decode.v
//
//

module decode (
    clock,
    insn
    //insn_type
);

    input wire[0:31] insn;
    input wire clock; 
    //reg[0:1] insn_type;
    
    reg[5:0] opcode;
    reg[4:0] rs;
    reg[4:0] rt;
    reg[4:0] rd;
    reg[4:0] shift_amount;
    reg[5:0] funct;
    reg[15:0] immediate;
    reg[25:0] j_address;

    always @(posedge clock)
    begin
        opcode <= insn[26:31];
    end

endmodule
