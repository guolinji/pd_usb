`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:22:44 05/21/2017 
// Design Name: 
// Module Name:    crc32_tx_rx 
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
module phy_crc32_tx_rx(
    clk,
    rst_n,

    phy_crc_tx_rx_select,

    phy_tx_packet_data_en,
    phy_tx_packet_data_in,
    phy_tx_packet_data_last,
    phy_tx_packet_crc,

    phy_rx_crc_data_in,
    phy_rx_crc_data_en,
    phy_rx_crc_data_last,
    phy_rx_crc_out_fail

    );

input     clk;
input     rst_n;

input     phy_crc_tx_rx_select;

input     phy_tx_packet_data_en;       
input     [7:0] phy_tx_packet_data_in; 
input     phy_tx_packet_data_last;       
output    [31:0] phy_tx_packet_crc;    

input     [3:0] phy_rx_crc_data_in; 
input     phy_rx_crc_data_last;       
input     phy_rx_crc_data_en;       
output    phy_rx_crc_out_fail;    

reg       phy_tx_crc_data_en_reg;
wire      phy_tx_crc_data_en_plus;

reg       [3:0] phy_tx_crc_data_in_cnt;
wire      phy_tx_crc_data_en_2;
wire      phy_tx_crc_data_last_2;
wire      [3:0] phy_tx_crc_data_in_2;

wire      [3:0] phy_crc_data_in;
wire      phy_crc_data_en;
wire      phy_crc_data_last;
wire      [31:0] phy_crc_out;
wire      phy_crc_out_en;
wire      phy_crc_out_fail;



always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_tx_crc_data_en_reg <= 1'h0;
       end
       else  begin
              phy_tx_crc_data_en_reg <= phy_tx_packet_data_en;
       end
end

assign  phy_tx_crc_data_en_plus   = phy_tx_packet_data_en && !phy_tx_crc_data_en_reg; 

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_tx_crc_data_in_cnt <= 4'h0;
       end
       else  if(phy_tx_crc_data_en_plus) begin
              phy_tx_crc_data_in_cnt <= 4'hf;
       end
       else  if(phy_tx_crc_data_in_cnt != 4'h0) begin
              phy_tx_crc_data_in_cnt <= phy_tx_crc_data_in_cnt - 1'h1;
       end
end


assign  phy_tx_crc_data_en_2   = (phy_tx_crc_data_in_cnt == 4'hf) || (phy_tx_crc_data_in_cnt == 4'h8) || phy_tx_crc_data_last_2;
assign  phy_tx_crc_data_last_2 = ((phy_tx_crc_data_in_cnt == 4'h1) && phy_tx_packet_data_last);
assign  phy_tx_crc_data_in_2   = (phy_tx_crc_data_in_cnt > 4'h8) ? phy_tx_packet_data_in[3:0] : phy_tx_packet_data_in[7:4] ;


assign  phy_crc_data_en   = phy_crc_tx_rx_select ? phy_tx_crc_data_en_2   : phy_rx_crc_data_en;
assign  phy_crc_data_last = phy_crc_tx_rx_select ? phy_tx_crc_data_last_2 : phy_rx_crc_data_last;
assign  phy_crc_data_in   = phy_crc_tx_rx_select ? phy_tx_crc_data_in_2   : phy_rx_crc_data_in;

assign  phy_tx_packet_crc = phy_crc_out;
assign  phy_rx_crc_out_fail = phy_crc_out_fail;


phy_crc32 phy_crc32(
    .clk(clk),
    .rst_n(rst_n),

    .crc_data_in(phy_crc_data_in),
    .crc_data_en(phy_crc_data_en),
    .crc_data_last(phy_crc_data_last),

    .crc_out_fail(phy_crc_out_fail),
    .crc_out(phy_crc_out)
);



endmodule


