//
// decode.v
//
//

`include "control.vh"

module decode (
    clock,
    fetch_insn,
    insn_valid,
    pc,
    rsDataOut,
    rtDataOut,
    rdIn,
    pcOut,
    irOut,
    writeBackData,
    regWriteEnable,
    control,
    rdOut,
    alu_stage_rd,
    mem_stage_rd,
    alu_stage_reg_we,
    mem_stage_reg_we,
    writeback_stage_rd,
    writeback_stage_we,
    stall,
    alu_branch_taken,
    dumpRegs
);

    output wire[0:31] rsDataOut;
    output wire[0:31] rtDataOut;

    wire[0:31] insn;
    input wire[0:31] fetch_insn;
    reg[0:31] stalled_insn;
    input wire [0:31] pc;
    input wire clock;
    input wire insn_valid;
    input wire[0:4] rdIn;
    input wire[0:31] writeBackData;
    input wire regWriteEnable;
    input wire dumpRegs;

    input wire[0:4] alu_stage_rd;
    input wire[0:4] mem_stage_rd;
    input wire[0:4] writeback_stage_rd;
    input wire      alu_stage_reg_we;
    input wire      mem_stage_reg_we;
    input wire      writeback_stage_we;
    input wire      alu_branch_taken;

    wire[0:31] rsData; // Latched in the reg_file module
    wire[0:31] rtData;
    output reg[0:31] pcOut; 
    output reg[0:31] irOut;
    output reg[0:`CONTROL_REG_SIZE-1] control;    
    output reg[0:4] rdOut;    
    output reg stall; 

    reg[0:1] insn_type;
    reg [0:31] nop_insn;
    
    wire[0:5] opcode;
    wire[0:4] rs;
    wire[0:4] rt;
    wire[0:4] rd;
    wire[0:4] shift_amount;
    wire[0:5] funct;
    wire[0:15] immediate;
    wire[0:25] j_address;
    wire[0:15] offset;

    reg [0:31] writeback_data_forward;

    
    wire    should_stall_rs; 
    wire    should_stall_rt; 
  
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

    assign insn = stall ? stalled_insn : fetch_insn;

    assign opcode = insn[0:5];
    assign rs = insn[6:10];

    assign rt = insn[11:15];
    assign rd = insn[16:20];
    assign shift_amount = insn[20:25];
    assign funct = insn[26:31];
    assign immediate = insn[16:31];
    assign offset = insn[16:31];
    assign j_address = insn[6:31];

    assign rsDataOut = (regWriteEnable == 1 && rs == rdIn) ? writeBackData : rsData;
    assign rtDataOut = (regWriteEnable == 1 && rt == rdIn) ? writeBackData : rtData;
    
    assign should_stall_rs = (((alu_stage_reg_we == 1 && stall == 0) && 
                           (rs == alu_stage_rd)) || 
                           ((mem_stage_reg_we == 1) && 
                           (rs == mem_stage_rd)) ||
                           ((writeback_stage_we == 1) &&
                           (rs == writeback_stage_rd)) ||
                           ((regWriteEnable == 1) &&
                           (rs == rdIn)));

    assign should_stall_rt = (((alu_stage_reg_we == 1 && stall == 0) && 
                           (rt == alu_stage_rd)) || 
                           ((mem_stage_reg_we == 1) && 
                           (rt == mem_stage_rd)) ||
                           ((writeback_stage_we == 1) &&
                           (rt == writeback_stage_rd)) ||
                           ((regWriteEnable == 1) &&
                           (rt == rdIn)));
    initial begin
        nop_insn = 32'h0000_0000;
    end

    always @(posedge clock)
    begin
        pcOut <= pc;
//	if (insn_valid == 1) begin
//            irOut <= insn;
//	end else begin
//	    irOut <= 32'h0000_0000;
//	end
	stalled_insn <= insn;
	//writeback_data_forward <= writeBackData;
	//$display("wb_data: %d wb_data_f: %d rs_data: %d rt_data: %d", writeBackData, writeback_data_forward, rsData, rtData);

    end // always @ (posedge clock)

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

	rdOut <= rd;
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
		    rdOut <= rt;
                end
                6'b001010: begin //SLTI
                    control[`REG_WE] = 1;
                    control[`I_TYPE] = 1'b1;
		    rdOut <= rt;
                end
                6'b100011: begin //LW
                    control[`REG_WE] = 1;
                    control[`I_TYPE] = 1'b1;
                    control[`MEM_WB] = 1'b1;                    
                    control[`MEM_READ] = 1'b1;
		    rdOut <= rt;
                end
                6'b101011: begin //SW
                    control[`REG_WE] = 0;
                    control[`MEM_WE] = 1'b1;
                    control[`I_TYPE] = 1'b1;
		    rdOut <= rt;
                end
                6'b001111: begin //LUI
                    control[`REG_WE] = 1;
                    control[`I_TYPE] = 1'b1;
		    rdOut <= rt;
                end
                6'b001101: begin //ORI
                    control[`REG_WE] = 1'b1;
                    control[`I_TYPE] = 1'b1;
    	            control[`LINK] = 1'b1;
		    rdOut <= rt;
		    
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
		    rdOut <= 31;
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

    //alu_stage_rd,
    //mem_stage_rd,
    //writeback_stage_rd, 
    always @(posedge clock)
      begin
      //Stall on RAW between decode and Execute, Memory, or Writeback stage
      //TODO: we might stall on NOP, because it is R type ... 
	  //stall = 1'b0;
	  if (insn_valid == 0) begin
	      stall = 1'b1;
	  end
	  
	  if (alu_branch_taken) begin
	    $display("branch taken flush");
	    irOut <= nop_insn;
	    rdOut <= 0;
	    control[`REG_WE] <= 0;
	  end else begin
	      irOut <= insn;
	  end
      if (opcode == 6'b000000 || opcode == `BEQ || opcode == `BNE || opcode == `SW) begin
	      if (should_stall_rs || should_stall_rt) begin
		      stall = 1'b1;
		      irOut <= nop_insn;
		      rdOut <= 0;
		      control[`REG_WE] <= 0;
              if (opcode == `SW) begin
                  control[`MEM_WE] <= 0;
              end
	      end else begin
            stall = 1'b0;
	      end 
    end else if (opcode == `ADDIU || opcode == `SLTI || opcode == `LUI || opcode == `ORI) begin
          if (should_stall_rt) begin
		      stall = 1'b1;
		      irOut <= nop_insn;
		      rdOut <= 0;
		      control[`REG_WE] <= 0;
	      end else begin
              stall = 1'b0;
          end
    end else if (opcode == `LW || opcode == `BGTZ || 
        opcode == `BLEZ || opcode == 6'b000001) begin
          if (should_stall_rs) begin
		      stall = 1'b1;
		      irOut <= nop_insn;
		      rdOut <= 0;
		      control[`REG_WE] <= 0;
              if (opcode == `LW) begin
                  control[`MEM_WB] <= 1'b0;                    
                  control[`MEM_READ] <= 1'b0;
              end
	      end else begin
                  stall = 1'b0;
          end
	  end else
	    stall = 1'b0;
      end 
    
endmodule
