 `include "timescale.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:21 05/21/2017 
// Design Name: 
// Module Name:    bmc_encoder 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module phy_bmc_decoder(
    clk,
    rst_n,

    phy_bmc_decoder_in,
    phy_bmc_decoder_clr,
    phy_bmc_decoder_dis,

    phy_bmc_decoder_out,
    phy_bmc_decoder_out_en
    );

input     clk;
input     rst_n;

input     phy_bmc_decoder_in;
input     phy_bmc_decoder_clr;
input     phy_bmc_decoder_dis;
output    phy_bmc_decoder_out;
output    phy_bmc_decoder_out_en;


parameter TIME_SCALE_FLAG = 0;

reg       phy_bmc_decoder_out;
reg       phy_bmc_decoder_out_en;

reg       phy_bmc_decoder_in_dly1;
reg       phy_bmc_decoder_in_dly2;
reg       phy_bmc_decoder_in_dly3;
wire      phy_bmc_decoder_in_edge_pos;
wire      phy_bmc_decoder_in_edge_neg;
reg       phy_bmc_decoder_in_first_low;
reg       phy_bmc_decoder_in_first_low_dly;
wire      phy_bmc_decoder_in_first_low_plus;

reg       [10:0] phy_bmc_decoder_period_cnt;
wire      phy_bmc_decoder_period_done;
reg       phy_bmc_decoder_period_keep;

wire      [10:0] bmc_decode_period;
//bmc decode
reg       phy_bmc_decoder_pre_bit;
reg       phy_bmc_decoder_cur_bit;

//
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_decoder_in_dly1 <= 1'b1;
              phy_bmc_decoder_in_dly2 <= 1'b1;
              phy_bmc_decoder_in_dly3 <= 1'b1;
       end
       else if(phy_bmc_decoder_clr) begin
              phy_bmc_decoder_in_dly1 <= 1'b1;
              phy_bmc_decoder_in_dly2 <= 1'b1;
              phy_bmc_decoder_in_dly3 <= 1'b1;
       end
       else if(!phy_bmc_decoder_dis) begin
              phy_bmc_decoder_in_dly1 <= phy_bmc_decoder_in;
              phy_bmc_decoder_in_dly2 <= phy_bmc_decoder_in_dly1;
              phy_bmc_decoder_in_dly3 <= phy_bmc_decoder_in_dly2;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_decoder_in_first_low_dly <= 1'b0;
       end
       else if(phy_bmc_decoder_clr) begin
              phy_bmc_decoder_in_first_low_dly <= 1'b0;
       end
       else begin
              phy_bmc_decoder_in_first_low_dly <= phy_bmc_decoder_in_first_low;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_decoder_in_first_low <= 1'b0;
       end
       else if(phy_bmc_decoder_clr) begin
              phy_bmc_decoder_in_first_low <= 1'b0;
       end
       else if(!phy_bmc_decoder_dis && !phy_bmc_decoder_in_dly3) begin
              phy_bmc_decoder_in_first_low <= 1'b1;
       end
end

assign    phy_bmc_decoder_in_edge_pos = phy_bmc_decoder_in_dly2 && !phy_bmc_decoder_in_dly3;
assign    phy_bmc_decoder_in_edge_neg = phy_bmc_decoder_in_dly3 && !phy_bmc_decoder_in_dly2;

assign    phy_bmc_decoder_in_first_low_plus = phy_bmc_decoder_in_first_low && !phy_bmc_decoder_in_first_low_dly;

//bmc period
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_decoder_period_cnt <= 11'h0;
       end
       else if(phy_bmc_decoder_clr) begin
              phy_bmc_decoder_period_cnt <= 11'h0;
       end
       else if(phy_bmc_decoder_period_done) begin
              phy_bmc_decoder_period_cnt <= 11'h0;
       end
       else if(phy_bmc_decoder_period_keep) begin
              phy_bmc_decoder_period_cnt <= phy_bmc_decoder_period_cnt + 1'h1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_decoder_period_keep <= 1'h0;
       end
       else if(phy_bmc_decoder_clr) begin
              phy_bmc_decoder_period_keep <= 1'h0;
       end
       else if(phy_bmc_decoder_period_done) begin
              phy_bmc_decoder_period_keep <= 1'h0;
       end
       else if(phy_bmc_decoder_in_edge_pos || phy_bmc_decoder_in_edge_neg || phy_bmc_decoder_in_first_low_plus) begin
              phy_bmc_decoder_period_keep <= 1'h1;
       end
end

assign    bmc_decode_period = (TIME_SCALE_FLAG == 0) ? 11'd5 :
	                      (TIME_SCALE_FLAG == 1) ? 11'd11 :
	                      (TIME_SCALE_FLAG == 2) ? 11'd22 : 11'd1;

assign    phy_bmc_decoder_period_done = (phy_bmc_decoder_period_cnt == bmc_decode_period);


//bmc decode 
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_decoder_pre_bit <= 1'h1;
       end
       else if(phy_bmc_decoder_clr) begin
              phy_bmc_decoder_pre_bit <= 1'h1;
       end
       else if(phy_bmc_decoder_period_done) begin
              phy_bmc_decoder_pre_bit <= phy_bmc_decoder_in_dly3;
       end
end

//bmc decode output
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_decoder_out_en <= 1'b0;
              phy_bmc_decoder_out <= 1'b0;
       end
       else if(phy_bmc_decoder_period_done) begin
              phy_bmc_decoder_out_en <= 1'b1;
              phy_bmc_decoder_out <= !(phy_bmc_decoder_in_dly3 ^ phy_bmc_decoder_pre_bit);
       end
       else begin
              phy_bmc_decoder_out_en <= 1'b0;
       end
end



endmodule
