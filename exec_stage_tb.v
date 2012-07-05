//
// exec_stage_tb.v
//
// Testbench for the execute stage
//   includes fetch, decode, and alu
//

module exec_stage_tb;
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
   
    wire[0:31] decode_rs_data;
    wire[0:31] decode_rt_data;
    wire[4:0]  decode_rd_in;
    wire[0:31] decode_pc_out;
    wire[0:31] decode_ir_out;
    wire[0:31] decode_write_back_data;
    wire       decode_reg_write_enable;
    wire [0:`CONTROL_REG_SIZE-1] decode_control;

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
    reg[0:31]  fetch_word;
    reg        instruction_valid;

    // alu
    reg[0:31] alu_rs_data_res;
    reg[0:31] alu_rt_data_res;
    reg[0:31] alu_insn;
    reg[0:31] alu_insn_res;
    wire [0:31] alu_output;
    wire bt;
    reg [0:31] alu_pc_res;
    reg [0:`CONTROL_REG_SIZE-1] alu_control_res;
   
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
    
    srec_parser #("srec_files/BubbleSort.srec") U0(
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
        .insn (fetch_data_out),
	    .insn_valid (instruction_valid),
        .pc (fetch_address),
        .rsData (decode_rs_data),
        .rtData (decode_rt_data),
        .rdIn (decode_rd_in),
        .pcOut (decode_pc_out),
        .irOut (decode_ir_out),
        .writeBackData (decode_write_back_data),
        .regWriteEnable (decode_reg_write_enable),
        .control (decode_control)
    );

    alu alu(
        .clock (clock),
	    .rsData (decode_rs_data),
        .rtData (decode_rt_data),
	    .control (decode_control),
	    .outData (alu_output),
	    .bt (alu_bt),
	    .insn (alu_insn),
	    .pc (decode_pc_out)
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
        $dumpfile("exec_stage_tb.vcd");
        $dumpvars;
    end

    
    always @(posedge clock) begin
        alu_insn <= fetch_data_out;
        alu_insn_res <= alu_insn;        
        alu_control_res <= decode_control;
        alu_pc_res <= decode_pc_out;        
        alu_rs_data_res <= decode_rs_data;
        alu_rt_data_res <= decode_rt_data;
    end
    

    initial begin
        @(posedge srec_done);
        @(posedge clock);
        byte_count = bytes_read+4;
        tb_address = 32'h8002_0000;
        tb_wren = 1'b0;
        instruction_valid = 1'b0;
        fetch_stall = 0;
        
        while (byte_count > 0) begin
            @(posedge clock);
            if ((fetch_address - 4) < 32'h8002_0000) begin
                instruction_valid = 1'b0;
            end else begin
                instruction_valid = 1'b1;
            end
	        read_word = tb_data_out;
            fetch_word = fetch_data_out;

            tb_address = tb_address + 4;
            byte_count = byte_count - 4; 
        end

        // The decode runs one clock cycle behind the fetch
        @(posedge clock);
        tb_address = tb_address + 4;
        instruction_valid = 1'b0;

        // allow the last alu op to run
        @(posedge clock);
        @(posedge clock);        
        ->terminate_sim;
    end // initial begin

    // ALU Process
    initial begin
        @(posedge srec_done);
        @(posedge clock);
        
        while (byte_count > 0) begin
            @(posedge clock);           

            $display("Time: %d, Input insn: %X, Input PC: %X, Input RS: %d, Input RT: %d, ALU_RESULT: %d",
                     $time, alu_insn_res, alu_pc_res, alu_rs_data_res, alu_rt_data_res, alu_output);

        end
        // allow the last decode to run
        @(posedge clock);
        @(posedge clock);
        $display("Time: %d, Input insn: %X, Input PC: %X, Input RS: %d, Input RT: %d, ALU_RESULT: %d",
                 $time, alu_insn_res, alu_pc_res, alu_rs_data_res, alu_rt_data_res, alu_output);
    end
    
endmodule
