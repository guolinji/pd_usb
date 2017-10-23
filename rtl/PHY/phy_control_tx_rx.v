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
module phy_control_tx_rx(
    clk,
    rst_n,

    phy_control_tx_rx_select,
    phy_control_tx_rx_clr,

    //tx
    pl2phy_tx_packet_en,
    pl2phy_tx_packet_type,
    phy2pl_tx_packet_done,
    phy2pl_tx_packet_result,

    phy_control_tx_packet_en,
    phy_control_tx_packet_type,
    phy_control_tx_packet_done,

    phy_definition_of_idle_en,
    phy_definition_of_idle_done,
    phy_definition_of_idle_result,

    //rx
    pl2phy_rx_packet_select,
    phy2pl_rx_packet_en,
    phy2pl_rx_packet_type,
    phy2pl_rx_packet_done,
    phy2pl_rx_packet_result,

    //rx payload
    phy2pl_rx_payload,
    phy2pl_rx_payload_en,

    phy_control_rx_packet_en,
    phy_control_rx_packet_type,
    phy_control_rx_paylaod,
    phy_control_rx_paylaod_en,
    phy_control_rx_packet_eop,
    phy_control_rx_packet_crc_error,
    phy_control_rx_packet_payload_error,
    phy_control_rx_packet_timeout

    );

input     clk;
input     rst_n;

output    phy_control_tx_rx_select;
output    phy_control_tx_rx_clr;

//tx
input     pl2phy_tx_packet_en;
input     [2:0] pl2phy_tx_packet_type;
output    phy2pl_tx_packet_done;
output    phy2pl_tx_packet_result;

output    phy_control_tx_packet_en;
output    [2:0] phy_control_tx_packet_type;
input     phy_control_tx_packet_done;

output    phy_definition_of_idle_en;
input     phy_definition_of_idle_done;
input     phy_definition_of_idle_result;

//rx
input     pl2phy_rx_packet_select;
output    phy2pl_rx_packet_en;
output    [2:0] phy2pl_rx_packet_type;
output    phy2pl_rx_packet_done;
output    [1:0] phy2pl_rx_packet_result;
//rx payload
output    phy2pl_rx_payload_en;
output    [2:0] phy2pl_rx_payload;


input     phy_control_rx_packet_en;
input     [2:0] phy_control_rx_packet_type;
input     phy_control_rx_paylaod_en;
input     [3:0] phy_control_rx_paylaod;
input     phy_control_rx_packet_eop;
input     phy_control_rx_packet_crc_error;
input     phy_control_rx_packet_payload_error;
input     phy_control_rx_packet_timeout;

localparam INTER_FRAME_GAP     = 11'd1300;

localparam CTL_TX_IDLE         = 3'h0;
localparam CTL_TX_INTER_GAP    = 3'h1;
localparam CTL_TX_CHECK_CC     = 3'h2;
localparam CTL_TX_WAIT_CC_IDLE = 3'h3;
localparam CTL_TX_TRANSFER     = 3'h4;


reg       phy2pl_tx_packet_done;
reg       phy2pl_tx_packet_result;

reg       phy2pl_rx_packet_done;
reg       [1:0] phy2pl_rx_packet_result;
reg       phy2pl_rx_payload_en;
reg       [7:0] phy2pl_rx_payload;

//reg       phy_control_tx_rx_select;
reg       phy_control_tx_rx_clr;

reg       [2:0] phy_ctl_tx_cur_st;
reg       [2:0] phy_ctl_tx_nxt_st;

wire      phy_ctl_tx_cur_is_inter_gap;
wire      phy_ctl_tx_cur_is_check_cc;
wire      phy_ctl_tx_cur_is_wait_cc_idle;
wire      phy_ctl_tx_cur_is_transfer;

reg       phy_control_rx_packet_eop_dly;
reg       [10:0] phy_inter_frame_gap_timer;
reg       phy_inter_frame_gap_timer_keep;
wire      phy_inter_frame_gap_timer_done;

