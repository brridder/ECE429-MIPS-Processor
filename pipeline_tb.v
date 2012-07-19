//
// pipeline_tb.v
//

module pipeline_tb();

    reg clock;
    wire program_done;

    event terminate_sim;

    pipeline DUT(
        .clock          (clock),
        .program_done   (program_done)
    );

    initial begin
        @ (terminate_sim)
        #10 $finish;
    end
    
    initial begin
        clock = 1;
    end

    always begin
        #5 clock = !clock;
    end

    always @(posedge clock)
    begin
        if (program_done == 1) begin
            ->terminate_sim;
        end
    end


endmodule
