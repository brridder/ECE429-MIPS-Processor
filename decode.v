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
    wire[4:0] base;
    wire [15:0] offset;
   
    // Instruction types
    parameter I_TYPE = 0;
    parameter J_TYPE = 1;
    parameter R_TYPE = 2;
    parameter INVALID_INS = 3;


    assign opcode = insn[26:31];
    assign rs = insn[21:25];
    assign base = insn[21:25];
    assign rt = insn[16:20];
    assign rd = insn[11:15];
    assign shift_amount = insn[6:10];
    assign funct = insn[0:5];
    assign immediate = insn[0:15];
    assign offset = insn[0:15];
    assign j_address = insn[0:25];
   

    // Is this the correct way of doing it?

    // Decode the opcode and type of instruction on the rising edge of the clock
    always @(posedge clock)
    begin
        //opcode <= insn[26:31];
        // DEBUG
        $display("Got opcode (decode.v) %d", insn[26:31]);
        
        case(opcode)
	  // R-TYPE
            6'b000000: begin	
	  case(funct)
            6'b100000: //ADD
	      $display("ADD rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100001: //ADDU
	      $display("ADDU rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100010: //SUB
	      $display("SUB rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100011: //SUBU
	      $display("SUBU rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b101010: //SLT
	      $display("SLT rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b101011: //SLTU
	      $display("SLTU rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b000000: //SLL
	      $display("SLL/NOP(sa = 0) sa: %d rt: %d rd: %d", shift_amount, rt, rd);
	    6'b000010: //SRL
	      $display("SRL sa: %d rt: %d rd: %d", shift_amount, rt, rd);
	    6'b000011: //SRA
	      $display("SRA sa: %d rt: %d rd: %d", shift_amount, rt, rd);
	    6'b100100: //AND
	      $display("AND rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100101: //OR
	      $display("OR rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100110: //XOR
	      $display("XOR rs: %d rt: %d rd: %d", rs, rt, rd);
	    6'b100111: //NOR
	      $display("NOR rs: %d rt: %d rd: %d", rs, rt, rd);
	  
	     default:
	       $display("unimplemented ADD type intruction");   
	   endcase // case (funct)
	    end // case: 6'b000000

	  //I-TYPE
	   6'b001001: 	//ADDIU
	     $display("ADDIU rs: %d rt: %d immediate: %d", rs, rt, immediate);
	  6'b001010: 	//SLTI
	     $display("SLTI rs: %d rt: %d immediate: %d", rs, rt, immediate);
	  6'b100011: 	//LW
	     $display("LW base: %d rt: %d offset: %d", base, rt, offset);
	  6'b101011: 	//SW
	     $display("SW base: %d rt: %d offset: %d", base, rt, offset);
	  6'b001111: 	//LUI
	     $display("LUI rt: %d immediate: %d", rt, immediate);
	  6'b001101: 	//ORI
	     $display("ORI rs: %d rt: %d immediate: %d", rs, rt, immediate);

	  //J-TYPE
	  6'b000010: 	//J
	     $display("J instr_index: %d", j_address);
	  6'b000100: 	//BEQ
	     $display("BEQ rs: %d rt: %d offset: %d", rs, rt, offset);
	  6'b000101: 	//BNE
	     $display("BNE rs: %d rt: %d offset: %d", rs, rt, offset);
	  6'b000111: 	//BGTZ
	     $display("BGTZ rs: %d offset: %d", rs, offset);
	  6'b000110: 	//BLEZ
	     $display("BLEZ rs: %d offset: %d", rs, offset);

	   6'b000001: //REGIMM instructions
	     begin
		case(rt)
		   5'b00000:	//BLTZ
		     $display("BLTZ rs: %d offset: %d", rs, offset);
		   5'b00001:	//BGEZ
		     $display("BGEZ rs: %d offset: %d", rs, offset);
		  default:
		    $display("REGIMM not implemented");
		endcase; // case (rt)
		
	     end
	  

	  
	  
            default:
	       $display("unimplemented/incorrect intruction");  
                //insn_type <= INVALID_INS;
    
        endcase // case (insn[26:31])
        
    end

   // Decode the rest of the fields based on the type of instruction



endmodule
