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
module prl_tx_message_if(
    clk,
    rst_n,
 
    //pe&pl if
    pe2pl_tx_en,
    pe2pl_tx_type,
    pe2pl_tx_sop_type,
    pe2pl_tx_info,
    pe2pl_tx_ex_info,
    pl2pe_tx_ack,
    pl2pe_tx_result,

    //tx st&if if
    prl_tx_st_message_if_ack,
    prl_tx_st_message_if_ack_result,

    //pl tx message decode if
    prl_tx_if_en,
    prl_tx_if_sop_type,
    prl_tx_if_message_type,
    prl_tx_if_header_type,

    prl_tx_if_alert_message_info,

    prl_tx_if_source_cap_table_select,
    prl_tx_if_source_cap_current,

    prl_tx_if_ex_message_data_size,

    prl_tx_if_ex_pps_status_flag_omf,
    prl_tx_if_ex_pps_status_flag_ptp,
    prl_tx_if_ex_pps_status_output_current,
    prl_tx_if_ex_pps_status_output_voltage,

    prl_tx_if_ex_status_temp_status,
    prl_tx_if_ex_status_event_flag,
    prl_tx_if_ex_status_present_input,
    prl_tx_if_ex_status_internal_temp


);

input              clk;
input              rst_n;

input              pe2pl_tx_en;
input    [ 6:0]    pe2pl_tx_type;
input    [ 2:0]    pe2pl_tx_sop_type;
input    [ 8:0]    pe2pl_tx_info;
input    [38:0]    pe2pl_tx_ex_info;
output             pl2pe_tx_ack;
output   [ 1:0]    pl2pe_tx_result;

input              prl_tx_st_message_if_ack;
input    [ 1:0]    prl_tx_st_message_if_ack_result;

output             prl_tx_if_en;
output   [ 2:0]    prl_tx_if_sop_type;
output   [ 1:0]    prl_tx_if_message_type;
output   [ 4:0]    prl_tx_if_header_type;


output   [ 3:0]    prl_tx_if_source_cap_table_select;
output             prl_tx_if_source_cap_current;

output   [ 3:0]    prl_tx_if_alert_message_info;

output   [ 8:0]    prl_tx_if_ex_message_data_size;

output             prl_tx_if_ex_pps_status_flag_omf;
output             prl_tx_if_ex_pps_status_flag_ptp;
output   [ 7:0]    prl_tx_if_ex_pps_status_output_current;
output   [15:0]    prl_tx_if_ex_pps_status_output_voltage;

output   [ 1:0]    prl_tx_if_ex_status_temp_status;
output   [ 2:0]    prl_tx_if_ex_status_event_flag;
output   [ 3:0]    prl_tx_if_ex_status_present_input;
output   [ 7:0]    prl_tx_if_ex_status_internal_temp;


reg                prl_tx_if_en_reg;
reg      [ 6:0]    prl_tx_if_type_reg;
reg      [ 2:0]    prl_tx_if_sop_type_reg;
reg      [ 8:0]    prl_tx_if_info_reg;
reg      [52:0]    prl_tx_if_ex_info_reg;

reg                pl2pe_tx_ack;
reg      [ 1:0]    pl2pe_tx_result;


//message decode
wire     [ 2:0]    prl_tx_if_header_num_data_object;
wire               prl_tx_if_header_port_data_role;
wire     [ 1:0]    prl_tx_if_header_spec_revision;
wire               prl_tx_if_header_cable_plug;
wire               prl_tx_if_header_port_power_role;

wire               prl_tx_if_pdo_unchunked_ex_message;
wire               prl_tx_if_pdo_dual_role_data;
wire               prl_tx_if_pdo_usb_communication_capable;
wire               prl_tx_if_pdo_unconstrained_power;
wire               prl_tx_if_pdo_usb_suspended_supported;
wire               prl_tx_if_pdo_dual_role_power;

wire     [ 3:0]    prl_tx_if_alert_message_info;

