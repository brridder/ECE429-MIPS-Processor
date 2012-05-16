//This module is responsible for taking a given srec file and decoding it.
//Once decoded, it is loaded into memory using the mem_controller module


module srec_parser(
		   clock
);


   parameter SREC_FILE_NAME = "test.srec";
   input wire clock;
   integer    file;
   integer    num_characters;
   reg [47*8-1:0] srec_line;
   reg[0:7] 	  first_character;
   reg [0:7] 	  second_character;
   integer 	  length;
   reg [36*8-1:0] 	  data;
   integer   		  data_length;
   integer 		  address;
   integer 		  checksum;
   integer 		  offset;
			  
   
   
   
   

   initial begin
      //num_characters = 32;
      file = $fopen(SREC_FILE_NAME, "r");
      $display("opened file \n");
      length = 1;
      while (length != 0) begin
	 length = $fgets(srec_line, file);
	 $sscanf(srec_line, "%c%c", first_character, second_character);
	 
	 if (second_character == "3") begin
	    $display("line: %s of length %d\n", srec_line, length);
	    $sscanf(srec_line, "S3%2X%8X%s", data_length, address, data);
	    $display("data_length: %d Address: %8X Data: %s", data_length, address, data);
	    offset = 2*8*(data_length - 4) - 16;

	    
	    $sscanf(data[offset+:16], "%2X", checksum);
	    $display("checksum: %2X\n", checksum);
	 end else begin
	   // $display("not a data line");
	 end
	 
	 
      end
      $display("read in file \n");
      
   end
   

   
endmodule // srec_parser



