//
// alu_tb.v
//
// ALU test bench
//

`include "control.vh"
`include "alu_func.vh"

module alu_tb;
    reg clock;
    reg[0:31] rsData;
    reg[0:31] rtData;
    reg[0:`CONTROL_REG_SIZE-1] control;
    reg[0:5] funct;
    reg[0:5] sa;
    wire[0:31] aluOutput;
    

    alu DUT(
        .clock (clock),
	.rsData (rsData),
        .rtData (rtData),
	.control (control),
	.funct (funct),
	.outData (aluOutput),
	.sa (sa)
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
	#10 $finish;
    end

    initial begin

	@ (posedge clock);
	rsData = 32'h00000005;
	rtData = 32'h00000002;
	//arithmetic function set to ADD
	funct = `ADD;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for 5 + 2: %d", aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000002;
	//arithmetic function set to ADD
	funct = `ADD;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d + %d : %d",$signed(rsData), rtData, aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000001;
	//arithmetic function set to ADDU
	funct = `ADDU;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d + %d (unsigned): %d",rsData, rtData, aluOutput);

	rsData = 32'h00000004;
	rtData = 32'h00000002;
	funct = `SUB;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d - %d : %d",rsData, rtData, aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000007;
	funct = `SUBU;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d - %d (unsigned): %d",rsData, rtData, aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000007;
	funct = `SLT;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d < %d : %d", $signed(rsData), rtData, aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000007;
	funct = `SLTU;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d < %d (unsigned): %d",rsData, rtData, aluOutput);

	rsData = 32'h00000002;
	rtData = 32'h00000002;
	sa = 5'b00010;
	funct = `SLL;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d << %d: %d", rtData, sa, aluOutput);

	rsData = 32'h00000002;
	rtData = 32'h00000002;
	sa = 5'b00010;
	funct = `SRL;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d >> %d: %d", rtData, sa, aluOutput);

	rsData = 32'h00000002;
	rtData = 32'h00000001;
	sa = 5'b00010;
	funct = `SRA;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d >>> %d: %d", rtData, sa, aluOutput);

	rsData = 32'h00040a02;
	rtData = 32'hffffffff;
	funct = `AND;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h AND %h: %h", rsData, rtData, aluOutput);

	rsData = 32'h00040a02;
	rtData = 32'hffff0000;
	funct = `OR;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h OR %h: %h", rsData, rtData, aluOutput);

	rsData = 32'h00040a02;
	rtData = 32'hffffffff;
	funct = `XOR;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h XOR %h: %h", rsData, rtData, aluOutput);

	rsData = 32'h00040a02;
	rtData = 32'hffffffff;
	funct = `NOR;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h NOR %h: %h", rsData, rtData, aluOutput);

	-> terminate_sim;
    end

	
endmodule