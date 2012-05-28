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

    reg [0:7]   test_count;
    reg [0:7]   failed_count;
   
    decode DUT(
        .clock (clock),
        .insn (insn)
    );

    function check_r_type;
        input actual_rs, expected_rs;
        input actual_rt, expected_rt;
        input actual_rd, expected_rd;
        input actual_shift_amount, expected_shift_amount;
        input actual_funct, expected_funct;
        
        if (actual_rs != expected_rs ||
            actual_rt != expected_rt ||
            actual_rd != expected_rd ||
            actual_shift_amount != expected_shift_amount ||
            actual_funct != expected_funct)
        begin
            check_r_type = 0;
        end
        else
        begin
            check_r_type = 1;
        end
    endfunction
         
    // initialization of the test bench
    initial begin
        clock = 1;
        test_count = 8'h00;
        failed_count = 8'h00;
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
        test_count = test_count + 1;
        //         | fu || sh|| rd|| rt|| rs|| op |
        // 100000 | 00000 |00010| 00011 | 00001  | 000000|

       //ADD
       insn = 32'b10000000000000100001100001000000;
        @ (posedge clock);

       //ADDU
        insn = 32'b10000100000000100001100001000000;
       @ (posedge clock);

       //SUB
        insn = 32'b10001000000000100001100001000000;
       @ (posedge clock);

       //SUBU
        insn = 32'b10001100000000100001100001000000;
       @ (posedge clock);
       
        // wait fot the result
       // @ (posedge clock);
        // check the result
     
        
        //
        // signal to end the simulation
        -> terminate_sim;

    end
   
    

endmodule // decode_tb