reg       phy_control_rx_paylaod_en_reg;
reg       [3:0] phy_control_rx_paylaod_reg;
reg       [39:0] phy_control_rx_paylaod_buffer;
reg       [3:0] phy_control_rx_paylaod_buffer_cnt;
//========================================================================================
//========================================================================================
//              inter frame gap control
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_inter_frame_gap_timer_keep <= 1'b0;
       end
       else if(phy_inter_frame_gap_timer_done) begin
              phy_inter_frame_gap_timer_keep <= 1'b0;
       end
       else if(phy2pl_tx_packet_done) begin
              phy_inter_frame_gap_timer_keep <= 1'b1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_inter_frame_gap_timer <= 11'b0;
       end
       else if(phy_inter_frame_gap_timer_done) begin
              phy_inter_frame_gap_timer <= 11'b0;
       end
       else if(phy_inter_frame_gap_timer_keep) begin
              phy_inter_frame_gap_timer <= phy_inter_frame_gap_timer + 1'b1;
       end
end

assign    phy_inter_frame_gap_timer_done        = (phy_inter_frame_gap_timer == INTER_FRAME_GAP);

//========================================================================================
//========================================================================================
//              definition of idle control
//========================================================================================
//========================================================================================

assign    phy_definition_of_idle_en        = phy_ctl_tx_cur_is_check_cc || phy_ctl_tx_cur_is_wait_cc_idle;
//========================================================================================
//========================================================================================
//              TX control state machine
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_ctl_tx_cur_st <= CTL_TX_IDLE;
       end
       else begin
              phy_ctl_tx_cur_st <= phy_ctl_tx_nxt_st;
       end
end

always @(*) begin
        phy_ctl_tx_nxt_st = phy_ctl_tx_cur_st;

        case(phy_ctl_tx_cur_st)
          CTL_TX_IDLE: begin
            if(pl2phy_tx_packet_en) begin
               phy_ctl_tx_nxt_st = CTL_TX_CHECK_CC;
            end
          end
          CTL_TX_CHECK_CC: begin
            if(phy_definition_of_idle_done && phy_definition_of_idle_result) begin
             phy_ctl_tx_nxt_st = CTL_TX_INTER_GAP;
            end
            else if(phy_definition_of_idle_done) begin
             phy_ctl_tx_nxt_st = CTL_TX_WAIT_CC_IDLE;
            end
          end
          CTL_TX_INTER_GAP: begin
            if(!phy_inter_frame_gap_timer_keep) begin
             phy_ctl_tx_nxt_st = CTL_TX_TRANSFER;
            end
          end
          CTL_TX_WAIT_CC_IDLE: begin
            if(phy_definition_of_idle_done && phy_definition_of_idle_result) begin
             phy_ctl_tx_nxt_st = CTL_TX_IDLE;
            end
          end
          CTL_TX_TRANSFER: begin
            if(phy_control_tx_packet_done) begin
             phy_ctl_tx_nxt_st = CTL_TX_IDLE;
            end
          end
	  default;
        endcase
end

assign    phy_ctl_tx_cur_is_inter_gap        = (phy_ctl_tx_cur_st == CTL_TX_INTER_GAP);
assign    phy_ctl_tx_cur_is_check_cc         = (phy_ctl_tx_cur_st == CTL_TX_CHECK_CC);
assign    phy_ctl_tx_cur_is_wait_cc_idle     = (phy_ctl_tx_cur_st == CTL_TX_WAIT_CC_IDLE);
assign    phy_ctl_tx_cur_is_transfer         = (phy_ctl_tx_cur_st == CTL_TX_TRANSFER);
//========================================================================================
//========================================================================================
//              TX control interface
//========================================================================================
//========================================================================================

