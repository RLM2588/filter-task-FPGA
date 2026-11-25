`timescale 1ns / 1ps

module filterTap #( // Только для Баркера
        parameter int INP_WIDTH = 16,
        parameter int SUM_WIDTH = 20,
        parameter int DELAY     = 2 ,
        parameter int KOEFF     = 1
    ) (
        input  logic                        clk      ,
        input  logic signed [INP_WIDTH-1:0] i_smpl   ,
        input  logic                        i_smpl_v ,
        input  logic signed [SUM_WIDTH-1:0] i_prevTap,
        output logic signed [SUM_WIDTH-1:0] o_nextTap 
    );
    localparam int FULL_SUM_WIDTH = (INP_WIDTH < SUM_WIDTH) ? (SUM_WIDTH + 1) : (INP_WIDTH + 1) + 1;
    
    logic signed [FULL_SUM_WIDTH-1:0] mac ;
    logic signed [SUM_WIDTH-1:0]      dout;
    
    generate
        if(KOEFF) begin
            assign mac = $signed(~{i_smpl[INP_WIDTH-1], i_smpl}) + 1 + i_prevTap;
        end else begin
            assign mac = i_smpl + i_prevTap;
        end
    endgenerate
    
    always_comb begin : comb_MAC
        if(FULL_SUM_WIDTH <= SUM_WIDTH) begin
            dout = mac;
        end else begin
//            dout = mac[SUM_WIDTH-1:0]; // без насыщения
            if (((~mac[FULL_SUM_WIDTH-1]) & (|mac[FULL_SUM_WIDTH-2:SUM_WIDTH])) | (mac[FULL_SUM_WIDTH-1] & (~&mac[FULL_SUM_WIDTH-2:SUM_WIDTH]))) begin // насыщение ((~sgn) & (|ext_bits)) | (sgn & (~&ext_bits))
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
