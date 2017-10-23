`timescale 1ns / 1ps
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
module phy_bmc_encoder(
    clk,
    rst_n,

    phy_bmc_encoder_data,
    phy_bmc_encoder_data_en,
    phy_bmc_encoder_data_preamble,
    phy_bmc_encoder_data_done,
    phy_bmc_encoder_hold_lowbmc_done,

    phy_bmc_encoder_drive_data,
    phy_bmc_encoder_drive_en
    );

input     clk;
input     rst_n;

input     [4:0] phy_bmc_encoder_data;
input     phy_bmc_encoder_data_en;
input     phy_bmc_encoder_data_preamble;
output    phy_bmc_encoder_data_done;
output    phy_bmc_encoder_hold_lowbmc_done;

output    phy_bmc_encoder_drive_en;
output    phy_bmc_encoder_drive_data;


localparam BMC_HALF_PERIOD = 11'd4;
localparam BMC_HOLD_LOW_BMC = 7'd3;


reg       phy_bmc_encoder_drive_en;
reg       phy_bmc_encoder_drive_data;
reg       phy_bmc_encoder_data_done;

reg       [10:0] phy_bmc_encoder_period_cnt;
wire      phy_bmc_encoder_half_period_done;
wire      phy_bmc_encoder_period_done;
reg       [5:0] phy_bmc_encoder_bit_cnt;
wire      phy_bmc_encoder_bit_done;

reg       [5:0] phy_bmc_encoder_buffer;
reg       phy_bmc_encoder_buffer_empty;

wire      phy_bmc_encoder_cur_bit;
reg       phy_bmc_encoder_buffer_empty_dly;
wire      phy_bmc_encoder_buffer_empty_neg;
wire      phy_bmc_encoder_buffer_empty_pos;

//
reg       phy_bmc_encoder_continue_period;

//min Thold Low BMC
reg       [6:0] phy_bmc_encoder_hold_lowbmc_cnt;
reg       phy_bmc_encoder_hold_lowbmc_en;
wire      phy_bmc_encoder_hold_lowbmc_done;

//buffer push & pop
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_buffer_empty <= 1'b1;
              phy_bmc_encoder_buffer <= 6'b0;
       end
       else if(phy_bmc_encoder_data_en && phy_bmc_encoder_buffer_empty) begin
              phy_bmc_encoder_buffer_empty <= 1'b0;
              phy_bmc_encoder_buffer <= {phy_bmc_encoder_data_preamble, phy_bmc_encoder_data};
       end
       else if(phy_bmc_encoder_data_en && phy_bmc_encoder_bit_done) begin
              phy_bmc_encoder_buffer <= {phy_bmc_encoder_data_preamble, phy_bmc_encoder_data};
       end
       else if(!phy_bmc_encoder_buffer_empty && phy_bmc_encoder_bit_done) begin
              phy_bmc_encoder_buffer_empty <= 1'b1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_buffer_empty_dly <= 1'b1;
       end
       else begin
              phy_bmc_encoder_buffer_empty_dly <= phy_bmc_encoder_buffer_empty;
       end
end

assign    phy_bmc_encoder_buffer_empty_neg = !phy_bmc_encoder_buffer_empty && phy_bmc_encoder_buffer_empty_dly;
assign    phy_bmc_encoder_buffer_empty_pos = phy_bmc_encoder_buffer_empty && !phy_bmc_encoder_buffer_empty_dly;

//bmc period
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_period_cnt <= 11'h0;
       end
       else if(phy_bmc_encoder_period_done) begin
              phy_bmc_encoder_period_cnt <= 11'h0;
       end
       else if(!phy_bmc_encoder_buffer_empty || phy_bmc_encoder_continue_period) begin
              phy_bmc_encoder_period_cnt <= phy_bmc_encoder_period_cnt + 1'h1;
       end
end

assign    phy_bmc_encoder_half_period_done = !phy_bmc_encoder_continue_period && (phy_bmc_encoder_period_cnt == BMC_HALF_PERIOD);
assign    phy_bmc_encoder_period_done = (phy_bmc_encoder_period_cnt == (BMC_HALF_PERIOD << 1));

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_bit_cnt <= 6'h0;
       end
       else if(phy_bmc_encoder_bit_done) begin
              phy_bmc_encoder_bit_cnt <= 6'h0;
       end
       else if(phy_bmc_encoder_period_done) begin
              phy_bmc_encoder_bit_cnt <= phy_bmc_encoder_bit_cnt + 1'h1;
       end
end


assign    phy_bmc_encoder_bit_done = phy_bmc_encoder_buffer[5] ?  (phy_bmc_encoder_period_done && (phy_bmc_encoder_bit_cnt == 6'h3f)) :
	                                                          (phy_bmc_encoder_period_done && (phy_bmc_encoder_bit_cnt == 6'h4 )) ;


//continue drive one bit 
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_continue_period <= 1'h0;
       end
       else if(phy_bmc_encoder_period_done) begin
              phy_bmc_encoder_continue_period <= 1'h0;
       end
       else if(phy_bmc_encoder_buffer_empty_pos && !phy_bmc_encoder_drive_data) begin
              phy_bmc_encoder_continue_period <= 1'h1;
       end
end

//min Thold Low BMC
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_hold_lowbmc_cnt <= 7'h0;
       end
       else if(phy_bmc_encoder_hold_lowbmc_done) begin
              phy_bmc_encoder_hold_lowbmc_cnt <= 7'h0;
       end
       else if(phy_bmc_encoder_hold_lowbmc_en && !phy_bmc_encoder_continue_period) begin
              phy_bmc_encoder_hold_lowbmc_cnt <= phy_bmc_encoder_hold_lowbmc_cnt + 1'h1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_hold_lowbmc_en <= 1'h0;
       end
       else if(phy_bmc_encoder_hold_lowbmc_done) begin
              phy_bmc_encoder_hold_lowbmc_en <= 1'h0;
       end
       else if(phy_bmc_encoder_buffer_empty_pos) begin
              phy_bmc_encoder_hold_lowbmc_en <= 1'h1;
       end
end

assign    phy_bmc_encoder_hold_lowbmc_done = (phy_bmc_encoder_hold_lowbmc_cnt == BMC_HOLD_LOW_BMC);

//drive
assign    phy_bmc_encoder_cur_bit = phy_bmc_encoder_buffer[5] ? phy_bmc_encoder_bit_cnt[0] : phy_bmc_encoder_buffer[phy_bmc_encoder_bit_cnt[2:0]];


always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_drive_data <= 1'h0;
              phy_bmc_encoder_drive_en <= 1'h0;
       end
       else if(phy_bmc_encoder_buffer_empty_neg) begin
              phy_bmc_encoder_drive_data <= 1'h1;
              phy_bmc_encoder_drive_en <= 1'h1;
       end
       else if(phy_bmc_encoder_hold_lowbmc_done) begin
              phy_bmc_encoder_drive_data <= 1'h0;
              phy_bmc_encoder_drive_en <= 1'h0;
       end
       else if(phy_bmc_encoder_period_done) begin
              phy_bmc_encoder_drive_data <= !phy_bmc_encoder_drive_data;
       end
       else if(phy_bmc_encoder_half_period_done && phy_bmc_encoder_cur_bit) begin
              phy_bmc_encoder_drive_data <= !phy_bmc_encoder_drive_data;
       end
end

//bmc_encoder_data_done
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_data_done <= 1'b0;
       end
       else if(phy_bmc_encoder_data_en && phy_bmc_encoder_buffer_empty) begin
              phy_bmc_encoder_data_done <= 1'b1;
       end
       else if(phy_bmc_encoder_data_en && phy_bmc_encoder_bit_done) begin
              phy_bmc_encoder_data_done <= 1'b1;
       end
       else begin
              phy_bmc_encoder_data_done <= 1'b0;
       end
end

endmodule