wire     [ 8:0]    prl_tx_if_ex_message_data_size;

wire               prl_tx_if_ex_pps_status_flag_omf;
wire               prl_tx_if_ex_pps_status_flag_ptp;
wire     [ 7:0]    prl_tx_if_ex_pps_status_output_current;
wire     [15:0]    prl_tx_if_ex_pps_status_output_voltage;

wire     [ 1:0]    prl_tx_if_ex_status_temp_status;
wire     [ 2:0]    prl_tx_if_ex_status_event_flag;
wire     [ 3:0]    prl_tx_if_ex_status_present_input;
wire     [ 7:0]    prl_tx_if_ex_status_internal_temp;

//========================================================================================
//========================================================================================
//               PRL TX Message  IF 
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_if_en_reg         <= 1'h0;
              prl_tx_if_type_reg       <= 7'h0;
              prl_tx_if_sop_type_reg   <= 3'h0;
              prl_tx_if_info_reg       <= 9'h0;
              prl_tx_if_ex_info_reg    <= 53'h0;
       end
       else if(prl_tx_st_message_if_ack) begin
              prl_tx_if_en_reg         <= 1'h0;
              prl_tx_if_type_reg       <= 7'h0;
              prl_tx_if_sop_type_reg   <= 3'h0;
              prl_tx_if_info_reg       <= 9'h0;
              prl_tx_if_ex_info_reg    <= 53'h0;
       end
       else if(pe2pl_tx_en) begin
              prl_tx_if_en_reg         <= 1'h1;
              prl_tx_if_type_reg       <= pe2pl_tx_type;
              prl_tx_if_sop_type_reg   <= pe2pl_tx_sop_type;
              prl_tx_if_info_reg       <= pe2pl_tx_info;
              prl_tx_if_ex_info_reg    <= pe2pl_tx_ex_info;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              pl2pe_tx_ack             <= 1'h0;
              pl2pe_tx_result          <= 2'h0;
       end
       else if(prl_tx_st_message_if_ack) begin
              pl2pe_tx_ack             <= 1'h1;
              pl2pe_tx_result          <= prl_tx_st_message_if_ack_result;
       end
       else begin
              pl2pe_tx_ack             <= 1'h0;
       end
end

//========================================================================================
//========================================================================================
//               PRL TX Message IF Decode
//========================================================================================
//========================================================================================

assign    prl_tx_if_en                             = prl_tx_if_en_reg;
assign    prl_tx_if_message_type                   = prl_tx_if_type_reg[6:5];
assign    prl_tx_if_header_type                    = prl_tx_if_type_reg[4:0];
assign    prl_tx_if_sop_type                       = prl_tx_if_sop_type_reg;

assign    prl_tx_if_source_cap_table_select        = prl_tx_if_info_reg[3:0];
assign    prl_tx_if_source_cap_current             = prl_tx_if_info_reg[4:4];

assign    prl_tx_if_alert_message_info             = prl_tx_if_info_reg[8:5];

assign    prl_tx_if_ex_message_data_size           = prl_tx_if_ex_info_reg[8:0];

assign    prl_tx_if_ex_pps_status_flag_omf         = prl_tx_if_ex_info_reg[9:9];
assign    prl_tx_if_ex_pps_status_flag_ptp         = prl_tx_if_ex_info_reg[11:10];
assign    prl_tx_if_ex_pps_status_output_current   = prl_tx_if_ex_info_reg[19:12];
assign    prl_tx_if_ex_pps_status_output_voltage   = prl_tx_if_ex_info_reg[35:20];

assign    prl_tx_if_ex_status_temp_status          = prl_tx_if_ex_info_reg[37:36];
assign    prl_tx_if_ex_status_event_flag           = prl_tx_if_ex_info_reg[40:38];
assign    prl_tx_if_ex_status_present_input        = prl_tx_if_ex_info_reg[44:41];
assign    prl_tx_if_ex_status_internal_temp        = prl_tx_if_ex_info_reg[52:45];


endmodule



