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
    reg[0:15] immediate;
    reg[0:31] insn;
    wire [0:31] aluOutput;
    reg [0:31] pc;

    alu DUT(
        .clock (clock),
	.rsData (rsData),
        .rtData (rtData),
	.control (control),
	.outData (aluOutput),
	.insn (insn),
	.pc (pc)
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
	control[`R_TYPE] = 1'b1;
	control[`I_TYPE] = 1'b0;
	pc = 0;
	rsData = 32'h00000005;
	rtData = 32'h00000002;

	//arithmetic function set to ADD
	insn = 32'h00000000 | `ADD;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for 5 + 2: %d", aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000002;
	//arithmetic function set to ADD
	insn = 32'h00000000 | `ADD;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d + %d : %d",$signed(rsData), rtData, aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000001;
	//arithmetic function set to ADDU
	insn = 32'h00000000 | `ADDU;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d + %d (unsigned): %d",rsData, rtData, aluOutput);

	rsData = 32'h00000004;
	rtData = 32'h00000002;
	insn = 32'h00000000 | `SUB;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d - %d : %d",rsData, rtData, aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000007;
	insn = 32'h00000000 | `SUBU;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d - %d (unsigned): %d",rsData, rtData, aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000007;
	insn = 32'h00000000 | `SLT;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d < %d : %d", $signed(rsData), rtData, aluOutput);

	rsData = -32'h00000002;
	rtData = 32'h00000007;
	insn = 32'h00000000 | `SLTU;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d < %d (unsigned): %d",rsData, rtData, aluOutput);

	rsData = 32'h00000002;
	rtData = 32'h00000002;
	sa = 5'b00010;
	
	insn = 32'h00000000 | `SLL | (5'b00010 << 6);
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d << %d: %d", rtData, sa, aluOutput);

	rsData = 32'h00000002;
	rtData = 32'h00000002;
	sa = 5'b00010;
	insn = 32'h00000000 | `SRL | (5'b00010 << 6);
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d >> %d: %d", rtData, sa, aluOutput);

	rsData = 32'h00000002;
	rtData = 32'h00000001;
	sa = 5'b00010;
	insn = 32'h00000000 | `SRA | (5'b00010 << 6);
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d >>> %d: %d", rtData, sa, aluOutput);

	rsData = 32'h00040a02;
	rtData = 32'hffffffff;
	insn = 32'h00000000 | `AND;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h AND %h: %h", rsData, rtData, aluOutput);

	rsData = 32'h00040a02;
	rtData = 32'hffff0000;
	insn = 32'h00000000 | `OR;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h OR %h: %h", rsData, rtData, aluOutput);

	rsData = 32'h00040a02;
	rtData = 32'hffffffff;
	insn = 32'h00000000 | `XOR;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h XOR %h: %h", rsData, rtData, aluOutput);

	rsData = 32'h00040a02;
	rtData = 32'hffffffff;
	insn = 32'h00000000 | `NOR;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h NOR %h: %h", rsData, rtData, aluOutput);

	control[`I_TYPE] = 1'b1;
	control[`R_TYPE] = 1'b0;

	rsData = 32'h00000008;
	immediate = 16'h0007;
	insn = 32'h00000000 | (`ADDIU << 26) | 16'h0007;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d + %d: %d (immediate unsigned)", rsData, immediate, aluOutput);

	rsData = 32'h00000008;
	immediate = 16'h0007;
	insn = 32'h00000000 | (`SLTI << 26) | 16'h0007;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d < %d: %d (immediate)", rsData, immediate, aluOutput);

	rsData = 32'h00000007;
	immediate = 16'h0008;
	insn = 32'h00000000 | (`SLTI << 26) | 16'h0008;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %d < %d: %d (immediate)", rsData, immediate, aluOutput);


	immediate = 16'h0007;
	insn = 32'h00000000 | (`LUI << 26) | 16'h0007;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for load upper immediate: %h -> %h ",immediate, aluOutput);

	rsData = 32'h0000ffff;
	immediate = 16'h0007;
	insn = 32'h00000000 | (`ORI << 26) | 16'h0007;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for %h ORI %h: %h (immediate)", rsData, immediate, aluOutput);

	control[`I_TYPE] = 1'b0;
	control[`R_TYPE] = 1'b0;
	control[`J_TYPE] = 1'b1;

	insn = 32'h00000000 | (`J << 26) | 32'h000000ff;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for J %h", aluOutput);

	rsData = 32'h00000001;
	rtData = 32'h00000001;
	insn = 32'h00000000 | (`BEQ << 26) | 32'h0000dead;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for BEQ %h", aluOutput);

	rsData = 32'h00000101;
	rtData = 32'h00000001;
	insn = 32'h00000000 | (`BEQ << 26) | 32'h0000dead;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for BEQ %h", aluOutput);

		rsData = 32'h00000001;
	rtData = 32'h00000001;
	insn = 32'h00000000 | (`BNE << 26) | 32'h0000dead;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for BNE %h", aluOutput);

	rsData = 32'h00000101;
	rtData = 32'h00000001;
	insn = 32'h00000000 | (`BNE << 26) | 32'h0000dead;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for BNE %h", aluOutput);

	rsData = 32'h00000101;
	insn = 32'h00000000 | (`BGTZ << 26) | 32'h0000beef;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for BGTZ %h (taken)", aluOutput);

	rsData = 32'h00000101;
	insn = 32'h00000000 | (`BLEZ << 26) | 32'h0000beef;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for BLEZ %h (not taken)", aluOutput);


	rsData = 32'h00000101;
	insn = 32'h00000000 | (`REGIMM << 26) | 32'h0000beef;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for BLTZ %h (not taken)", aluOutput);

	rsData = 32'h00000101;
	insn = 32'h00000000 | (`REGIMM << 26) | (`BGEZ << 16) | 32'h0000beef;
	@ (posedge clock);
	@ (posedge clock);
	$display("ALU output for BGEZ %h (taken)", aluOutput);

	
	

	


	-> terminate_sim;
    end

	
endmodule