// 
// pipeline.v
//
// The five stages all put together finally.
//

`include "alu_func.vh"
`include "control.vh"

module pipeline(
    clock,
    program_done
);

    input wire clock;
    output reg program_done;
    // SREC parser
    wire[0:31]  srec_address;
    wire        srec_wren;
    wire[0:31]  srec_data_in;
    wire[0:31]  srec_data_out;
    wire        srec_done;
    wire[0:31]  srec_bytes_read;

    // Memory Control Unit - Instruction memory
    wire[0:31]  mcu_address;
    wire        mcu_wren;
    wire[0:31]  mcu_data_in;
    wire[0:31]  mcu_data_out;

    // Fetch stage
    wire[0:31]  fetch_address;
    wire        fetch_wren;
    wire[0:31]  fetch_data_in;
    wire[0:31]  fetch_data_out;
    wire[0:31]  fetch_insn_decode;
    wire[0:31]  fetch_pc_out;
    
    wire[0:4]   fetch_rs_out;
    wire[0:4]   fetch_rt_out;
    wire        fetch_stall; 	

    // Decode Stage
    reg         decode_insn_valid;
    wire[0:31]  decode_insn_in;
    wire[0:31]  decode_rs_data;
    wire[0:31]  decode_rt_data;
    wire[0:4]   decode_rd_in;
    wire [0:4] 	decode_rd_out;
    wire[0:31]  decode_pc_out;
    wire[0:31]  decode_ir_out;
    wire[0:31]  decode_write_back_data;
    wire        decode_reg_write_enable;
    wire[0:`CONTROL_REG_SIZE-1] decode_control;
    reg         decode_dump_regs;
    wire        decode_stall_out;
    
    // Execute Stage
    wire[0:31]  alu_rt_data_out;
    wire[0:31]  alu_out_data;
    wire[0:`CONTROL_REG_SIZE-1] alu_control_out;
    wire        alu_branch_taken;
    wire[0:31]  alu_insn_out;
    wire [0:31] alu_insn_in;
    wire[0:4]   alu_rd_out;

    // Memory Stage
    wire[0:31]  mem_stage_address;
    wire[0:31]  mem_stage_address_out;
    wire[0:31]  mem_stage_mem_data_out;
    wire[0:31]  mem_stage_data_out;
    wire[0:31]  mem_stage_data_in;
    wire[0:`CONTROL_REG_SIZE-1] mem_stage_control_in;
    wire[0:`CONTROL_REG_SIZE-1] mem_stage_control_out;
    wire[0:4]   mem_stage_rd_out;
    reg         mem_stage_print_stack;
    reg[0:`CONTROL_REG_SIZE-1]  mem_stage_srec_read_control;
    
    // Writeback stage
    wire[0:4]   writeback_rd_out;


    reg[0:31]   nop_insn;
    reg         pipeline_stall;
    reg         instruction_valid; 
    // SREC Parser
    srec_parser #("srec_files/SimpleIf.srec") srec0(
        .clock          (clock),
        .mem_address    (srec_address),
        .mem_wren       (srec_wren),
        .mem_data_in    (srec_data_in),
        .mem_data_out   (srec_data_out),
        .done           (srec_done),
        .bytes_read     (srec_bytes_read)
    );
    
    // Memory Control Unit
    mem_controller mcu0(
        .clock          (clock),
        .address        (mcu_address),
        .wren           (mcu_wren),
        .data_in        (mcu_data_in),
        .data_out       (mcu_data_out),
	.print_stack    (1'b0)
    );

    // Fetch Stage
    fetch fetch0(
        .clock          (clock),
        .address        (fetch_address),
        .insn           (fetch_data_in),
        .insn_decode    (fetch_data_out),
        .pc             (fetch_pc_out),
        .wren           (fetch_wren),
        .stall          (fetch_stall),
        .pcIn           (alu_out_data),
        .jump           (alu_branch_taken)
    );
    
    // Decode Stage
    decode decode0(
        .clock          (clock),
        .fetch_insn     (decode_insn_in),
        .insn_valid     (decode_insn_valid),
        .pc             (fetch_address),
        .rsDataOut      (decode_rs_data),
        .rtDataOut      (decode_rt_data),
        .rdIn           (writeback_rd_out),
        .pcOut          (decode_pc_out),
        .irOut          (decode_ir_out),
        .writeBackData  (decode_write_back_data),
        .regWriteEnable (decode_reg_write_enable),
        .control        (decode_control),
        .rdOut          (decode_rd_out),
        .alu_stage_rd   (decode_rd_out),
        .mem_stage_rd   (alu_rd_out),
        //.writeback_stage_rd (writeback_stage_rd),
        .alu_stage_reg_we   (decode_control[`REG_WE]),
        .mem_stage_reg_we   (alu_control_out[`REG_WE]),
        .writeback_stage_rd (mem_stage_rd_out),
        .writeback_stage_we (mem_stage_control_out[`REG_WE]),
        .stall          (decode_stall_out),
	.alu_branch_taken (alu_branch_taken),
        .dumpRegs       (decode_dump_regs)

    );

    // Execute Stage
    alu alu0(
        .clock          (clock),
        .rsData         (decode_rs_data),
        .rtData         (decode_rt_data),
        .rtDataOut      (alu_rt_data_out),
        .control        (decode_control),
        .control_out    (alu_control_out),
        .outData        (alu_out_data),
        .branchTaken    (alu_branch_taken),
        .insn           (alu_insn_in),
        .insn_out       (alu_insn_out),
        .pc             (decode_pc_out),
        .rdIn           (decode_rd_out),
        .rdOut          (alu_rd_out)
    );
   
    // Memory Stage
    mem_stage mem_stage0(
        .clock          (clock),
        .address        (mem_stage_address),
        .data_in        (mem_stage_data_in),
        .address_out    (mem_stage_address_out),
        .mem_data_out   (mem_stage_mem_data_out),
        .data_out       (mem_stage_data_out),
        .control        (mem_stage_control_in),
        .control_out    (mem_stage_control_out),
        .rdIn           (alu_rd_out),
        .rdOut          (mem_stage_rd_out),
        .print_stack    (mem_stage_print_stack)
    );

    // Writeback Stage
    writeback_stage writeback_stage0(
        .clock          (clock),
        .rdIn           (mem_stage_rd_out),
        .rdDataIn       (mem_stage_data_out),
        .memDataIn      (mem_stage_mem_data_out),
        .control        (mem_stage_control_out),
        .rdOut          (writeback_rd_out),
        .regWriteEnable (decode_reg_write_enable),
        .writeBackData  (decode_write_back_data)
    );

    assign mcu_address = srec_done ? fetch_address : srec_address;
    assign mcu_wren = srec_done ? fetch_address : srec_wren;
    assign mcu_data_in = srec_done ? fetch_data_in : srec_data_in;
    assign fetch_data_in = mcu_data_out;
    
    assign mem_stage_address = srec_done ? alu_out_data : srec_address;
    assign mem_stage_data_in = srec_done ? alu_rt_data_out : srec_data_in;
    assign mem_stage_control_in = srec_done ? alu_control_out : mem_stage_srec_read_control;
   
    //assign decode_insn_in = pipeline_stall ? nop_insn : fetch_data_out;
    assign decode_insn_in = decode_stall_out ? decode_ir_out : fetch_data_out;
    assign alu_insn_in = (decode_stall_out || alu_branch_taken) ? nop_insn : decode_ir_out;
    assign fetch_stall = srec_done ? decode_stall_out : 1'b1;

    


    initial begin
        mem_stage_srec_read_control = 0;
        mem_stage_srec_read_control[`MEM_WE] = 1;
        nop_insn = 32'b0000_0000;
    end

    initial begin
        @(posedge srec_done)
        decode_dump_regs <= 1;
        @(posedge clock)
        decode_dump_regs <= 0;
    end

    always @(posedge clock) begin
        if (alu_insn_out[26:31] == `JR && alu_out_data== 31) begin
           program_done <= 1;
           decode_dump_regs <= 1;
	    @(posedge clock);
        end
    end
    always @(posedge clock) begin
    end 

    always @(posedge clock) begin
        if (fetch_address < 32'h8002_0000) begin
            instruction_valid = 1'b0;
            pipeline_stall = 1'b1;
	    decode_insn_valid = 1'b0;
        end else begin 
            instruction_valid = 1'b1;
	    decode_insn_valid = 1'b1;
            pipeline_stall = 1'b0;
	    $display("decode instruction out: %X", alu_insn_in);
	    $display("fetched instruction: %X", fetch_data_out);
	    $display("decode stall: %d", decode_stall_out);
	    $display("fetch pc out: %X", fetch_pc_out);
	    $display("ALU register WE: %d", decode_control[`REG_WE]);
	    $display("ALU RD: %d\n\n", decode_rd_out);
        end
    end



endmodule
