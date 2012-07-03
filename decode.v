//
// decode.v
//
//

`include "control.vh"

module decode (
    clock,
    insn,
    insn_valid,
    pc,
    rsData,
    rtData,
    rdIn,
    pcOut,
    irOut,
    writeBackData,
    regWriteEnable,
    control
);

    input wire[0:31] insn;
    input wire[0:31] pc;
    input wire clock;
    input wire insn_valid;
    input wire[4:0] rdIn;
    input wire[0:31] writeBackData;
    input wire regWriteEnable;

    output wire[0:31] rsData; // Latched in the reg_file module
    output wire[0:31] rtData;
    output reg[0:31] pcOut; 
    output reg[0:31] irOut;
    output reg[0:`CONTROL_REG_SIZE-1] control;    

    reg[0:1] insn_type;
    
    wire[0:5] opcode;
    wire[4:0] rs;
    wire[4:0] rt;
    wire[4:0] rd;
    wire[4:0] shift_amount;
    wire[5:0] funct;
    wire[15:0] immediate;
    wire[25:0] j_address;
    wire[4:0] base;
    wire[15:0] offset;
  
    reg_file REGISTER_FILE(
        .clock (clock),
        .rsOut (rsData),
        .rtOut (rtData),
        .rsIn (rs),
        .rtIn (rt),
        .rdIn (rdIn),
        .regWriteEnable (regWriteEnable),
        .writeBackData (writeBackData)
    );

    // Instruction types
    parameter I_TYPE = 0;
    parameter J_TYPE = 1;
    parameter R_TYPE = 2;
    parameter INVALID_INS = 3;

    assign opcode = insn[0:5];
    assign rs = insn[6:10];
    assign base = insn[6:10];

    assign rt = insn[11:15];
    assign rd = insn[16:20];
    assign shift_amount = insn[20:25];
    assign funct = insn[26:31];
    assign immediate = insn[16:31];
    assign offset = insn[16:31];
    assign j_address = insn[6:31];
    
    always @(posedge clock)
    begin
        if (insn_valid) begin
            pcOut <= pc;
        end
    end

    always @(posedge clock)
    begin
        if (insn_valid) begin
            irOut <= insn;
        end
    end

    always @(posedge clock)
      begin
	  control[`R_TYPE] = 1'b0;
	    if(insn_valid) begin
            case(opcode)
	            // R-TYPE
                6'b000000: begin
                    $display("R-Type instruction.");
		    control[`R_TYPE] = 1'b1;
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
                    control[`REG_WE] = 1;
	            end // case: 6'b000000

	            //I-TYPE
	            6'b001001: 	//ADDIU
                begin
                  $display("I-Type instruction.");
	              $display("ADDIU rs: %d rt: %d immediate: %d", rs, rt, immediate);
                  control[`REG_WE] = 1;
                end
	            6'b001010: 	//SLTI
                begin
                  $display("I-Type instruction.");
	              $display("SLTI rs: %d rt: %d immediate: %d", rs, rt, immediate);
                  control[`REG_WE] = 1;
                end
	            6'b100011: 	//LW
                begin
                  $display("I-Type instruction.");
	              $display("LW base: %d rt: %d offset: %d", base, rt, offset);
                  control[`REG_WE] = 1;
                end
	            6'b101011: 	//SW
                begin
                  $display("I-Type instruction.");
	              $display("SW base: %d rt: %d offset: %d", base, rt, offset);
                  control[`REG_WE] = 0;
                end
	            6'b001111: 	//LUI
                begin
                  $display("I-Type instruction.");
	              $display("LUI rt: %d immediate: %d", rt, immediate);
                  control[`REG_WE] = 1;
                end
	            6'b001101: 	//ORI
                begin
                  $display("I-Type instruction.");
	              $display("ORI rs: %d rt: %d immediate: %d", rs, rt, immediate);
                  control[`REG_WE] = 1;
                end
	            //J-TYPE
	            6'b000010: 	//J
                begin
                  $display("J-Type instruction.");
	              $display("J instr_index: %d", j_address);
                  control[`REG_WE] = 1;
                end
	            6'b000100: 	//BEQ
                begin
                  $display("J-Type instruction.");
	              $display("BEQ rs: %d rt: %d offset: %d", rs, rt, offset);
                  control[`REG_WE] = 1;
                end
	            6'b000101: 	//BNE
                begin
                  $display("J-Type instruction.");
	              $display("BNE rs: %d rt: %d offset: %d", rs, rt, offset);
                  control[`REG_WE] = 1;
                end
	            6'b000111: 	//BGTZ
                begin
                  $display("J-Type instruction.");
	              $display("BGTZ rs: %d offset: %d", rs, offset);
                  control[`REG_WE] = 1;
                end
	            6'b000110: 	//BLEZ
                begin
                  $display("J-Type instruction.");
	              $display("BLEZ rs: %d offset: %d", rs, offset);
                  control[`REG_WE] = 1;
                end
                
	            6'b000001: //REGIMM instructions
	            begin
                    $display("REGIMM-Type instruction.");
		            case(rt)
		                5'b00000:	//BLTZ
		                  $display("BLTZ rs: %d offset: %d", rs, offset);
		                5'b00001:	//BGEZ
		                  $display("BGEZ rs: %d offset: %d", rs, offset);
		                default:
		                  $display("REGIMM not implemented");
		            endcase // case (rt)
                  control[`REG_WE] = 0;
	            end
                default:
	              $display("unimplemented/incorrect intruction");  
                  //control[`REG_WE] = 0;

            endcase // case (insn[26:31])
            
            $display("%d", $time);
	    end // if (insn_valid = 1'b1)

    end // always @ (posedge clock)
   
endmodule
