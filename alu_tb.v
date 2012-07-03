//
// alu_tb.v
//
// ALU test bench
//

`include "control.vh"

module alu_tb;
    reg clock;
    reg[0:31] rsData;
    reg[0:31] rtData;
    reg[0:`CONTROL_REG_SIZE-1] control;
    reg[0:5] funct;

    alu DUT(
        .clock (clock),
	.rsData (rsData),
        .rtData (rtData),
	.control (control),
	.funct (funct)
    );

    initial begin
	clock = 1;
    end

    always begin
	#5 clock = !clock;
    end

    event terminate_sim;
    initial begin
	@ (terminate_sim);
	#10 finish;
    end

    initial begin

	@ (posedge clock);
	rsData = 32'h00000005;
	rtData = 32'h00000002;
	//arithmetic function set to ADD
	funct = 6'b100000;
    end

	
endmodule