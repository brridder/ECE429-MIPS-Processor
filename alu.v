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
    control,
    funct,
    outData,
    sa
);

    input wire clock;
    input wire [0:31] rsData;
    input wire [0:31] rtData;

    input wire [0:`CONTROL_REG_SIZE-1] control;
    input wire [5:0] funct;
    input wire [0:5] sa;

    output reg [0:31] outData;

    always @(posedge clock)
      begin
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
    end


    

endmodule

    