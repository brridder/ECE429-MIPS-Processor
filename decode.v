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
    control,
    rdOut,
    alu_stage_rd,
    mem_stage_rd,
    writeback_stage_rd, 
    stall,
    dumpRegs
);

    input wire[0:31] insn;
    input wire[0:31] pc;
    input wire clock;
    input wire insn_valid;
    input wire[0:4] rdIn;
    input wire[0:31] writeBackData;
    input wire regWriteEnable;
    input wire dumpRegs;

    input wire[0:4] alu_stage_rd;
    input wire[0:4] mem_stage_rd;
    input wire[0:4] writeback_stage_rd;

    output wire[0:31] rsData; // Latched in the reg_file module
    output wire[0:31] rtData;
    output reg[0:31] pcOut; 
    output reg[0:31] irOut;
    output reg[0:`CONTROL_REG_SIZE-1] control;    
    output reg[0:4] rdOut;    
    output reg stall; 

    reg[0:1] insn_type;
    
    wire[0:5] opcode;
    wire[0:4] rs;
    wire[0:4] rt;
    wire[0:4] rd;
    wire[0:4] shift_amount;
    wire[0:5] funct;
    wire[0:15] immediate;
    wire[0:25] j_address;
    wire[0:15] offset;
  
    reg_file REGISTER_FILE(
        .clock (clock),
        .rsOut (rsData),
        .rtOut (rtData),
        .rsIn (rs),
        .rtIn (rt),
        .rdIn (rdIn),
        .regWriteEnable (regWriteEnable),
        .writeBackData (writeBackData),
        .dumpRegs(dumpRegs)
    );

    // Instruction types
    parameter I_TYPE = 0;
    parameter J_TYPE = 1;
    parameter R_TYPE = 2;
    parameter INVALID_INS = 3;

    assign opcode = insn[0:5];
    assign rs = insn[6:10];

    assign rt = insn[11:15];
    assign rd = insn[16:20];
    assign shift_amount = insn[20:25];
    assign funct = insn[26:31];
    assign immediate = insn[16:31];
    assign offset = insn[16:31];
    assign j_address = insn[6:31];
    
    always @(posedge clock)
    begin
        pcOut <= pc;
        irOut <= insn;
        rdOut <= rd;
    end

    always @(posedge clock)
    begin
        control[`REG_WE] = 1'b0;
        control[`I_TYPE] = 1'b0;
        control[`R_TYPE] = 1'b0;
        control[`J_TYPE] = 1'b0;
        control[`MEM_WE] = 1'b0;
        control[`MEM_WB] = 1'b0;
        control[`MEM_READ] = 1'b0;
        control[`LINK] = 1'b0;
        if(insn_valid && insn != 32'h0000_0000) begin            
            case(opcode)
                // R-TYPE
                6'b000000: begin
                    control[`R_TYPE] = 1'b1;
    	            if(funct == `JR) begin
    		            control[`REG_WE] = 0;
    	            end else begin
    		            control[`REG_WE] = 1;
    	            end
                end // case: 6'b000000
           
                //I-TYPE
                6'b001001: begin //ADDIU 
                    control[`REG_WE] = 1'b1;
                    control[`I_TYPE] = 1'b1;
                end
                6'b001010: begin //SLTI
                    control[`REG_WE] = 1;
                    control[`I_TYPE] = 1'b1;
                end
                6'b100011: begin //LW
                    control[`REG_WE] = 1;
                    control[`I_TYPE] = 1'b1;
                    control[`MEM_WB] = 1'b1;                    
                    control[`MEM_READ] = 1'b1;
                end
                6'b101011: begin //SW
                    control[`REG_WE] = 0;
                    control[`MEM_WE] = 1'b1;
                    control[`I_TYPE] = 1'b1;
                end
                6'b001111: begin //LUI
                    control[`REG_WE] = 1;
                    control[`I_TYPE] = 1'b1;
                end
                6'b001101: begin //ORI
                    control[`REG_WE] = 1'b1;
                    control[`I_TYPE] = 1'b1;
    	            control[`LINK] = 1'b1;
                end
                //J-TYPE
                6'b000010: begin //J
                    control[`REG_WE] = 0;
    	            control[`J_TYPE] = 1'b1;
                end
                `JAL: begin
    	            control[`REG_WE] = 1;
    	            control[`J_TYPE] = 1'b1;
    	            control[`LINK] = 1'b1;
    	        end
                6'b000100: begin //BEQ
                    control[`REG_WE] = 0;
             	    control[`J_TYPE] = 1'b1;
                end
                6'b000101: begin //BNE
                    control[`REG_WE] = 0;
                    control[`J_TYPE] = 1'b1;
                end
                6'b000111: begin //BGTZ
                    control[`REG_WE] = 0;
                    control[`J_TYPE] = 1'b1;
                end
                6'b000110: begin //BLEZ
                    control[`REG_WE] = 0;
                    control[`J_TYPE] = 1'b1;
                end
                6'b000001: begin //REGIMM instructions
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
            endcase // case (opcode)
        end // if (insn_valid = 1'b1)
    end // always @ (posedge clock)

    always @(posedge control)
    begin
        if (control[`REG_WE] == 1) begin
            if (control[`I_TYPE] == 1) begin
                //if (rt == 
            end else if (control[`R_TYPE] == 1) begin
            
            end else if (control[`J_TYPE] == 1) begin

            end
            irOut = 32'b0000_0000;
            stall = 1'b1;
        end
    end
    
endmodule
