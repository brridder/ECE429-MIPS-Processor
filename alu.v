//
// alu.v
//
//

`include "control.vh"
`include "alu_func.vh"

module alu (
    clock,
    rsData,
    rtData,
    rtDataOut,
    control,
    control_out,
    outData,
    bt,
    insn,
    insn_out,
    pc,
    rdIn,
    rdOut
);

    input wire clock;
    input wire [0:31] rsData;
    input wire [0:31] rtData;

    input wire [0:`CONTROL_REG_SIZE-1] control;
    input wire [0:31] insn;
    input wire [0:31] pc;
    input wire [0:4]  rdIn;

    wire [0:5] opcode;
    wire [5:0] funct;
    wire [0:5] sa;
    wire [0:15] immediate;
    wire [0:25] insn_index;
    wire [0:17] offset;
    wire [0:4]  rt;


    output reg[0:31] outData;
    output reg bt; //branch taken
    output reg[0:31] insn_out;
    output reg[0:31] rtDataOut;
    output reg[0:`CONTROL_REG_SIZE-1] control_out;
    output reg[0:4] rdOut;
    
    assign opcode = insn[0:5];
    assign rt = insn[11:15];
    assign sa = insn[20:25];
    assign funct = insn[26:31];
    assign immediate = insn[16:31];
    assign offset = insn[16:31];
    assign insn_index = insn[6:31];

    always @(posedge clock)
    begin
	rdOut <= rdIn;
    end
	
    always @(posedge clock)
    begin
	    bt = 0;          
	    if (control[`R_TYPE]) begin
	        case(funct)
	            `ADD:
	              //rd <- rs + rt
	              outData = rsData + rtData;
	            `ADDU:
	              //todo: do we need to treat unsigned specially?
	              outData = $unsigned(rsData) + $unsigned(rtData);
	            `SUB:
	              outData = rsData - rtData;
	            `SUBU:
	              //todo: correct way to do unsigned?
	              outData = $unsigned(rsData) - $unsigned(rtData);
	            `SLT: // rd <- 1 if rs < rt; else rd <- 0
	              if ($signed(rsData) < $signed(rtData)) begin
	                  outData = 32'h00000001;
	              end else begin
	                  outData = 32'h00000000;
	              end
	            `SLTU:
	              if ($unsigned(rsData) < $unsigned(rtData)) begin
	                  outData = 32'h0000001;
	              end else begin 
	                  outData = 32'h00000000; 
	              end
	            `SLL:
	              outData = rtData << sa;
	            `SRL:
	              outData = rtData >> sa;
	            `SRA:
	              outData = rtData >>> sa;
	            `AND:
	              outData = rsData & rtData;
	            `OR:
	              outData = rsData | rtData;
	            `XOR:
	              outData = rsData ^ rtData;
	            `NOR:
	              outData = ~(rsData | rtData);
	        endcase // case (funct)
	    end else if(control[`I_TYPE]) begin
	        case(opcode)
	            `ADDIU:
		          outData = rsData + $signed(immediate);
	            `SLTI:
		          if ($signed(rsData) < $signed(immediate)) begin
		              outData = 32'h0000001;
		          end else begin
		              outData = 32'h0000000;
		          end
	            `LW:
		          outData = $signed(offset) + rsData;
	            `SW:
		          outData = $signed(offset) + rsData;
	            `LUI:
		          outData = immediate << 16;
	            `ORI:
		          outData = rsData | immediate;
	        endcase // case (funct)
	    end else if (control[`J_TYPE]) begin
            case(opcode)
	            `J:
		          //outData = insn_index;
	              bt = 1'b1;
		        
	            `BEQ:
		          if (rsData == rtData) begin
		              outData = pc + $signed(offset << 2);
		              bt = 1'b1;
		          end else begin
		              bt = 1'b0;
		          end
	            `BNE:
		          if  (rsData  != rtData) begin
		              outData = pc + $signed(offset << 2);
		              bt = 1'b1;
		          end else begin
		              bt = 1'b0;
		          end
	            `BGTZ:
		          if ($signed(rsData) > 1'b0) begin
		              outData = pc + $signed(offset << 2);
		              bt = 1'b1;
		          end else begin
		              bt = 1'b0;
		          end
	            `BLEZ:
		          if ($signed(rsData) <= 1'b0) begin
		              outData = pc + $signed(offset << 2);
		          end else begin
		              bt = 1'b0;
		          end

	            `REGIMM:
		          case(rt)
		              `BLTZ:
		                if ($signed(rsData) < 1'b0) begin
			                outData = pc + $signed(offset << 2);
			                bt = 1'b1;
		                end else begin
			                bt = 1'b0;
		                end
		              `BGEZ:
		                if ($signed(rsData) >= 1'b0) begin
			                outData = pc + $signed(offset << 2);
			                bt = 1'b1;
		                end else begin
			                bt = 1'b0;
		                end
		          endcase // case (rtData)
	        endcase // case (funct)
	    end else begin
            outData = 32'h0000_0000;
        end        
    end
    
    always @(posedge clock)
    begin
        insn_out = insn;
    end

    always @(posedge clock)
    begin
        rtDataOut = rtDataOut;
    end
    
    always @(posedge clock)
    begin
        control_out = control;
    end

endmodule

    
