//
// writeback_stage_tb.v
//
// Testbench for the writeback stage
// includes all previous stages
//

module writeback_stage_tb;
    reg clock;

    wire[0:31] srec_address;
    wire       srec_wren;
    wire[0:31] srec_data_in;
    wire[0:31] srec_data_out;
    wire       srec_done;

    wire[0:31] mcu_address;
    wire       mcu_wren;
    wire[0:31] mcu_data_in;
    wire[0:31] mcu_data_out;

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

    reg[0:31]  alu_rs_data_res;
    reg[0:31]  alu_rt_data_res;
    reg[0:31]  alu_insn;
    wire[0:31] alu_output;
    wire 	   alu_bt;
    wire[0:31] alu_rt_data_out;
    wire[0:31] alu_insn_out;
    reg [0:31] alu_pc_res;
    wire[0:`CONTROL_REG_SIZE-1] alu_control_out;
   
    wire[0:31] mem_stage_address;
    wire[0:31] mem_stage_address_out;
    wire[0:31] mem_stage_data_in;
    wire[0:31] mem_stage_data_out;
    wire[0:`CONTROL_REG_SIZE-1] mem_stage_control_in;
    wire[0:`CONTROL_REG_SIZE-1] mem_stage_control_out;
    wire[0:31] mem_stage_mem_data_out;
    reg[0:`CONTROL_REG_SIZE-1]  mem_stage_srec_read_control;
    

    wire[0:31] bytes_read;
    integer    byte_count;
    reg        instruction_valid;

    event      terminate_sim;

    srec_parser #("srec_files/SimpleIf.srec") U0(
        .clock (clock),
        .mem_address (srec_address),
        .mem_wren (srec_wren),
        .mem_data_in (srec_data_in),
        .mem_data_out (srec_data_out),
        .done (srec_done),
        .bytes_read(bytes_read)
    );

    mem_controller mcu(
        .clock (clock), 
        .address (mcu_address), 
        .wren (mcu_wren), 
        .data_in (mcu_data_in), 
        .data_out (mcu_data_out)
    );

    fetch F0(
        .clock (clock), 
        .address (fetch_address),
        .insn (fetch_data_in),
        .insn_decode (fetch_data_out),
        .pc (fetch_pc),
        .wren (fetch_wren),
        .stall (fetch_stall)
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
        .control_out (alu_control_out),
	    .outData (alu_output),
	    .bt (alu_bt),
	    .insn (decode_ir_out),
        .insn_out(alu_insn_out),
        .rtDataOut(alu_rt_data_out),
	    .pc (decode_pc_out)
    );

    mem_stage DUT(
        .clock (clock),
        .address (mem_stage_address),
        .data_in (mem_stage_data_in),
        .address_out (mem_stage_address_out),
        .mem_data_out (mem_stage_mem_data_out),
        .data_out (mem_stage_data_out),
        .control (mem_stage_control_in),
        .control_out (mem_stage_control_out)
    );
     
    assign mcu_address = srec_done ? fetch_address : srec_address;
    assign mcu_wren = srec_done ? fetch_wren : srec_wren;
    assign mcu_data_in = srec_done ? fetch_data_in : srec_data_in;
    assign fetch_data_in = mcu_data_out;    
   
    assign mem_stage_address = srec_done ? alu_output : srec_address;
    assign mem_stage_data_in = srec_done ? alu_rt_data_out : srec_data_in;
    assign mem_stage_control_in = srec_done ? alu_control_out : mem_stage_srec_read_control;

    // Specify when to stop the simulation
    initial begin 
        @ (terminate_sim);
        #10 $finish;
    end
   
    // Initial setup
    initial begin
        clock = 1;
        fetch_stall = 1;
        instruction_valid = 1'b0;
        mem_stage_srec_read_control = 0;
        mem_stage_srec_read_control[`MEM_WE] = 1;
    end

    // Clock process
    always begin
        #5 clock = !clock;
    end 

    // Debug dump
    initial begin
        $dumpfile("writeback_stage_tb.vcd");
        $dumpvars;
    end

    // Register feed process
    always @ (posedge clock) begin
        alu_insn <= fetch_data_out;
        alu_pc_res <= decode_pc_out;        
        alu_rs_data_res <= decode_rs_data;
        alu_rt_data_res <= decode_rt_data;
    end

    // Fetch and Decode process
    initial begin
        @ (posedge srec_done);
        @ (posedge clock);
        byte_count = bytes_read + 4;
        instruction_valid = 1'b0;
        fetch_stall = 0;
        
        while (byte_count > 0) begin
            @ (posedge clock);
            //$display("Fetch Address %X", fetch_address);
            if (fetch_address < 32'h8002_0000) begin
                instruction_valid = 1'b0;
            end else begin
                instruction_valid = 1'b1;
            end
            // debug
            if (fetch_stall == 0) begin
                byte_count = byte_count - 4;
                fetch_stall <= 1;                
            end
            //$display("ALU address out: %X", alu_output);
            //$display("Time: %d, mem_stage address_out %x, mem_stage data_out %x, mem_stage mem_data_out, %x control out %x", 
            //         $time, mem_stage_address_out, mem_stage_data_out, mem_stage_mem_data_out, mem_stage_control_out);
        end

        // The decode runs one clock cycle behind the fetch
        @ (posedge clock);
        // allow the last alu op to run
        @ (posedge clock);
        @ (posedge clock);        
        ->terminate_sim;
    end // initial begin

    // ALU process    
    initial begin
        @ (posedge srec_done);
        @ (posedge clock);
        
        while (byte_count > 0) begin
            @ (posedge clock);           
            fetch_stall <= 0; // a quick way to insert a NOP after every fetch to see if it actually works              
            $display("Time: %d, Inp insn: %X, Inp PC: %X, Inp RS: %d, Inp RT: %d, ALU_RESULT: %d",
                     $time, alu_insn_out, alu_pc_res, alu_rs_data_res, alu_rt_data_res, alu_output);
        end
        // allow the last decode to run
        @ (posedge clock);
        @ (posedge clock);
        $display("Time: %d, Inp insn: %X, Inp PC: %X, Inp RS: %d, Inp RT: %d, ALU_RESULT: %d",
                 $time, alu_insn_out, alu_pc_res, alu_rs_data_res, alu_rt_data_res, alu_output);
    end
    
endmodule
