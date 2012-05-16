//This module is responsible for taking a given srec file and decoding it.
//Once decoded, it is loaded into memory using the mem_controller module


module srec_parser(
		   clock,
		   mem_address,
		   mem_wren,
		   mem_data_in,
		   mem_data_out,
		   done,
		   bytes_read
);


   parameter SREC_FILE_NAME = "test2.srec";
   
   input wire clock;
   output reg [0:31] mem_address;
   output reg 	    mem_wren;
   output reg [0:31] mem_data_in;

   inout wire [0:31] mem_data_out;

   output reg 	     done;
   output integer bytes_read;
   
	      
   integer    file;
   integer    num_characters;
   reg [47*8-1:0] srec_line;
   reg[0:7] 	  first_character;
   reg [0:7] 	  second_character;
   integer 	  length;
   reg [36*8-1:0] 	  data;
   integer   		  data_length;
   integer 		  address;
   integer 		  data_word;
   integer 		  offset;
			  
   
  

   initial begin
      //num_characters = 32;
      done = 1'b0;
      bytes_read = 0;
      
      file = $fopen(SREC_FILE_NAME, "r");
      $display("opened file %s\n", SREC_FILE_NAME);
      length = 1;
      while (length != 0) begin
	 length = $fgets(srec_line, file);
	 $sscanf(srec_line, "%c%c", first_character, second_character);
	 
	 if (second_character == "3") begin
	    $sscanf(srec_line, "S3%2X%8X%s", data_length, address, data);
	    offset = 2*8*(data_length - 4) -64;
	    address = address - 4;

	    @(posedge clock);
	    	    
	    while (offset >= 16) begin
	       address = address + 4;
	       bytes_read = bytes_read + 4;
	       $sscanf(data[offset+:64], "%8X", data_word);
	       offset = offset - 64;
	       @(posedge clock);
	       mem_address = address;
	       mem_wren = 1'b1;
	       mem_data_in = data_word;
	    end
	 end
	 
	 
      end
      $display("read in file \n");
      done = 1'b1;
      
   end
   

   
endmodule // srec_parser



