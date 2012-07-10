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
        //if (insn_valid) begin
            pcOut <= pc;
        //end
    end

    always @(posedge clock)
    begin
        //if (insn_valid) begin
            irOut <= insn;
        //end
    end

    always @(posedge clock)
      begin
	    if(insn_valid) begin
            control[`I_TYPE] = 1'b0;
            control[`R_TYPE] = 1'b0;
            control[`J_TYPE] = 1'b0;
		    control[`MEM_WE] = 1'b0;
            control[`MEM_WB] = 1'b0;            

            case(opcode)
	            // R-TYPE
                6'b000000: begin
		    control[`R_TYPE] = 1'b1;
                    control[`REG_WE] = 1;
	            end // case: 6'b000000
	       
	            //I-TYPE
	            6'b001001: 	//ADDIU
                begin
                  control[`REG_WE] = 1'b1;
                  control[`I_TYPE] = 1'b1;
                end
	            6'b001010: 	//SLTI
                begin
                  control[`REG_WE] = 1;
                  control[`I_TYPE] = 1'b1;
                end
	            6'b100011: 	//LW
                begin
                  control[`REG_WE] = 1;
                  control[`I_TYPE] = 1'b1;
                  control[`MEM_WB] = 1'b1;                    
                end
	            6'b101011: 	//SW
                begin
                  control[`REG_WE] = 0;
                  control[`MEM_WE] = 1'b1;
                  control[`I_TYPE] = 1'b1;
                end
	            6'b001111: 	//LUI
                begin
                  control[`REG_WE] = 1;
                  control[`I_TYPE] = 1'b1;
                end
	            6'b001101: 	//ORI
                begin
                  control[`REG_WE] = 1;
                  control[`I_TYPE] = 1'b1;
                end
	            //J-TYPE
	            6'b000010: 	//J
                begin
                  control[`REG_WE] = 1;
		  control[`J_TYPE] = 1'b1;
                end
	            6'b000100: 	//BEQ
                begin
                  control[`REG_WE] = 1;
		  control[`J_TYPE] = 1'b1;
                end
	            6'b000101: 	//BNE
                begin
                  control[`REG_WE] = 1;
		  control[`J_TYPE] = 1'b1;
                end
	            6'b000111: 	//BGTZ
                begin
                  control[`REG_WE] = 1;
		  control[`J_TYPE] = 1'b1;
                end
	            6'b000110: 	//BLEZ
                begin
                  control[`REG_WE] = 1;
		  control[`J_TYPE] = 1'b1;
                end
	            6'b000001: //REGIMM instructions
	              begin
			  control[`J_TYPE] = 1'b1;
		            case(rt)
		                5'b00000:	//BLTZ
				  ;
		                5'b00001:	//BGEZ
				  ;
		                default:
		                  $display("REGIMM not implemented");
		            endcase // case (rt)
                  control[`REG_WE] = 0;
	            end
                default:
	          ;
                  

            endcase // case (insn[26:31])
            
    	    end // if (insn_valid = 1'b1)

    end // always @ (posedge clock)
   
endmodule
