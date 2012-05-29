//
// decode_tb.v
//
// Decode test bench
//

module decode_tb;
    reg clock;
    reg	i_valid;
    reg[0:31] insn;
    reg [0:31] pc;   

    wire[0:1] insn_type;
    wire[5:0] opcode;
    wire[4:0] rs;
    wire[4:0] rt;
    wire[4:0] rd;
    wire[4:0] shift_amount;
    wire[5:0] funct;
    wire[15:0] immediate;
    wire[25:0] j_address;

    decode DUT(
        .clock (clock),
        .insn (insn),
	    .insn_valid (i_valid),
        .pc (pc)
    );

    // initialization of the test bench
    initial begin
        clock = 1;
    end

    // clock signal
    always begin
        #5 clock = !clock;
    end

    // Specify when to stop the simulation
    event terminate_sim;
    initial begin 
        @ (terminate_sim);
        #10 $finish;
    end

    // TEST CASES BEGIN HERE
    initial begin

        @ (posedge clock);
        i_valid = 1'b1;
       
        //ADD
        //         | op || rs|| rt|| rd|| sh|| fu |
        insn = 32'b00000000101110000011001010100000;
        @ (posedge clock);

        //ADDU
        insn = 32'b00000000001000110001000000100001;
        @ (posedge clock);

        //SUB
        insn = 32'b00000000000000100001100001100010;
        @ (posedge clock);

        //SUBU
        insn = 32'b00000000000000100001100001100011;
        @ (posedge clock);

        //SLT
        insn = 32'b00000000000000100001100001101010;
        @ (posedge clock);

        //SLTU
        insn = 32'b00000000000000100001100001101011;
        @ (posedge clock);

         //SLL
        insn = 32'b00000000000000100001100001000000;
        @ (posedge clock);

        //SRL
        insn = 32'b00000000000000100001100001000010;
        @ (posedge clock);

        //SRA
        insn = 32'b00000000000000100001100001000011;
        @ (posedge clock);

         //AND
        insn = 32'b00000000000000100001100001100100;
        @ (posedge clock);

        //OR
        insn = 32'b00000000000000100001100001100101;
        @ (posedge clock);

        //XOR
        insn = 32'b00000000000000100001100001100110;
        @ (posedge clock);

        //NOR
        insn = 32'b00000000000000100001100001100111;
        @ (posedge clock);

        //ADDIU
        insn = 32'b00100111101111011111111111001001;
        @ (posedge clock);

        //SLTI
        insn = 32'b00101000000000100001100001001001;
        @ (posedge clock);

        //LW
        insn = 32'b10001100000000100001100001001001;
        @ (posedge clock);

        //SW
        insn = 32'b10101100000000100001100001001001;
        @ (posedge clock);

        //LUI
        insn = 32'b00111100000000100001100001001111;
        @ (posedge clock);

        //ORI
        insn = 32'b00110100000000100001100001001101;
        @ (posedge clock);

        //J
        insn = 32'b00001000000000100001100001000010;
        @ (posedge clock);

        //BEQ
        insn = 32'b00010000000000100001100001000100;
        @ (posedge clock);

        //BNE
        insn = 32'b00010100000000100001100001000101;
        @ (posedge clock);

        //BGTZ
        insn = 32'b00011100000000100001100001000111;
        @ (posedge clock);

        //BLEZ
        insn = 32'b00011000000000100001100001000110;
        @ (posedge clock);

        //BLTZ
        insn = 32'b00000100000000000000000001000001;
        @ (posedge clock);
                
        //BGEZ
        insn = 32'b00000100000000010100100001000001;
        @ (posedge clock);
                
        //
        // signal to end the simulation
        -> terminate_sim;

    end

endmodule // decode_tb


