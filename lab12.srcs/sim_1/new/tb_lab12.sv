`timescale 1ns / 1ps

module tb_lab12();
    localparam int CLK_PER = 10;
    
    logic              clk  = 1'b0;
    logic              srst = 1'b1;
    logic signed [3:0] din;
    logic signed [3:0] dout;
    
    always #(CLK_PER / 2) clk = ~clk;
    
    always_ff @(posedge clk) begin : ff_cnt
        if (srst) begin
            din <= '0;
        end else begin
            din <= din + 1'b1;
        end
    end
    
    delay #(
        .DATA_WIDTH (4),
        .DELAY      (0)
    )u_delay (
        .clk    (clk  ),
        .i_data (din  ),
        .en     (~srst),
        .o_data (dout )
    );
    
    initial begin
        @(posedge clk);
        srst = 1'b0;
        repeat (10) @(posedge clk);
        $stop;
    end
endmodule
