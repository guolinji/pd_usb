`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:21 05/21/2017 
// Design Name: 
// Module Name:    control_tx_rx 
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
module control_tx_rx(
    clk,
    rst_n,

    control_tx_rx_select,
    control_tx_rx_clr,

    //tx
    PL2PHY_Tx_Packet_en,
    PL2PHY_Tx_Packet_type,
    PHY2PL_Tx_Packet_done,
    PHY2PL_Tx_Packet_result,

    control_tx_packet_en,
    control_tx_packet_type,
    control_tx_packet_done,

    definition_of_idle_en,
    definition_of_idle_done,
    definition_of_idle_result,
    //rx
    PL2PHY_Rx_Packet_select,
    PHY2PL_Rx_Packet_en,
    PHY2PL_Rx_Packet_type,
    PHY2PL_Rx_Packet_done,
    PHY2PL_Rx_Packet_result,

    control_rx_packet_en,
    control_rx_packet_type,
    control_rx_packet_eop,
    control_rx_packet_crc_error,
    control_rx_packet_payload_error,
    control_rx_packet_timeout

    );

input     clk;
input     rst_n;

output    control_tx_rx_select;
output    control_tx_rx_clr;

//tx
input     PL2PHY_Tx_Packet_en;
input     [2:0] PL2PHY_Tx_Packet_type;
output    PHY2PL_Tx_Packet_done;
output    PHY2PL_Tx_Packet_result;

output    control_tx_packet_en;
output    [2:0] control_tx_packet_type;
input     control_tx_packet_done;

output    definition_of_idle_en;
input     definition_of_idle_done;
input     definition_of_idle_result;
//rx
input     PL2PHY_Rx_Packet_select;
output    PHY2PL_Rx_Packet_en;
output    [2:0] PHY2PL_Rx_Packet_type;
output    PHY2PL_Rx_Packet_done;
output    [1:0] PHY2PL_Rx_Packet_result;

input     control_rx_packet_en;
input     [2:0] control_rx_packet_type;
input     control_rx_packet_eop;
input     control_rx_packet_crc_error;
input     control_rx_packet_payload_error;
input     control_rx_packet_timeout;

localparam INTER_FRAME_GAP     = 11'd1300;

localparam CTL_TX_IDLE         = 3'h0;
localparam CTL_TX_INTER_GAP    = 3'h1;
localparam CTL_TX_CHECK_CC     = 3'h2;
localparam CTL_TX_WAIT_CC_IDLE = 3'h3;
localparam CTL_TX_TRANSFER     = 3'h4;


reg       PHY2PL_Tx_Packet_done;
reg       PHY2PL_Tx_Packet_result;

reg       PHY2PL_Rx_Packet_done;
reg       [1:0] PHY2PL_Rx_Packet_result;


reg       [2:0] ctl_tx_cur_st;
reg       [2:0] ctl_tx_nxt_st;

wire      ctl_tx_cur_is_inter_gap;
wire      ctl_tx_cur_is_check_cc;
wire      ctl_tx_cur_is_wait_cc_idle;
wire      ctl_tx_cur_is_transfer;

reg       [10:0] inter_frame_gap_timer;
reg       inter_frame_gap_timer_keep;
wire      inter_frame_gap_timer_done;

//========================================================================================
//========================================================================================
//              inter frame gap control
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              inter_frame_gap_timer_keep <= 1'b0;
       end
       else if(inter_frame_gap_timer_done) begin
              inter_frame_gap_timer_keep <= 1'b0;
       end
       else if(PHY2PL_Tx_Packet_done) begin
              inter_frame_gap_timer_keep <= 1'b1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              inter_frame_gap_timer <= 11'b0;
       end
       else if(inter_frame_gap_timer_done) begin
              inter_frame_gap_timer <= 11'b0;
       end
       else if(inter_frame_gap_timer_keep) begin
              inter_frame_gap_timer <= inter_frame_gap_timer + 1'b1;
       end
end

assign    inter_frame_gap_timer_done        = (inter_frame_gap_timer == INTER_FRAME_GAP);

//========================================================================================
//========================================================================================
//              definition of idle control
//========================================================================================
//========================================================================================

assign    definition_of_idle_en        = ctl_tx_cur_is_check_cc || ctl_tx_cur_is_wait_cc_idle;
//========================================================================================
//========================================================================================
//              TX control state machine
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              ctl_tx_cur_st <= TX_IDLE;
       end
       else begin
              ctl_tx_cur_st <= ctl_tx_nxt_st;
       end
end

always @(*) begin
        ctl_tx_nxt_st = ctl_tx_cur_st;

        case(ctl_tx_cur_st)
          CTL_TX_IDLE: begin
            if(PL2PHY_Tx_Packet_en) begin
               ctl_tx_nxt_st = CTL_TX_INTER_GAP;
            end
          end
          CTL_TX_INTER_GAP: begin
            if(!inter_frame_gap_timer_keep) begin
             ctl_tx_cur_st = CTL_TX_CHECK_CC;
            end
          end
          CTL_TX_CHECK_CC: begin
            if(definition_of_idle_done && definition_of_idle_result) begin
             ctl_tx_cur_st = CTL_TX_TRANSFER;
            end
            else if(definition_of_idle_done) begin
             ctl_tx_cur_st = CTL_TX_WAIT_CC_IDLE;
            end
          end
          CTL_TX_WAIT_CC_IDLE: begin
            if(definition_of_idle_done && definition_of_idle_result) begin
             ctl_tx_cur_st = CTL_TX_IDLE;
            end
          end
          CTL_TX_TRANSFER: begin
            if(control_tx_packet_done) begin
             ctl_tx_cur_st = CTL_TX_IDLE;
            end
          end
	  default;
        endcase
end

assign    ctl_tx_cur_is_inter_gap        = (ctl_tx_cur_st == CTL_TX_INTER_GAP);
assign    ctl_tx_cur_is_check_cc         = (ctl_tx_cur_st == CTL_TX_CHECK_CC);
assign    ctl_tx_cur_is_wait_cc_idle     = (ctl_tx_cur_st == CTL_TX_WAIT_CC_IDLE);
assign    ctl_tx_cur_is_transfer         = (ctl_tx_cur_st == CTL_TX_TRANSFER);
//========================================================================================
//========================================================================================
//              TX control interface
//========================================================================================
//========================================================================================

always @(*) begin

          PHY2PL_Tx_Packet_done      = 1'b0;
          PHY2PL_Tx_Packet_result    = 1'b0;

      if(ctl_tx_cur_is_transfer && control_tx_packet_done) begin
          PHY2PL_Tx_Packet_done      = 1'b1;
      end
      else if(ctl_tx_cur_is_wait_cc_idle && definition_of_idle_result) begin
          PHY2PL_Tx_Packet_done      = 1'b1;
          PHY2PL_Tx_Packet_result    = 1'b1;
      end
end

assign    control_tx_packet_en        = ctl_tx_cur_is_transfer;
assign    control_tx_packet_type      = PL2PHY_Tx_Packet_type;

//========================================================================================
//========================================================================================
//              RX control interface
//========================================================================================
//========================================================================================

always @(*) begin

          PHY2PL_Rx_Packet_done      = 1'h0;
          PHY2PL_Rx_Packet_result    = 2'h0;

      if(control_rx_packet_eop) begin
          PHY2PL_Rx_Packet_done      = 1'h1;
          PHY2PL_Rx_Packet_result    = {1'h0, control_rx_packet_crc_error};
      end
      else if(control_rx_packet_payload_error) begin
          PHY2PL_Rx_Packet_done      = 1'h1;
          PHY2PL_Rx_Packet_result    = 2'h2;
      end
      else if(control_rx_packet_timeout) begin
          PHY2PL_Rx_Packet_done      = 1'h1;
          PHY2PL_Rx_Packet_result    = 2'h3;
      end
end

assign    PHY2PL_Rx_Packet_en        = control_tx_packet_en;
assign    PHY2PL_Rx_Packet_type      = control_tx_packet_type;

//========================================================================================
//========================================================================================
//               tx rx control
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              control_tx_rx_select <= 1'b1;
       end
       else if(PL2PHY_Rx_Packet_select) begin
              control_tx_rx_select <= 1'b0;
       end
       else if(PHY2PL_Rx_Packet_done) begin
              control_tx_rx_select <= 1'b1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              control_tx_rx_clr <= 1'b0;
       end
       else if(PHY2PL_Rx_Packet_done) begin
              control_tx_rx_clr <= 1'b1;
       end
       else begin
              control_tx_rx_clr <= 1'b0;
       end
end

endmodule
