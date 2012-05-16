//
// srec_parser_tb.v
//
// Srec Parser Unit Test Bench

module srec_parser_tb();


   reg clock;
   //reg mem_clock;

   wire[0:31]  srec_address;
   wire        srec_wren;
   wire [0:31] srec_data_in;
   wire [0:31] srec_data_out;

   wire [0:31] address;
   wire        wren;
   wire [0:31] data_in;
   wire [0:31] data_out;

   reg[0:31]  tb_address;
   reg        tb_wren;
   reg [0:31] tb_data_in;
   wire [0:31] tb_data_out;
   
   wire        srec_done;
   wire [0:31] bytes_read;
   integer     byte_count;
   integer     read_word;
   

   assign address = srec_done ? tb_address : srec_address;
   assign wren = srec_done ? tb_wren : srec_wren;
   assign tb_data_out = data_out;

   
   
   assign data_in = srec_done ? tb_data_in : srec_data_in;
    
   srec_parser #("srec_files/BubbleSort.srec") U0(
		  .clock (clock),
		  .mem_address (srec_address),
	          .mem_wren (srec_wren),
         	  .mem_data_in (srec_data_in),
		  .mem_data_out (srec_data_out),
		  .done (srec_done),
		  .bytes_read(bytes_read)
   );

   mem_controller U1(
		     .clock (clock),
		     .address (address),
		     .wren (wren),
		     .data_in (data_in),
		     .data_out (data_out)
		     );
   
 

   initial begin
      clock = 1;
   end

   always begin
    #5 clock = !clock;
   end

   initial begin
      @(posedge srec_done);
      @(posedge clock);

      byte_count = bytes_read;
      tb_address = 32'h8002_0000;
      tb_wren = 1'b0;
      while (byte_count > 0) begin
	 @(posedge clock);
	 read_word = tb_data_out;
	 
	 $display("%8X: %8X", tb_address, read_word);
	 tb_address = tb_address + 4;
	 byte_count = byte_count - 4;
	 
      end
   end
   


endmodule // srec_parser_tb

