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
        insn = 32'b11111111011001001100101010000000;
        $display("inst type is (clk 1) %d", insn_type);
        $display("rs is (clk1) %d", rs);
        @ (posedge clock);
        // wait fot the result
        @ (posedge clock);
        // check the result
        if (check_r_type(rs, 5'b01010,
                         rt, 5'b11001,
                         rd, 5'b00100,
                         shift_amount, 5'b11011,
                         funct, 6'b111111) == 0)
        begin
            failed_count = failed_count + 1;
            $display("ADD test failed");
        end
        
        $display("inst type is (clk 3) %d", insn_type );
        $display("rs is (clk3) %d", rs);
        $display("rt is (clk3) %d", rt);
        $display("rd is (clk3) %d", rd);
        $display("sh is (clk3) %d", shift_amount);
        $display("fu is (clk3) %d", funct);

        $display("Tests ran:    %d", test_count);
        $display("Tests failed  %d", failed_count);
        
        //
        // signal to end the simulation
        -> terminate_sim;

    end
   
    

endmodule // decode_tb


