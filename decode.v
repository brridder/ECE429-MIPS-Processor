//
// decode.v
//
//

module decode (
    clock,
    insn,
    insn_type,
    opcode,
    rs,
    rt,
    rd,
    shift_amount,
    funct,
    immediate,
    j_address
);

    input wire[0:31] insn;
    input wire clock; 
    output reg[0:1] insn_type;
    
    output reg[5:0] opcode;
    output reg[4:0] rs;
    output reg[4:0] rt;
    output reg[4:0] rd;
    output reg[4:0] shift_amount;
    output reg[5:0] funct;
    output reg[15:0] immediate;
    output reg[25:0] j_address;

    // Instruction types
    parameter I_TYPE = 0;
    parameter J_TYPE = 1;
    parameter R_TYPE = 2;
    parameter INVALID_INS = 3;
   

    // Is this the correct way of doing it?

    // Decode the opcode and type of instruction on the rising edge of the clock
    always @(posedge clock)
    begin
        opcode <= insn[26:31];
        $display("Got opcode %d", insn[26:31]);
        
        case(insn[26:31])
            6'b000000:	// ADD
              insn_type <= R_TYPE;
            default:
              insn_type <= INVALID_INS;
    
        endcase // case (insn[26:31])
        
    end

   // Decode the rest of the fields based on the type of instruction
   always @(insn_type)
   begin
       case(insn_type)
           R_TYPE:
             rs <= insn[21:25];
             
       endcase // case (insn_type)
       
   end

endmodule
