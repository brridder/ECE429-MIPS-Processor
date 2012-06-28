//
// reg_file_tb.v
//
// Register File Unit Test Bench
//

module reg_file_tb();

reg clock;

reg[0:31] inst;
reg[0:31] data;
reg[0:31] pc;
reg[0:31] writeBackData;
reg[0:4]  rdIn;

wire[0:31] rsOut;
wire[0:31] rtOut;
wire[0:31] pcOut;
wire[0:31] irOut;


reg_file U0(
    .clock (clock),
    .rsOut (rsOut),
    .rtOut (rtOut),
    .rdIn (rdIn),
    .writeBackData (writeBackData),
    .pcIn (pc),
    .pcOut (pcOut),
    .irIn (inst),
    .irOut (irOut)
);

initial begin
    clock = 1;
    inst = 0;
    data = 0;
    pc = 0;
    writeBackData = 0;
end

initial begin
    $display("\t\ttime,\tclock,\tpcIn,\tpcOut,\tirIn,\tirOut,\trsOut,\trtOut,\twriteBackData");
    $monitor("%d,\t%b,\t%h,\t%h,\t%h,\t%h,\t%h,\t%h,\t%h",
             $time, clock, pc, pcOut, inst, irOut, rsOut, rtOut, writeBackData);
end


always begin
    #5 clock = !clock;
end

initial
begin
    pc = 32'hdead_beef;
    inst = 32'h0000_0000;
    rdIn = 5'b0_0000; // $r0
    writeBackData = 32'hdeed_deed;
    @ (posedge clock);
    pc = 32'hffff_eeee;
    inst = 32'h0000_0000;
    rdIn = 5'b0_0001; // $r1
    writeBackData = 32'hbeaf_dead;
    @ (posedge clock);
    inst = 32'h000000_00000_00001_00010_00000_100000;
    rdIn = 5'b0_0100; // $r4
    writeBackData = 32'hbeef_deed;
    @ (posedge clock);
end

initial 
    #100 $finish;

endmodule
