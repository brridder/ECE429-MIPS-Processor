//
// decode.v
//
//

module decode (
    clock,
    insn
);

    input wire[0:31] insn;
    input wire clock; 
    reg[0:1] insn_type;
    
    
    wire[5:0] opcode;
    wire[4:0] rs;
    wire[4:0] rt;
    wire[4:0] rd;
    wire[4:0] shift_amount;
    wire[5:0] funct;
    wire[15:0] immediate;
    wire[25:0] j_address;

    // Instruction types
    parameter I_TYPE = 0;
    parameter J_TYPE = 1;
    parameter R_TYPE = 2;
    parameter INVALID_INS = 3;


    assign opcode = insn[26:31];
    assign rs = insn[21:25];
    assign rt = insn[16:20];
    assign rd = insn[11:15];
    assign shift_amount = insn[6:10];
    assign funct = insn[0:5];
    assign immediate = insn[0:15];
    assign j_address = insn[0:25];
   

    // Is this the correct way of doing it?

    // Decode the opcode and type of instruction on the rising edge of the clock
    always @(posedge clock)
    begin
        //opcode <= insn[26:31];
        // DEBUG
        $display("Got opcode (decode.v) %d", insn[26:31]);
        
        case(opcode)
            6'b000000: begin	// R-TYPE ARithemtic
	       //TODO: add type of intrsuction (R/I/J) to output
	  $display("R-TYPE INSTRUCTION");
	  case(funct)
            6'b100000: //ADD
	      $display("ADD rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100001: //ADDU
	      $display("ADDU rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100010: //SUB
	      $display("SUB rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100011: //SUBU
	      $display("SUBU rs: %d rt: %d rd: %d", rs, rt, rd);
	  
	     default:
	       $display("unimplemented ADD type intruction");   
	   endcase // case (funct)
	  end
            default:
	       $display("unimplemented/incorrect intruction");  
                //insn_type <= INVALID_INS;
    
        endcase // case (insn[26:31])
        
    end

   // Decode the rest of the fields based on the type of instruction



endmodule
