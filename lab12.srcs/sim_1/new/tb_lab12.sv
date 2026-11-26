`timescale 1ns / 1ps

module tb_lab12();
    localparam int CLK_PER   = 10;
    localparam int INP_WIDTH = 16;
    localparam int SUM_WIDTH = 20;
    localparam int DELAY     = 2 ;
    
    localparam int NUM_SAMPLES = 8022 + 2;
    localparam int GAP_AT  = 20;
    localparam int GAP_LEN = 3 ;
    
    logic                        clk  = 1'b0;
    logic signed [INP_WIDTH-1:0] i_i     ;
    logic signed [INP_WIDTH-1:0] i_q     ;
    logic                        i_data_v;
    logic signed [SUM_WIDTH-1:0] o_i     ;
    logic signed [SUM_WIDTH-1:0] o_q     ;
    logic                        o_data_v;
    
    always #(CLK_PER / 2) clk = ~clk;
    
    lab12 #(
        .INP_WIDTH(16),
        .SUM_WIDTH(20),
        .DELAY    (2 )
    ) u_lab12 (
        .clk     (clk     ),
        .i_i     (i_i     ),
        .i_q     (i_q     ),
        .i_data_v(i_data_v),
        .o_i     (o_i     ),
        .o_q     (o_q     ),
        .o_data_v(o_data_v)
    );
    
    logic tb_rst;
    logic tb_rfd;

    logic i_v_i;
    logic i_v_q;
    
    assign i_data_v = i_v_i & i_v_q;
    
    ReadFile #(
        .numOfBits (INP_WIDTH),
        .file_name ("C:/Users/Radiy/Documents/MATLAB/FPGA/lab12/data2fpgaI.dat")
    ) u_read_fileI (
        .data (i_i   ),
        .dv   (i_v_i ),
        .rst  (tb_rst),
        .rfd  (tb_rfd),
        .clk  (clk   )
    );
    
    WriteFile_full #(
        .numOfBits (SUM_WIDTH),
        .file_name ("C:/Users/Radiy/Documents/MATLAB/FPGA/lab12/data_from_fpgaI.dat")
    ) u_write_fileI (
        .clk    (clk   ),
        .dv     (o_data_v),
        .sign   (1'b1  ),
        .DataIn (o_i  )
    );
    
    ReadFile #(
        .numOfBits (INP_WIDTH),
        .file_name ("C:/Users/Radiy/Documents/MATLAB/FPGA/lab12/data2fpgaQ.dat")
    ) u_read_fileQ (
        .data (i_q   ),
        .dv   (i_v_q ),
        .rst  (tb_rst),
        .rfd  (tb_rfd),
        .clk  (clk   )
    );
    
    WriteFile_full #(
        .numOfBits (SUM_WIDTH),
        .file_name ("C:/Users/Radiy/Documents/MATLAB/FPGA/lab12/data_from_fpgaQ.dat")
    ) u_write_fileQ (
        .clk    (clk   ),
        .dv     (o_data_v),
        .sign   (1'b1  ),
        .DataIn (o_q  )
    );
    
    initial begin
        tb_rst = 1'b1;
        tb_rfd = 1'b0;
    
        repeat (2) @(posedge clk);
        tb_rst = 1'b0;
        
        @(negedge clk);
        tb_rfd = 1'b1;
        repeat (GAP_AT) @(posedge clk);
        @(negedge clk);
        tb_rfd = 1'b0;
        repeat (GAP_LEN) @(posedge clk);
        
        @(negedge clk);
        tb_rfd = 1'b1;
        repeat (NUM_SAMPLES - GAP_AT) @(posedge clk);
    
        @(negedge clk);
        tb_rfd = 1'b0;
        repeat (5) @(posedge clk);
        $stop;
    end
endmodule