always @(*) begin

          phy2pl_tx_packet_done      = 1'b0;
          phy2pl_tx_packet_result    = 1'b0;

      if(phy_ctl_tx_cur_is_transfer && phy_control_tx_packet_done) begin
          phy2pl_tx_packet_done      = 1'b1;
      end
      else if(phy_ctl_tx_cur_is_wait_cc_idle && phy_definition_of_idle_result) begin
          phy2pl_tx_packet_done      = 1'b1;
          phy2pl_tx_packet_result    = 1'b1;
      end
end

assign    phy_control_tx_packet_en        = phy_ctl_tx_cur_is_transfer;
assign    phy_control_tx_packet_type      = pl2phy_tx_packet_type;

//========================================================================================
//========================================================================================
//              RX control interface
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_control_rx_packet_eop_dly <= 1'b0;
       end
       else begin
              phy_control_rx_packet_eop_dly <= phy_control_rx_packet_eop;
       end
end


always @(*) begin

          phy2pl_rx_packet_done      = 1'h0;
          phy2pl_rx_packet_result    = 2'h0;

      if(phy_control_rx_packet_eop_dly) begin
          phy2pl_rx_packet_done      = 1'h1;
          phy2pl_rx_packet_result    = {1'h0, phy_control_rx_packet_crc_error};
      end
      else if(phy_control_rx_packet_payload_error) begin
          phy2pl_rx_packet_done      = 1'h1;
          phy2pl_rx_packet_result    = 2'h2;
      end
      else if(phy_control_rx_packet_timeout) begin
          phy2pl_rx_packet_done      = 1'h1;
          phy2pl_rx_packet_result    = 2'h3;
      end
end

assign    phy2pl_rx_packet_en        = phy_control_rx_packet_en;
assign    phy2pl_rx_packet_type      = phy_control_rx_packet_type;

//========================================================================================
//========================================================================================
//              RX Payload interface
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_control_rx_paylaod_buffer_cnt <= 4'b0;
       end
       else if(phy_control_rx_packet_eop) begin
              phy_control_rx_paylaod_buffer_cnt <= 4'b0;
       end
       else if(phy_control_rx_paylaod_buffer_cnt == 4'ha) begin
              phy_control_rx_paylaod_buffer_cnt <= 4'h8;
       end
       else if(phy_control_rx_paylaod_en) begin
           if(phy_control_rx_paylaod_buffer_cnt != 4'ha) begin
              phy_control_rx_paylaod_buffer_cnt <= phy_control_rx_paylaod_buffer_cnt + 1'b1;
           end
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_control_rx_paylaod_buffer <= 40'b0;
       end
       else if(phy_control_rx_paylaod_en) begin
              phy_control_rx_paylaod_buffer <= {phy_control_rx_paylaod, phy_control_rx_paylaod_buffer[39:4]};
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy2pl_rx_payload_en <= 1'b0;
              phy2pl_rx_payload <= 8'b0;
       end
       else if(phy_control_rx_paylaod_buffer_cnt == 4'ha) begin
              phy2pl_rx_payload_en <= 1'b1;
              phy2pl_rx_payload <= phy_control_rx_paylaod_buffer[7:0];
       end
       else begin
              phy2pl_rx_payload_en <= 1'b0;
       end
end


//========================================================================================
//========================================================================================
//               tx rx control
//========================================================================================
//========================================================================================

//always @(posedge clk or negedge rst_n) begin
//       if(!rst_n) begin
//              phy_control_tx_rx_select <= 1'b1;
//       end
//       else if(pl2phy_rx_packet_select) begin
//              phy_control_tx_rx_select <= 1'b0;
//       end
//       else if(phy2pl_rx_packet_done) begin
//              phy_control_tx_rx_select <= 1'b1;
//       end
//end

assign  phy_control_tx_rx_select =  !pl2phy_rx_packet_select;

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_control_tx_rx_clr <= 1'b0;
       end
       else if(phy2pl_rx_packet_done) begin
              phy_control_tx_rx_clr <= 1'b1;
       end
       else begin
              phy_control_tx_rx_clr <= 1'b0;
       end
end

endmodule
