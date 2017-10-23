`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:21 05/21/2017 
// Design Name: 
// Module Name:    prl_tx_message_path 
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
module prl_rx_message_if(
    clk,
    rst_n,

    pl2pe_rx_en,
    pl2pe_rx_type,
    pl2pe_rx_sop_type,
    pl2pe_rx_info,
    pl2pe_rx_result,

    prl_rx_st_inform_pe_en,
    prl_rx_st_inform_pe_result,

    //prl rx parser header
    prl_rx_parser_message_type,
    prl_rx_parser_sop_type,
    prl_rx_parser_header_type,

    //request message
    prl_rx_parser_data_request_pdo_type,
    prl_rx_parser_data_request_op_cur,
    prl_rx_parser_data_request_max_op_cur,
    prl_rx_parser_data_src_cap_max_vol,
    prl_rx_parser_data_src_cap_voltage,
    prl_rx_parser_data_src_cap_max_cur

);

input              clk;
input              rst_n;

output             pl2pe_rx_en;
output   [ 2:0]    pl2pe_rx_result;
output   [ 6:0]    pl2pe_rx_type;
output   [ 2:0]    pl2pe_rx_sop_type;
output   [54:0]    pl2pe_rx_info;

input              prl_rx_st_inform_pe_en;
input    [ 2:0]    prl_rx_st_inform_pe_result;

input    [ 1:0]    prl_rx_parser_message_type;
input    [ 2:0]    prl_rx_parser_sop_type;
input    [ 4:0]    prl_rx_parser_header_type;


input              prl_rx_parser_data_request_pdo_type;
input    [10:0]    prl_rx_parser_data_request_op_cur;
input    [ 9:0]    prl_rx_parser_data_request_max_op_cur;
input    [ 7:0]    prl_rx_parser_data_src_cap_max_vol;
input    [ 9:0]    prl_rx_parser_data_src_cap_voltage;
input    [ 9:0]    prl_rx_parser_data_src_cap_max_cur;


reg                pl2pe_rx_en;
reg      [ 2:0]    pl2pe_rx_result;
reg      [ 6:0]    pl2pe_rx_type;
reg      [ 2:0]    pl2pe_rx_sop_type;
reg      [65:0]    pl2pe_rx_info;

wire     [65:0]    pl2pe_rx_info_pre;

//========================================================================================
//========================================================================================
//               PRL RX Message IF 
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              pl2pe_rx_en             <= 1'h0;
              pl2pe_rx_type           <= 7'h0;
              pl2pe_rx_sop_type       <= 3'h0;
              pl2pe_rx_info           <= 66'h0;
              pl2pe_rx_result         <= 3'h0;
       end
       else if(prl_rx_st_inform_pe_en) begin
              pl2pe_rx_en             <= 1'h1;
              pl2pe_rx_type           <= {prl_rx_parser_message_type, prl_rx_parser_header_type};
              pl2pe_rx_sop_type       <= prl_rx_parser_sop_type;
              pl2pe_rx_info           <= pl2pe_rx_info_pre;
              pl2pe_rx_result         <= prl_rx_st_inform_pe_result;
       end
       else begin
              pl2pe_rx_en             <= 1'h0;
       end
end



assign     pl2pe_rx_info_pre[ 9: 0]     =         prl_rx_parser_data_request_max_op_cur;
assign     pl2pe_rx_info_pre[19:10]     =         prl_rx_parser_data_request_op_cur;
assign     pl2pe_rx_info_pre[29:20]     =         prl_rx_parser_data_src_cap_max_cur;
assign     pl2pe_rx_info_pre[39:30]     =         prl_rx_parser_data_src_cap_voltage;
assign     pl2pe_rx_info_pre[47:40]     =         prl_rx_parser_data_src_cap_max_vol;
assign     pl2pe_rx_info_pre[48:48]     =         prl_rx_parser_data_request_pdo_type;


assign     pl2pe_rx_info_pre[65:49]     =         16'h0;




endmodule




