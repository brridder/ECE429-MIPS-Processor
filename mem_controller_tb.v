// 
// mem_controller_tb.v
//
// Memory Controller Unit Test Bench
//



module mem_controller_tb();

reg clock;
reg[0:31] address;
reg wren;
reg[0:31] data_in;

wire[0:31] data_out;

mem_controller U0(
    .clock (clock),
    .address (address),
    .wren (wren),
    .data_in (data_in),
    .data_out (data_out)
    );

initial begin
    clock = 1;
    address = 0;
    wren = 0;
    data_in = 0;
end

initial begin
    $display("\t\ttime,\tclock,\taddress,\twren,\tdata_in,\tdata_out");
    $monitor("%d,\t%b,\t%h,\t%b,\t%h,\t%h",$time,clock,address,wren,
        data_in,data_out);
end

always begin
    #5 clock = !clock;
end

initial 
begin
    wren = 1'b1;
    address = 32'h8002_0016;
    data_in = 32'hdead_beef;
    @(posedge clock);
    wren = 1'b0; // Read the memory we just saved
    @(posedge clock);
    address = 32'h0000_0016; // Read the memory location minus the start loc
    @(posedge clock);
    address = 32'hFFFF_FFFF;
    wren = 1'b1;
    data_in = 32'haaaa_aaaa;
    @(posedge clock);
    wren = 1'b0;
    @(posedge clock);
end

initial
    #100 $finish;

endmodule
