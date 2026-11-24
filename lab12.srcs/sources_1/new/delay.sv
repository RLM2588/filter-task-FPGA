`timescale 1ns / 1ps

module delay #(
        parameter int DATA_WIDTH = 16,
        parameter int DELAY      = 1
    )(
        input  logic                         clk   ,
        input  logic signed [DATA_WIDTH-1:0] i_data,
        input  logic signed                  en    ,
        output logic signed [DATA_WIDTH-1:0] o_data
    );
    generate
        if(DELAY == 0) begin : comb_zero_delay
            assign o_data = i_data;
        end else begin : ff_delay
            logic signed [DATA_WIDTH - 1 : 0] shift_reg [0 : DELAY - 1] = '{default: '0};
            
            always_ff @(posedge clk) begin : ff_reg_shift
                if (en) begin
                    shift_reg <= {i_data, shift_reg[0 : DELAY - 2]};
                end
            end
            
            assign o_data  = shift_reg[DELAY - 1];
        end
    endgenerate
endmodule
