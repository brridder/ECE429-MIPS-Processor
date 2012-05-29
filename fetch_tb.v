//
// fetch_tb.v
//
// Fetch test bench
//

module fetch_tb;
    reg clock;

    wire[0:31] address;
    wire       wren;
    wire[0:31] data_in;
    wire[0:31] data_out;

    wire[0:31] fetch_address;
    wire       fetch_wren;
    wire[0:31] fetch_data_in;
    wire[0:31] fetch_data_out;
    
    wire[0:31] fetch_insn_decode;
    wire[0:31] fetch_pc;
    reg        fetch_stall; 
    
    wire[0:31] srec_address;
    wire       srec_wren;
    wire[0:31] srec_data_in;
    wire[0:31] srec_data_out;

    wire       srec_done;

    reg[0:31]  tb_address;
    reg        tb_wren;
    reg[0:31]  tb_data_in;
    wire[0:31] tb_data_out;

    
    wire[0:31] bytes_read;
    integer    byte_count;
    integer    read_word;
    reg[0:31]    fetch_word;

    reg instruction_valid;

    mem_controller mcu(
        .clock (clock), 
        .address (address), 
        .wren (wren), 
        .data_in (data_in), 
        .data_out (data_out)
    );

    fetch DUT(
        .clock (clock), 
        .address (fetch_address),
        .insn (fetch_data_in),
        .insn_decode (fetch_data_out),
        .pc (fetch_pc),
        .wren (fetch_wren),
        .stall (fetch_stall)
    );
    
    srec_parser #("srec_files/SumArray.srec") U0(
        .clock (clock),
        .mem_address (srec_address),
        .mem_wren (srec_wren),
        .mem_data_in (srec_data_in),
        .mem_data_out (srec_data_out),
        .done (srec_done),
        .bytes_read(bytes_read)
    );

    decode U1(
        .clock (clock),
        .insn (fetch_word),
	.insn_valid (instruction_valid)
    );
   
    assign address = srec_done ? (fetch_stall ? tb_address : fetch_address) : srec_address;
    assign wren = srec_done ? (fetch_stall ? tb_wren : fetch_wren) : srec_wren;
    assign tb_data_out = data_out;
    assign fetch_data_in = data_out;
    assign data_in = srec_done ? (fetch_stall ? tb_data_in : fetch_data_in) : srec_data_in;

    // Specify when to stop the simulation
    event terminate_sim;
    initial begin 
        @ (terminate_sim);
        #10 $finish;
    end
   
    initial begin
        clock = 1;
        fetch_stall = 1;
        instruction_valid = 1'b0;
    end

    always begin
        #5 clock = !clock;
    end 

    initial begin
        $dumpfile("fetch_tb.vcd");
        $dumpvars;
    end

    initial begin
        @(posedge srec_done);
        @(posedge clock);
        byte_count = bytes_read;
        tb_address = 32'h8002_0000;
        tb_wren = 1'b0;
        instruction_valid = 1'b0;
        fetch_stall = 0;   
        while (byte_count > 0) begin
            @(posedge clock);
            if ((fetch_address - 4) < 32'h8002_000) begin
                instruction_valid = 1'b0;
            end else begin
                instruction_valid = 1'b1;
            end

	        read_word = tb_data_out;
            fetch_word = fetch_data_out;

            if (fetch_address-4 >= 32'h8002_0000) begin

                $display("PC: %X, Instruction: %b", fetch_address - 4, fetch_word);
            end
            tb_address = tb_address + 4;
            byte_count = byte_count - 4; // 27 = 0010 011
        end
        instruction_valid = 1'b0;
        ->terminate_sim;
    end

endmodule
