//
// srec_parser_tb.v
//
// Srec Parser Unit Test Bench

module srec_parser_tb();


   reg clock;

   srec_parser U0(
		  .clock (clock)
   );


   initial begin
      clock = 1;
   end


endmodule // srec_parser_tb

