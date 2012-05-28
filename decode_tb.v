//
// decode_tb.v
//
// Decode test bench
//

module decode_tb;
    reg clock;
    reg[0:31] insn;

    wire[0:1]  insn_type;
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
        .insn_type (insn_type),
        .opcode (opcode),
        .rs (rs),
        .rt (rt),
        .rd (rd),
        .shift_amount (shift_amount),
        .funct (funct),
        .immediate (immediate),
        .j_address (j_address)
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
        //
        // ADD instruction testcase
        @ (posedge clock);
        //          | fu || sh|| rd|| rt|| rs|| op |
        insn = 32'b11111111011001001000101010000000;
        $display("inst type is %d", insn_type);
        @ (posedge clock);
        @ (posedge clock);
        $display("inst type is %d", insn_type );


        //
        // signal to end the simulation
        -> terminate_sim;

    end
   
    

endmodule // decode_tb


