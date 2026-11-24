`timescale 1ns / 1ps

module filterTap #(
        parameter int INP_WIDTH = 16,
        parameter int SUM_WIDTH = 20,
        parameter int KFF_WIDTH = 2,
        parameter int DELAY     = 2
    ) (
        input  logic                        clk,
        input  logic signed [INP_WIDTH-1:0] i_smpl,
        input  logic                        i_smpl_v,
        input  logic signed [KFF_WIDTH-1:0] i_koeff,
        input  logic signed [SUM_WIDTH-1:0] i_prevTap,
        output logic signed [SUM_WIDTH-1:0] o_nextTap 
    );
    localparam int FULL_SUM_WIDTH = (INP_WIDTH + KFF_WIDTH) + 1;
    
    logic signed [FULL_SUM_WIDTH-1:0] mac;
    logic signed [SUM_WIDTH-1:0]      dout;
    
    assign mac = i_smpl * i_koeff + i_prevTap;
    
    always_comb begin : comb_MAC
        if(FULL_SUM_WIDTH <= SUM_WIDTH) begin
            dout = mac;
        end else begin
//            dout = mac[SUM_WIDTH-1:0]; // без насыщения
            if (|mac[FULL_SUM_WIDTH-1:SUM_WIDTH]) begin // насыщение
                dout = {mac[FULL_SUM_WIDTH-1], {(SUM_WIDTH-1){~mac[FULL_SUM_WIDTH-1]}}};
            end else begin
                dout = mac[SUM_WIDTH-1:0];
            end
        end
    end
    
    delay #(
        .DATA_WIDTH (SUM_WIDTH),
        .DELAY      (DELAY    )
    ) u_delay (
        .clk    (clk      ),
        .i_data (dout     ),
        .en     (i_smpl_v ),
        .o_data (o_nextTap)
    );
endmodule
