// Memory test bench

module mem_tb;
    reg clock, wren;
    reg [0:31] address, data;
    wire [0:31] data_out;

    // Instantiate mem DUT
    mem DUT(clock, address, wren, data, data_out);

    // Executes only once during the initialization
    initial begin
        clock = 0;
        wren = 0;
        address = 0;
        data = 0;
    end

    // Clock generation
    always
        #5 clock = !clock;

    // Setup for simulation
    initial begin
        $dumpfile("mem.vcd");   // waveform
        $dumpvars;              // dump all the signals
    end
    initial begin
        // print header to stdout
        $display("\t\ttime,\tclock,\twren,\taddress,\tdata,\tdata_out");
        // prints signal values when they change
        $monitor("%d,\t%b,\t%b,\t%h,\t%h,\t%h", $time, clock, wren, address, data, data_out);
    end

    // Specify when to stop the simulation
    event terminate_sim;
    initial begin 
        @ (terminate_sim);
        #10 $finish;
    end
   

    // TEST CASES BEGIN HERE
    initial begin
        // 1. load and validate data at mem top and bottom
        @ (posedge clock);
        wren = 1'b1;
        address = 32'h0000_0000;
        data = 32'h55cc_55cc;
        @ (posedge clock);
        wren = 1'b0;
        @ (posedge clock);
        if (data_out != 32'h55cc_55cc) begin
            $display("Mem error at time %d", $time);
            $display("Expected value 55cc55cc, actual value %h", data_out);
            $display("Address %d", address);
            #5 -> terminate_sim;
        end

        @ (posedge clock);
        wren = 1'b1;
        address = 32'h000f_fffc;
        data = 32'h1234_5678;
        @ (posedge clock);
        wren = 1'b0;
        @ (posedge clock);
        if (data_out != 32'h1234_5678) begin
            $display("Mem error at time %d", $time);
            $display("Expected value 12345678, actual value %d", data_out);
            $display("Address %d", address);
            #5 -> terminate_sim;
        end

        // 2. Load and validate data somewhere in the middle of memory
        @ (posedge clock);
        wren = 1'b1;
        address = 32'h0008_8888;
        data = 32'hfedc_ba98;
        @ (posedge clock);
        wren = 1'b0;
        @ (posedge clock);
        if (data_out != 32'hfedc_ba98) begin
            $display("Mem error at time %d", $time);
            $display("Expected value fedcba98, actual value %d", data_out);
            $display("Address %d", address);
            #5 -> terminate_sim;
        end

        // 3. Load and validate data out of memory bounds
        @ (posedge clock);
        wren = 1'b1;
        address = 32'hffff_ffff;        
        data = 32'h5678_9abc;
        @ (posedge clock);
        wren = 1'b0;
        @ (posedge clock);
        if (data_out != 32'h0000_0000) begin
            $display("Mem error at time %d", $time);
            $display("Expected value 00000000, actual value %d", data_out);
            $display("Address %d (out of bounds)", address);
            #5 -> terminate_sim;
        end
      
        -> terminate_sim;
      
    end   
    
endmodule   
