`timescale 1ns / 1ps

module tb_lab12();
    localparam int CLK_PER = 10;
    
    logic              clk  = 1'b0;
    
    always #(CLK_PER / 2) clk = ~clk;
    
    lab12 #(
        .INP_WIDTH(16),
        .SUM_WIDTH(20),
        .DELAY    (2 )
    ) (
        .clk     (clk     ),
        .i_i     (i_i     ),
        .i_q     (i_q     ),
        .i_data_v(i_data_v),
        .o_i     (o_i     ),
        .o_q     (o_q     ),
        .o_data_v(o_data_v)
    );
    
    initial begin
        @(posedge clk);
        repeat (10) @(posedge clk);
        $stop;
    end
endmodule
