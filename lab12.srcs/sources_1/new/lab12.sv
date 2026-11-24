`timescale 1ns / 1ps

module lab12 #(
        parameter int INP_WIDTH = 16,
        parameter int SUM_WIDTH = 20,
        parameter int DELAY     = 2 
    ) (
        input  logic                        clk     ,
        input  logic signed [INP_WIDTH-1:0] i_i     ,
        input  logic signed [INP_WIDTH-1:0] i_q     ,
        input  logic                        i_data_v,
        output logic signed [INP_WIDTH-1:0] o_i     ,
        output logic signed [INP_WIDTH-1:0] o_q     ,
        output logic                        o_data_v
    );
    localparam int KFF_COUNT = 11;
    
    localparam logic             rom    [0:KFF_COUNT-1] = '{
        1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1 
    }; // 0 -> +1; 1 -> -1;
    
    logic signed [SUM_WIDTH-1:0] taps_i [0:KFF_COUNT-1];
    logic signed [SUM_WIDTH-1:0] taps_q [0:KFF_COUNT-1];
    
    assign o_i = taps_i[KFF_COUNT-1];
    assign o_q = taps_q[KFF_COUNT-1];
    
    generate // FOR I
        for (genvar i = 0; i < KFF_COUNT; i++) begin
            if (i == 0) begin : gen_first_tap
                filterTap #(
                    .INP_WIDTH(INP_WIDTH),
                    .SUM_WIDTH(SUM_WIDTH),
                    .DELAY    (DELAY    ),
                    .KOEFF    (rom[i]   )
                ) u_tap_i (
                    .clk      (clk      ),
                    .i_smpl   (i_i      ),
                    .i_smpl_v (i_data_v ),
                    .i_prevTap('0       ),
                    .o_nextTap(taps_i[i])
                );
            end else begin : gen_other_tap
                filterTap #(
                    .INP_WIDTH(INP_WIDTH),
                    .SUM_WIDTH(SUM_WIDTH),
                    .DELAY    (DELAY    ),
                    .KOEFF    (rom[i]   )
                ) u_tap_i (
                    .clk      (clk        ),
                    .i_smpl   (i_i        ),
                    .i_smpl_v (i_data_v   ),
                    .i_prevTap(taps_i[i-1]),
                    .o_nextTap(taps_i[i]  )
                );
            end
        end
    endgenerate
    
    generate // FOR Q
        for (genvar i = 0; i < KFF_COUNT; i++) begin
            if (i == 0) begin : gen_first_tap
                filterTap #(
                    .INP_WIDTH(INP_WIDTH),
                    .SUM_WIDTH(SUM_WIDTH),
                    .DELAY    (DELAY    ),
                    .KOEFF    (rom[i]   )
                ) u_tap_i (
                    .clk      (clk      ),
                    .i_smpl   (i_q      ),
                    .i_smpl_v (i_data_v ),
                    .i_prevTap('0       ),
                    .o_nextTap(taps_q[i])
                );
            end else begin : gen_other_tap
                filterTap #(
                    .INP_WIDTH(INP_WIDTH),
                    .SUM_WIDTH(SUM_WIDTH),
                    .DELAY    (DELAY    ),
                    .KOEFF    (rom[i]   )
                ) u_tap_i (
                    .clk      (clk        ),
                    .i_smpl   (i_q        ),
                    .i_smpl_v (i_data_v   ),
                    .i_prevTap(taps_q[i-1]),
                    .o_nextTap(taps_q[i]  )
                );
            end
        end
    endgenerate
    
    delay #(
        .DATA_WIDTH (1    ),
        .DELAY      (DELAY) // (DELAY + KFF_COUNT)
    ) u_delay (
        .clk    (clk     ),
        .i_data (i_data_v),
        .en     (1'b1    ),
        .o_data (o_data_v)
    );
endmodule
