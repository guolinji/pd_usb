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
module prl_ctl_state_machine(
    clk,
    rst_n,

    pe2pl_tx_ams_begin,
    pe2pl_tx_ams_end,
    

    prl2phy_tx_phy_reset_req,
    phy2prl_tx_phy_reset_done,

    prl2phy_rx_packet_select,

    //pe&pl reset handshake
    pl2pe_hard_reset_req,
    pl2pe_cable_reset_req,

    pe2pl_hard_reset_ack,
    pe2pl_cable_reset_ack,

    //prl rx st & rx if signal 
    prl_rx_st_inform_pe_en,
    prl_rx_st_inform_pe_result,

    //rx parser message signal
    prl_rx_parser_message_req,
    //prl_rx_parser_message_result,
    prl_rx_parser_message_type,
    prl_rx_parser_sop_type,
    prl_rx_parser_header_type,
    prl_rx_parser_message_id,

    //prl tx st construct signal
    prl_tx_st_message_construct_req,
    prl_tx_st_messageid_counter,
    prl_tx_st_message_construct_ack,
    prl_tx_st_message_construct_ack_result,

    prl_tx_st_message_if_ack,
    prl_tx_st_message_if_ack_result,

    //prl tx if signal
    prl_tx_if_en,
    prl_tx_if_sop_type,
    prl_tx_if_message_type,
    prl_tx_if_header_type,
    prl_tx_if_ex_message_data_size,

    //prl rx construct signal
    prl_rx_st_send_goodcrc_req,
    prl_rx_st_send_goodcrc_sop_type,
    prl_rx_st_send_goodcrc_messageid,
    prl_rx_st_send_goodcrc_ack,
    prl_rx_st_send_goodcrc_ack_result,

    //prl hdrst construct signal
    prl_hdrst_send_req,
    prl_hdrst_send_ack,
    prl_hdrst_send_ack_result

);

input              clk;
input              rst_n;

input              pe2pl_tx_ams_begin;
input              pe2pl_tx_ams_end;

input              phy2prl_tx_phy_reset_done;
output             prl2phy_tx_phy_reset_req;

output             prl2phy_rx_packet_select;

//pe&pl reset handshake
output             pl2pe_hard_reset_req;
output             pl2pe_cable_reset_req;
input              pe2pl_hard_reset_ack;
input              pe2pl_cable_reset_ack;

//prl rx st & rx if signal 
output             prl_rx_st_inform_pe_en;
output   [ 2:0]    prl_rx_st_inform_pe_result;

//prl_tx_if signal
input              prl_tx_if_en;
input    [ 2:0]    prl_tx_if_sop_type;
input    [ 1:0]    prl_tx_if_message_type;
input    [ 4:0]    prl_tx_if_header_type;
input    [ 8:0]    prl_tx_if_ex_message_data_size;

output             prl_tx_st_message_if_ack;
output   [ 1:0]    prl_tx_st_message_if_ack_result;

//prl rx parser signal
input              prl_rx_parser_message_req;
//input    [ 2:0]    prl_rx_parser_message_result;
input    [ 1:0]    prl_rx_parser_message_type;
input    [ 2:0]    prl_rx_parser_sop_type;
input    [ 4:0]    prl_rx_parser_header_type;
input    [ 2:0]    prl_rx_parser_message_id;

//prl tx st signal
output             prl_tx_st_message_construct_req;
output   [ 2:0]    prl_tx_st_messageid_counter;
input              prl_tx_st_message_construct_ack;
input              prl_tx_st_message_construct_ack_result;


//prl rx construct signal
output             prl_rx_st_send_goodcrc_req;
output   [ 1:0]    prl_rx_st_send_goodcrc_sop_type;
output   [ 2:0]    prl_rx_st_send_goodcrc_messageid;
input              prl_rx_st_send_goodcrc_ack;
input              prl_rx_st_send_goodcrc_ack_result;


//prl hdrst construct signal
output             prl_hdrst_send_req;
input              prl_hdrst_send_ack;
input              prl_hdrst_send_ack_result;









localparam PRL_TX_PHY_LAYER_RESET                  = 4'h0;
localparam PRL_TX_DISCARD_MESSAGE                  = 4'h1;
localparam PRL_TX_WAIT_FOR_MESSAGE_REQUEST         = 4'h2;
localparam PRL_TX_LAYER_RESET_FOR_TRANSMIT         = 4'h3;
localparam PRL_TX_CONSTRUCT_MESSAGE                = 4'h4;
localparam PRL_TX_WAIT_FOR_PHY_RESPONSE            = 4'h5;
localparam PRL_TX_MATCH_MESSAGEID                  = 4'h6;
localparam PRL_TX_CHECK_RETRYCOUNTER               = 4'h7;
localparam PRL_TX_TRANSMISSION_ERROR               = 4'h8;
localparam PRL_TX_MESSAGE_SENT                     = 4'h9;
localparam PRL_TX_SRC_SINK_TX                      = 4'ha;
localparam PRL_TX_SRC_SOURCE_TX                    = 4'hb;
localparam PRL_TX_SRC_PENDING                      = 4'hc;

localparam PRL_RX_WAIT_FOR_PHY_MESSAGE             = 3'h0;
localparam PRL_RX_LAYER_RESET_FOR_RECEIVE          = 3'h1;
localparam PRL_RX_SEND_GOODCRC                     = 3'h2;
localparam PRL_RX_CHECK_MESSAGEID                  = 3'h3;
localparam PRL_RX_STORE_MESSAGEID                  = 3'h4;

localparam PRL_HR_IDLE                             = 3'h0;
localparam PRL_HR_RESET_LAYER                      = 3'h1;
localparam PRL_HR_REQUEST_HARD_RESET               = 3'h2;
localparam PRL_HR_WAIT_FOR_PHY_HARD_RESET_COMPLETE = 3'h3;
localparam PRL_HR_PHY_HARD_RESET_REQUEST           = 3'h4;
localparam PRL_HR_INDICATE_HARD_RESET              = 3'h5;
localparam PRL_HR_WAIT_FOR_PE_HARD_RESET_COMPLETE  = 3'h6;
localparam PRL_HR_PE_HARD_RESET_COMPLETE           = 3'h7;

//timer paremeter
localparam T_RECIVE           = 4'd10;            //tRecive 1ms
localparam T_SINKTX           = 5'd18;            //tSinkTx 18ms
localparam T_HDRSTCOMPLETE    = 3'd5;             //tHardresetComplete 5ms


//counter paremeter
localparam N_RRYCOUNTER       = 2'd2;             //retry counter 2

//Protocol Layer Timer and Counter

reg      [ 2:0]    prl_tx_messageid_counter_sop;
reg      [ 2:0]    prl_tx_messageid_counter_sopp;
reg      [ 2:0]    prl_tx_messageid_counter_soppp;

reg      [ 1:0]    prl_tx_message_retrycounter;
wire               prl_tx_message_retrycounter_add;

reg                prl_rx_messageid_counter_sop_valid;
reg                prl_rx_messageid_counter_sopp_valid;
reg                prl_rx_messageid_counter_soppp_valid;

reg      [ 2:0]    prl_rx_messageid_counter_sop;
reg      [ 2:0]    prl_rx_messageid_counter_sopp;
reg      [ 2:0]    prl_rx_messageid_counter_soppp;


reg                pl2pe_hard_reset_req;
reg                pl2pe_cable_reset_req;

reg                prl2phy_rx_packet_select;

reg                prl_tx_st_message_if_ack;
reg      [ 1:0]    prl_tx_st_message_if_ack_result;

reg                prl_hdrst_send_req;

//Protocol Layer Message transmission Signal
reg      [ 3:0]    prl_tx_cur_st;
reg      [ 3:0]    prl_tx_nxt_st;

wire               prl_tx_st_is_phy_layer_reset;
wire               prl_tx_st_is_discard_message;
wire               prl_tx_st_is_wait_for_message_request;
wire               prl_tx_st_is_layer_reset_for_transmit;
wire               prl_tx_st_is_construct_message;
wire               prl_tx_st_is_wait_for_phy_response;
wire               prl_tx_st_is_match_messageid;
wire               prl_tx_st_is_check_retrycounter;
wire               prl_tx_st_is_transmission_error;
wire               prl_tx_st_is_message_sent;
wire               prl_tx_st_is_src_sink_tx;
wire               prl_tx_st_is_src_source_tx;
wire               prl_tx_st_is_src_pending;

wire               prl_tx_st_discard_message_req;
wire               prl_tx_st_discard_message_done;

wire               prl_tx_st_phy_reset_req;
wire               prl_tx_st_phy_reset_done;

reg                prl_tx_st_ams_begin_keep;
wire               prl_tx_st_ams_begin;
reg                prl_tx_st_ams_end_keep;
wire               prl_tx_st_ams_end;
wire               prl_tx_st_message_req;
wire               prl_tx_st_message_type_is_soft;

reg                prl_tx_st_message_construct_req;
wire               prl_tx_st_message_construct_ack;
wire               prl_tx_st_message_construct_ack_result;

reg                prl_tx_st_crcreceive_timer_en;
reg      [ 3:0]    prl_tx_st_crcreceive_timer;
wire               prl_tx_st_rec_crc_timeout;
wire               prl_tx_st_rec_goodcrc;

wire     [ 2:0]    prl_tx_st_messageid_counter;
wire               prl_tx_st_messageid_is_match;
wire     [ 3:0]    prl_tx_st_rec_messageid;
wire     [ 1:0]    prl_tx_st_rec_messageid_sop_type;

wire               prl_tx_st_check_retry_cable_plug;
wire               prl_tx_st_check_retry_check_retrycounter;
wire               prl_tx_st_check_retry_big_ex_message;

wire               prl_tx_st_rx_st_store_messageid;
wire               prl_tx_st_rx_message_is_sop;

wire               prl_tx_st_rx_rec_soft_reset;
wire               prl_tx_st_exit_form_hardreset;

wire               prl_tx_st_sinker_timer_done;
reg     [ 3:0]     prl_tx_st_sinker_timer;


//Protocol Layer Message recepiton Signal
reg     [ 2:0]     prl_rx_cur_st;
reg     [ 2:0]     prl_rx_nxt_st;

wire               prl_rx_st_is_wait_for_phy_message;
wire               prl_rx_st_is_layer_reset_for_receive;
wire               prl_rx_st_is_send_goodcrc;
wire               prl_rx_st_is_check_messageid;
wire               prl_rx_st_is_store_messageid;

wire               prl_rx_st_enter_send_goodcrc;
wire               prl_rx_st_exit_send_goodcrc;

wire               prl_rx_st_rec_message_en;
wire               prl_rx_st_rec_message_is_soft_reset;

wire               prl_rx_st_tx_send_soft_reset;
wire               prl_rx_st_exit_form_hardreset;

wire               prl_rx_st_send_goodcrc_req;
wire               prl_rx_st_send_goodcrc_ack;
wire               prl_rx_st_send_goodcrc_ack_result;

wire               prl_rx_st_messageid_match;
wire               prl_rx_st_messageid_counter_valid;
wire     [ 2:0]    prl_rx_st_messageid_counter;
reg      [ 2:0]    prl_rx_st_rec_messageid;
reg      [ 1:0]    prl_rx_st_message_sop_type;


//Protocol Layer Message hard/cable reset Signal
reg      [ 2:0]    prl_hdrst_cur_st;
reg      [ 2:0]    prl_hdrst_nxt_st;

wire               prl_hdrst_st_is_reset_layer;
wire               prl_hdrst_st_is_request_hard_reset;
wire               prl_hdrst_st_is_wait_for_phy_hard_reset_complete;
wire               prl_hdrst_st_is_phy_hard_reset_request;
wire               prl_hdrst_st_is_indicate_hard_reset;
wire               prl_hdrst_st_is_wait_for_pe_hard_reset_complete;
wire               prl_hdrst_st_is_pe_hard_reset_complete;

wire               prl_hdrst_st_hard_reset_from_pe;
wire               prl_hdrst_st_cable_reset_from_pe;
wire               prl_hdrst_st_hard_reset_rec_by_phy;
wire               prl_hdrst_st_cable_reset_rec_by_phy;

wire               prl_hdrst_st_reset_from_pe;
wire               prl_hdrst_st_reset_rec_by_phy;

wire               prl_hdrst_st_reset_complete_by_phy;
reg      [ 2:0]    prl_hdrst_st_hardreset_complete_timer;
wire               prl_hdrst_st_reset_rec_phy_timeout;

wire               prl_hdrst_st_reset_req_to_pe;
wire               prl_hdrst_st_reset_complete_by_pe;

reg                prl_hdrst_st_reset_timeout_keep;
reg                prl_hdrst_st_reset_complete_by_phy_keep;

//time scale 
reg      [ 4:0]    prl_time_scale_cnt_10us;
reg      [ 3:0]    prl_time_scale_cnt_100us;
reg      [ 3:0]    prl_time_scale_cnt_1ms;
wire               prl_time_scale_10us;
wire               prl_time_scale_100us;
wire               prl_time_scale_1ms;

//========================================================================================
//========================================================================================
//               Protocol Layer Message transmission State Machine
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_cur_st <= PRL_TX_WAIT_FOR_MESSAGE_REQUEST;
       end
       else if(prl_tx_st_rx_rec_soft_reset || prl_tx_st_exit_form_hardreset) begin
              prl_tx_cur_st <= PRL_TX_PHY_LAYER_RESET;
       end
       else if(prl_hdrst_st_is_reset_layer) begin
              prl_tx_cur_st <= PRL_TX_WAIT_FOR_MESSAGE_REQUEST;
       end
       else if(prl_tx_st_rx_st_store_messageid && prl_tx_st_rx_message_is_sop && !prl_tx_st_is_wait_for_phy_response) begin
              prl_tx_cur_st <= PRL_TX_DISCARD_MESSAGE;
       end
       else begin
              prl_tx_cur_st <= prl_tx_nxt_st;
       end
end

assign prl_tx_st_is_phy_layer_reset              =  (prl_tx_cur_st == PRL_TX_PHY_LAYER_RESET         );
assign prl_tx_st_is_discard_message              =  (prl_tx_cur_st == PRL_TX_DISCARD_MESSAGE         );
assign prl_tx_st_is_wait_for_message_request     =  (prl_tx_cur_st == PRL_TX_WAIT_FOR_MESSAGE_REQUEST);
assign prl_tx_st_is_layer_reset_for_transmit     =  (prl_tx_cur_st == PRL_TX_LAYER_RESET_FOR_TRANSMIT);
assign prl_tx_st_is_construct_message            =  (prl_tx_cur_st == PRL_TX_CONSTRUCT_MESSAGE       );
assign prl_tx_st_is_wait_for_phy_response        =  (prl_tx_cur_st == PRL_TX_WAIT_FOR_PHY_RESPONSE   );
assign prl_tx_st_is_match_messageid              =  (prl_tx_cur_st == PRL_TX_MATCH_MESSAGEID         );
assign prl_tx_st_is_check_retrycounter           =  (prl_tx_cur_st == PRL_TX_CHECK_RETRYCOUNTER      );
assign prl_tx_st_is_transmission_error           =  (prl_tx_cur_st == PRL_TX_TRANSMISSION_ERROR      );
assign prl_tx_st_is_message_sent                 =  (prl_tx_cur_st == PRL_TX_MESSAGE_SENT            );
assign prl_tx_st_is_src_sink_tx                  =  (prl_tx_cur_st == PRL_TX_SRC_SINK_TX             );
assign prl_tx_st_is_src_source_tx                =  (prl_tx_cur_st == PRL_TX_SRC_SOURCE_TX           );
assign prl_tx_st_is_src_pending                  =  (prl_tx_cur_st == PRL_TX_SRC_PENDING             );                


always @(*) begin
        prl_tx_nxt_st = prl_tx_cur_st;

        case(prl_tx_cur_st)
          PRL_TX_DISCARD_MESSAGE: begin
                if(!prl_tx_st_rx_message_is_sop) begin
                   prl_tx_nxt_st = PRL_TX_PHY_LAYER_RESET;
                end
                else if(prl_tx_st_discard_message_done) begin
                   prl_tx_nxt_st = PRL_TX_PHY_LAYER_RESET;
                end
          end
          PRL_TX_PHY_LAYER_RESET: begin
                if(prl_tx_st_phy_reset_done) begin
                   prl_tx_nxt_st = PRL_TX_WAIT_FOR_MESSAGE_REQUEST;
                end
          end
          PRL_TX_WAIT_FOR_MESSAGE_REQUEST: begin
                if(prl_tx_st_ams_end_keep || prl_tx_st_ams_end) begin
                      prl_tx_nxt_st = PRL_TX_SRC_SINK_TX;
                end
                else if(prl_tx_st_ams_begin_keep || prl_tx_st_ams_begin) begin
                      prl_tx_nxt_st = PRL_TX_SRC_SOURCE_TX;
                end
                else if(prl_tx_st_message_req) begin
                   if(prl_tx_st_message_type_is_soft) begin  //message is soft message
                      prl_tx_nxt_st = PRL_TX_LAYER_RESET_FOR_TRANSMIT;
                   end
	           else begin
                      prl_tx_nxt_st = PRL_TX_CONSTRUCT_MESSAGE;
                   end
                end
          end
          PRL_TX_CONSTRUCT_MESSAGE: begin
                prl_tx_nxt_st = PRL_TX_WAIT_FOR_PHY_RESPONSE;
          end
          PRL_TX_WAIT_FOR_PHY_RESPONSE: begin
                if(prl_tx_st_message_construct_ack && prl_tx_st_message_construct_ack_result) begin   //cc is not idle, message send failure
                      prl_tx_nxt_st = PRL_TX_CHECK_RETRYCOUNTER;
                end
                else if(prl_tx_st_rec_crc_timeout) begin //CRCReceiveTimer timeout
                      prl_tx_nxt_st = PRL_TX_CHECK_RETRYCOUNTER;
                end
                else if(prl_tx_st_rec_goodcrc) begin //GoodCRC Receive
                      prl_tx_nxt_st = PRL_TX_MATCH_MESSAGEID;
                end
          end
          PRL_TX_MATCH_MESSAGEID: begin
                if(prl_tx_st_messageid_is_match) begin
                   prl_tx_nxt_st = PRL_TX_MESSAGE_SENT;
                end
                else begin
                   prl_tx_nxt_st = PRL_TX_CHECK_RETRYCOUNTER;
                end
          end
          PRL_TX_MESSAGE_SENT: begin
                prl_tx_nxt_st = PRL_TX_WAIT_FOR_MESSAGE_REQUEST;
          end
          PRL_TX_CHECK_RETRYCOUNTER: begin
                if(prl_tx_st_check_retry_cable_plug) begin
                      prl_tx_nxt_st = PRL_TX_TRANSMISSION_ERROR;
                end
                else if(prl_tx_st_check_retry_check_retrycounter) begin
                      prl_tx_nxt_st = PRL_TX_TRANSMISSION_ERROR;
                end
                else if(prl_tx_st_check_retry_big_ex_message) begin
                      prl_tx_nxt_st = PRL_TX_TRANSMISSION_ERROR;
                end
	        else begin
                      prl_tx_nxt_st = PRL_TX_CONSTRUCT_MESSAGE;
                end
          end
          PRL_TX_TRANSMISSION_ERROR: begin
                prl_tx_nxt_st = PRL_TX_WAIT_FOR_MESSAGE_REQUEST;
          end
          PRL_TX_LAYER_RESET_FOR_TRANSMIT: begin
                prl_tx_nxt_st = PRL_TX_CONSTRUCT_MESSAGE;
          end
          PRL_TX_SRC_SINK_TX: begin
                prl_tx_nxt_st = PRL_TX_WAIT_FOR_MESSAGE_REQUEST;
          end
          PRL_TX_SRC_SOURCE_TX: begin
                if(prl_tx_st_message_req) begin
                   prl_tx_nxt_st = PRL_TX_SRC_PENDING;
                end
          end
          PRL_TX_SRC_PENDING: begin
                if(prl_tx_st_sinker_timer_done) begin
                   if(prl_tx_st_message_type_is_soft) begin  //message is soft message
                      prl_tx_nxt_st = PRL_TX_LAYER_RESET_FOR_TRANSMIT;
                   end
	           else begin
                      prl_tx_nxt_st = PRL_TX_CONSTRUCT_MESSAGE;
                   end
                end
          end
	  default;
        endcase
end

//========================================================================================
//========================================================================================
//               PRL Tx Message Control Signal Generate
//========================================================================================
//========================================================================================

//Tx requeset phy reset
assign  prl_tx_st_phy_reset_req          = prl_tx_st_is_phy_layer_reset;
assign  prl_tx_st_phy_reset_done         = phy2prl_tx_phy_reset_done;
assign  prl2phy_tx_phy_reset_req         = prl_tx_st_phy_reset_req;


//Tx message transmission requeset
assign  prl_tx_st_message_req            = prl_tx_if_en && (prl_tx_if_sop_type < 3'h3);
assign  prl_tx_st_message_type_is_soft   = (prl_tx_if_header_type == 5'b0_1101) && (prl_tx_if_message_type == 2'h0);

assign  prl_tx_st_rec_messageid_sop_type = prl_rx_parser_sop_type;


//rx receive soft reset message or hardreset
assign  prl_tx_st_rx_rec_soft_reset      = prl_rx_st_is_layer_reset_for_receive;
assign  prl_tx_st_exit_form_hardreset    = prl_hdrst_st_is_pe_hard_reset_complete;

//rx receive message sop type
assign  prl_tx_st_rx_message_is_sop      = (prl_rx_parser_sop_type == 3'h0);

//AMS begin&end control
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_st_ams_end_keep <= 1'h0;
       end
       else if(pe2pl_tx_ams_end) begin
              prl_tx_st_ams_end_keep <= 1'h1;
       end
       else if(prl_tx_st_is_src_sink_tx) begin
              prl_tx_st_ams_end_keep <= 1'h0;
       end
end

assign  prl_tx_st_ams_end        = pe2pl_tx_ams_end;

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_st_ams_begin_keep <= 1'h0;
       end
       else if(pe2pl_tx_ams_begin) begin
              prl_tx_st_ams_begin_keep <= 1'h1;
       end
       else if(prl_tx_st_is_src_source_tx) begin
              prl_tx_st_ams_begin_keep <= 1'h0;
       end
end

assign  prl_tx_st_ams_begin      = pe2pl_tx_ams_begin;
//Tx message construct control
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_st_message_construct_req <= 1'h0;
       end
       else if(prl_tx_st_message_construct_ack) begin
              prl_tx_st_message_construct_req <= 1'h0;
       end
       else if(prl_tx_st_is_construct_message) begin
              prl_tx_st_message_construct_req <= 1'h1;
       end
end

//Tx phy respond & crcrecive timer control
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_st_crcreceive_timer_en <= 1'h0;
       end
       else if(prl_tx_st_message_construct_ack && !prl_tx_st_message_construct_ack_result) begin
              prl_tx_st_crcreceive_timer_en <= 1'h1;
       end
       else if(prl_tx_st_rec_crc_timeout || prl_tx_st_rec_goodcrc) begin
              prl_tx_st_crcreceive_timer_en <= 1'h0;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_st_crcreceive_timer <= 4'h0;
       end
       else if(prl_tx_st_rec_crc_timeout || prl_tx_st_rec_goodcrc) begin
              prl_tx_st_crcreceive_timer <= 4'h0;
       end
       else if(prl_tx_st_crcreceive_timer_en) begin
           if(prl_time_scale_100us) begin
              prl_tx_st_crcreceive_timer <= prl_tx_st_crcreceive_timer + 1'h1;
           end
       end
end

assign  prl_tx_st_rec_crc_timeout = (prl_tx_st_crcreceive_timer == T_RECIVE); 

assign  prl_tx_st_rec_goodcrc     = prl_rx_parser_message_req && (prl_rx_parser_header_type == 5'b0_0001) && (prl_rx_parser_message_type == 2'h0);

//Tx messageid counter 

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_messageid_counter_sop         <= 3'h0;
              prl_rx_messageid_counter_sop_valid   <= 1'h0;
              prl_rx_messageid_counter_sop         <= 3'h0;
       end
       else if(prl_tx_st_is_layer_reset_for_transmit && (prl_tx_if_sop_type == 3'h0)) begin
              prl_tx_messageid_counter_sop         <= 3'h0;
              prl_rx_messageid_counter_sop_valid   <= 1'h0;
              prl_rx_messageid_counter_sop         <= 3'h0;
       end
       else if(prl_rx_st_is_layer_reset_for_receive &&  (prl_rx_parser_sop_type == 3'h0)) begin
              prl_tx_messageid_counter_sop         <= 3'h0;
              prl_rx_messageid_counter_sop_valid   <= 1'h0;
              prl_rx_messageid_counter_sop         <= 3'h0;
       end
       else if(prl_hdrst_st_hard_reset_from_pe && (prl_tx_if_sop_type == 3'h0)) begin
              prl_tx_messageid_counter_sop         <= 3'h0;
              prl_rx_messageid_counter_sop_valid   <= 1'h0;
              prl_rx_messageid_counter_sop         <= 3'h0;
       end
       else if(prl_hdrst_st_hard_reset_rec_by_phy && (prl_rx_parser_sop_type == 3'h0)) begin
              prl_tx_messageid_counter_sop         <= 3'h0;
              prl_rx_messageid_counter_sop_valid   <= 1'h0;
              prl_rx_messageid_counter_sop         <= 3'h0;
       end
       else begin
           if(prl_tx_st_is_transmission_error || prl_tx_st_is_message_sent) begin
               if(prl_tx_if_sop_type == 3'h0) begin
                  prl_tx_messageid_counter_sop         <= prl_tx_messageid_counter_sop + 1'h1;
               end
           end

          if((prl_rx_st_is_store_messageid) && (prl_rx_st_message_sop_type == 2'h0)) begin
                  prl_rx_messageid_counter_sop         <= prl_rx_parser_message_id;
                  prl_rx_messageid_counter_sop_valid   <= 1'h1;
          end

       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_messageid_counter_sopp         <= 3'h0;
              prl_rx_messageid_counter_sopp         <= 3'h0;
              prl_rx_messageid_counter_sopp_valid   <= 1'h0;
       end
       else if(prl_tx_st_is_layer_reset_for_transmit && (prl_tx_if_sop_type == 3'h1)) begin
              prl_tx_messageid_counter_sopp  <= 3'h0;
              prl_rx_messageid_counter_sopp  <= 3'h0;
              prl_rx_messageid_counter_sopp_valid   <= 1'h0;
       end
       else if(prl_rx_st_is_layer_reset_for_receive &&  (prl_rx_parser_sop_type == 3'h1)) begin
              prl_tx_messageid_counter_sopp         <= 3'h0;
              prl_rx_messageid_counter_sopp         <= 3'h0;
              prl_rx_messageid_counter_sopp_valid   <= 1'h0;
       end
       else if(prl_hdrst_st_cable_reset_from_pe && (prl_tx_if_sop_type == 3'h1)) begin
              prl_tx_messageid_counter_sopp         <= 3'h0;
              prl_rx_messageid_counter_sopp         <= 3'h0;
              prl_rx_messageid_counter_sopp_valid   <= 1'h0;
       end
       else if(prl_hdrst_st_cable_reset_rec_by_phy && (prl_rx_parser_sop_type == 3'h1)) begin
              prl_tx_messageid_counter_sopp         <= 3'h0;
              prl_rx_messageid_counter_sopp         <= 3'h0;
              prl_rx_messageid_counter_sopp_valid   <= 1'h0;
       end
       else begin
           if(prl_tx_st_is_transmission_error || prl_tx_st_is_message_sent) begin
               if(prl_tx_if_sop_type == 3'h1) begin
                  prl_tx_messageid_counter_sopp <= prl_tx_messageid_counter_sopp + 1'h1;
               end
           end

          if((prl_rx_st_is_store_messageid) && (prl_rx_st_message_sop_type == 2'h1)) begin
              prl_rx_messageid_counter_sopp          <= prl_rx_parser_message_id;
              prl_rx_messageid_counter_sopp_valid    <= 1'h0;
          end

       end
end


always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_messageid_counter_soppp          <= 3'h0;
              prl_rx_messageid_counter_soppp_valid    <= 1'h0;
              prl_rx_messageid_counter_soppp          <= 3'h0;
       end
       else if(prl_tx_st_is_layer_reset_for_transmit && (prl_tx_if_sop_type == 3'h2)) begin
              prl_tx_messageid_counter_soppp          <= 3'h0;
              prl_rx_messageid_counter_soppp_valid    <= 1'h0;
              prl_rx_messageid_counter_soppp          <= 3'h0;
       end
       else if(prl_rx_st_is_layer_reset_for_receive &&  (prl_rx_parser_sop_type == 3'h2)) begin
              prl_tx_messageid_counter_soppp          <= 3'h0;
              prl_rx_messageid_counter_soppp_valid    <= 1'h0;
              prl_rx_messageid_counter_soppp          <= 3'h0;
       end
       else if(prl_hdrst_st_cable_reset_from_pe && (prl_tx_if_sop_type == 3'h2)) begin
              prl_tx_messageid_counter_soppp          <= 3'h0;
              prl_rx_messageid_counter_soppp_valid    <= 1'h0;
              prl_rx_messageid_counter_soppp          <= 3'h0;
       end
       else if(prl_hdrst_st_cable_reset_rec_by_phy && (prl_rx_parser_sop_type == 3'h2)) begin
              prl_tx_messageid_counter_soppp          <= 3'h0;
              prl_rx_messageid_counter_soppp_valid    <= 1'h0;
              prl_rx_messageid_counter_soppp          <= 3'h0;
       end
       else begin
           if(prl_tx_st_is_transmission_error || prl_tx_st_is_message_sent) begin
               if(prl_tx_if_sop_type == 3'h2) begin
                  prl_tx_messageid_counter_soppp <= prl_tx_messageid_counter_soppp + 1'h1;
               end
           end

          if((prl_rx_st_is_store_messageid) && (prl_rx_st_message_sop_type == 2'h2)) begin
              prl_rx_messageid_counter_soppp_valid      <= 1'h1;
              prl_rx_messageid_counter_soppp            <= prl_rx_parser_message_id;
          end

       end
end




//Tx messageid compare 
assign  prl_tx_st_messageid_counter = (prl_tx_st_rec_messageid_sop_type == 2'h0) ? prl_tx_messageid_counter_sop   :
                                      (prl_tx_st_rec_messageid_sop_type == 2'h1) ? prl_tx_messageid_counter_sopp  :
	                                                                           prl_tx_messageid_counter_soppp ; 

assign  prl_tx_st_messageid_is_match = (prl_tx_st_rec_messageid == prl_tx_st_messageid_counter) ; 
assign  prl_tx_st_rec_messageid      = prl_rx_parser_message_id;

//Tx messageid retry check 
assign  prl_tx_st_check_retry_cable_plug         = (prl_tx_if_sop_type != 2'h0); 
assign  prl_tx_st_check_retry_check_retrycounter = (prl_tx_message_retrycounter == N_RRYCOUNTER); 
assign  prl_tx_st_check_retry_big_ex_message     = (prl_tx_if_message_type == 2'h2) && (prl_tx_if_ex_message_data_size > 9'd26); 

assign  prl_tx_message_retrycounter_add          = !(prl_tx_st_check_retry_cable_plug  || prl_tx_st_check_retry_big_ex_message);

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_message_retrycounter <= 2'h0;
       end
       else if(prl_tx_st_is_transmission_error || prl_tx_st_is_message_sent) begin
              prl_tx_message_retrycounter <= 2'h0;
       end
       else if(prl_tx_st_is_check_retrycounter) begin
           if(prl_tx_message_retrycounter_add) begin
              prl_tx_message_retrycounter <= prl_tx_message_retrycounter + 1'h1;
           end
       end
end

//Tx messageid discard for receive message 
assign  prl_tx_st_rx_st_store_messageid     = prl_rx_st_is_store_messageid; 




//Tx messageid sinker timeout
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_st_sinker_timer <= 4'h0;
       end
       else if(prl_tx_st_is_src_pending) begin
           if(prl_time_scale_1ms) begin
              prl_tx_st_sinker_timer <= prl_tx_st_sinker_timer + 1'h1;
           end
       end
       else begin
              prl_tx_st_sinker_timer <= 4'h0;
       end
end

assign  prl_tx_st_sinker_timer_done = (prl_tx_st_sinker_timer == T_SINKTX); 



//========================================================================================
//========================================================================================
//               Protocol Layer Message reception State Machine
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_cur_st <= PRL_RX_WAIT_FOR_PHY_MESSAGE;
       end
       else if(prl_rx_st_tx_send_soft_reset || prl_rx_st_exit_form_hardreset || prl_hdrst_st_is_reset_layer) begin
              prl_rx_cur_st <= PRL_RX_WAIT_FOR_PHY_MESSAGE;
       end
       else begin
              prl_rx_cur_st <= prl_rx_nxt_st;
       end
end

assign  prl_rx_st_is_wait_for_phy_message        = (prl_rx_cur_st == PRL_RX_WAIT_FOR_PHY_MESSAGE    );
assign  prl_rx_st_is_layer_reset_for_receive     = (prl_rx_cur_st == PRL_RX_LAYER_RESET_FOR_RECEIVE );
assign  prl_rx_st_is_send_goodcrc                = (prl_rx_cur_st == PRL_RX_SEND_GOODCRC            );
assign  prl_rx_st_is_check_messageid             = (prl_rx_cur_st == PRL_RX_CHECK_MESSAGEID         );
assign  prl_rx_st_is_store_messageid             = (prl_rx_cur_st == PRL_RX_STORE_MESSAGEID         );         

always @(*) begin
        prl_rx_nxt_st = prl_rx_cur_st;

        case(prl_rx_cur_st)
          PRL_RX_WAIT_FOR_PHY_MESSAGE: begin
               if(prl_rx_st_rec_message_en) begin
                  if(prl_rx_st_rec_message_is_soft_reset) begin  //receive message is soft message
                     prl_rx_nxt_st = PRL_RX_LAYER_RESET_FOR_RECEIVE;
                  end
	          else begin
                     prl_rx_nxt_st = PRL_RX_SEND_GOODCRC;
                  end
               end
          end
          PRL_RX_LAYER_RESET_FOR_RECEIVE: begin
               prl_rx_nxt_st = PRL_RX_SEND_GOODCRC;
          end
          PRL_RX_SEND_GOODCRC: begin
               if(prl_rx_st_send_goodcrc_ack) begin
                  if(prl_rx_st_send_goodcrc_ack_result) begin  //cc is not idle, message discard
                     prl_rx_nxt_st = PRL_RX_WAIT_FOR_PHY_MESSAGE;
                  end
	          else begin
                     prl_rx_nxt_st = PRL_RX_CHECK_MESSAGEID;
                  end
               end
          end
          PRL_RX_CHECK_MESSAGEID: begin
               if(prl_rx_st_rec_message_is_soft_reset) begin  
                  prl_rx_nxt_st = PRL_RX_STORE_MESSAGEID;
               end
               else if(prl_rx_st_messageid_match) begin  //message retry
                  prl_rx_nxt_st = PRL_RX_WAIT_FOR_PHY_MESSAGE;
               end
	       else begin
                  prl_rx_nxt_st = PRL_RX_STORE_MESSAGEID;
               end
          end
          PRL_RX_STORE_MESSAGEID: begin
                  prl_rx_nxt_st = PRL_RX_WAIT_FOR_PHY_MESSAGE;
          end
	  default;
        endcase
end

//========================================================================================
//========================================================================================
//               PRL Rx Message Control Signal Generate
//========================================================================================
//========================================================================================
//
assign  prl_rx_st_rec_message_en               = prl_rx_parser_message_req && (prl_rx_parser_sop_type < 3'h3) && 
	                                         !((prl_rx_parser_header_type == 5'b0_0001) && (prl_rx_parser_message_type == 2'h0)); 
assign  prl_rx_st_rec_message_is_soft_reset    = (prl_rx_parser_header_type == 5'b1_0110) && (prl_rx_parser_message_type == 2'h0); 

assign  prl_rx_st_tx_send_soft_reset           = prl_tx_st_is_layer_reset_for_transmit;
assign  prl_rx_st_exit_form_hardreset          = prl_hdrst_st_is_pe_hard_reset_complete;

assign  prl_rx_st_send_goodcrc_req        = prl_rx_st_is_send_goodcrc; 
assign  prl_rx_st_send_goodcrc_sop_type   = prl_rx_st_message_sop_type; 
assign  prl_rx_st_send_goodcrc_messageid  = prl_rx_st_rec_messageid; 

assign  prl_rx_st_inform_pe_en      = prl_rx_st_is_store_messageid; 
assign  prl_rx_st_inform_pe_result  = 3'h0; 

assign  prl_rx_st_messageid_match   = (prl_rx_st_rec_messageid == prl_rx_st_messageid_counter); 
//Rx messageid compare 
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_st_message_sop_type <= 2'h0;
              prl_rx_st_rec_messageid    <= 3'h0;
       end
       else if(prl_rx_parser_message_req) begin
              prl_rx_st_message_sop_type <= prl_rx_parser_sop_type[1:0];
              prl_rx_st_rec_messageid    <= prl_rx_parser_message_id;
       end
end

assign  prl_rx_st_messageid_counter_valid = (prl_rx_st_message_sop_type == 2'h0) ? prl_rx_messageid_counter_sop_valid   :
                                            (prl_rx_st_message_sop_type == 2'h1) ? prl_rx_messageid_counter_sopp_valid  :
	                                                                           prl_rx_messageid_counter_soppp_valid ; 

assign  prl_rx_st_messageid_counter = (prl_rx_st_message_sop_type == 2'h0) ? prl_rx_messageid_counter_sop   :
                                      (prl_rx_st_message_sop_type == 2'h1) ? prl_rx_messageid_counter_sopp  :
	                                                                     prl_rx_messageid_counter_soppp ; 

assign  prl_rx_st_messageid_match   = prl_rx_st_messageid_counter_valid ? (prl_rx_st_rec_messageid == prl_rx_st_messageid_counter) : 1'b0; 

//========================================================================================
//========================================================================================
//               Protocol Layer Message Hardreset State Machine
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_hdrst_cur_st <= PRL_HR_IDLE;
       end
       else begin
              prl_hdrst_cur_st <= prl_hdrst_nxt_st;
       end
end

assign      prl_hdrst_st_is_reset_layer                        =  (prl_hdrst_cur_st == PRL_HR_RESET_LAYER                      );
assign      prl_hdrst_st_is_request_hard_reset                 =  (prl_hdrst_cur_st == PRL_HR_REQUEST_HARD_RESET               );
assign      prl_hdrst_st_is_wait_for_phy_hard_reset_complete   =  (prl_hdrst_cur_st == PRL_HR_WAIT_FOR_PHY_HARD_RESET_COMPLETE );
assign      prl_hdrst_st_is_phy_hard_reset_request             =  (prl_hdrst_cur_st == PRL_HR_PHY_HARD_RESET_REQUEST           );
assign      prl_hdrst_st_is_indicate_hard_reset                =  (prl_hdrst_cur_st == PRL_HR_INDICATE_HARD_RESET              );
assign      prl_hdrst_st_is_wait_for_pe_hard_reset_complete    =  (prl_hdrst_cur_st == PRL_HR_WAIT_FOR_PE_HARD_RESET_COMPLETE  );
assign      prl_hdrst_st_is_pe_hard_reset_complete             =  (prl_hdrst_cur_st == PRL_HR_PE_HARD_RESET_COMPLETE           );


always @(*) begin
        prl_hdrst_nxt_st = prl_hdrst_cur_st;

        case(prl_hdrst_cur_st)
          PRL_HR_IDLE: begin
               if(prl_hdrst_st_reset_from_pe || prl_hdrst_st_reset_rec_by_phy) begin
                     prl_hdrst_nxt_st = PRL_HR_RESET_LAYER;
               end
          end
          PRL_HR_RESET_LAYER: begin
               if(prl_hdrst_st_reset_from_pe) begin
                     prl_hdrst_nxt_st = PRL_HR_REQUEST_HARD_RESET;
               end
               else if(prl_hdrst_st_reset_rec_by_phy) begin
                     prl_hdrst_nxt_st = PRL_HR_INDICATE_HARD_RESET;
               end
          end
          PRL_HR_REQUEST_HARD_RESET: begin
                     prl_hdrst_nxt_st = PRL_HR_WAIT_FOR_PHY_HARD_RESET_COMPLETE;
          end
          PRL_HR_WAIT_FOR_PHY_HARD_RESET_COMPLETE: begin
               if(prl_hdrst_st_reset_complete_by_phy || prl_hdrst_st_reset_rec_phy_timeout) begin  
                     prl_hdrst_nxt_st = PRL_HR_PHY_HARD_RESET_REQUEST;
               end
          end
          PRL_HR_PHY_HARD_RESET_REQUEST: begin
                  prl_rx_nxt_st = PRL_HR_WAIT_FOR_PE_HARD_RESET_COMPLETE;
          end
          PRL_HR_WAIT_FOR_PE_HARD_RESET_COMPLETE: begin
               if(prl_hdrst_st_reset_complete_by_pe) begin  
                     prl_hdrst_nxt_st = PRL_HR_PE_HARD_RESET_COMPLETE;
               end
          end
          PRL_HR_PE_HARD_RESET_COMPLETE: begin
                     prl_hdrst_nxt_st = PRL_HR_IDLE;
               //if(prl_hdrst_st_reset_complete_by_phy_keep) begin  
               //      prl_hdrst_nxt_st = PRL_HR_IDLE;
               //end
               //else if(prl_hdrst_st_reset_timeout_keep) begin  
               //   if(prl_hdrst_st_reset_complete_by_phy) begin  
               //      prl_hdrst_nxt_st = PRL_HR_IDLE;
               //   end
               //end
          end
	  default;
        endcase
end

//========================================================================================
//========================================================================================
//               PRL Hard Reset Message Control Signal Generate
//========================================================================================
//========================================================================================
//reset indicate from pe or phy
assign  prl_hdrst_st_hard_reset_from_pe      = prl_tx_if_en && (prl_tx_if_sop_type == 3'h3);
assign  prl_hdrst_st_cable_reset_from_pe     = prl_tx_if_en && (prl_tx_if_sop_type == 3'h4);

assign  prl_hdrst_st_hard_reset_rec_by_phy   = prl_rx_parser_message_req && (prl_rx_parser_sop_type == 3'h3);
assign  prl_hdrst_st_cable_reset_rec_by_phy  = prl_rx_parser_message_req && (prl_rx_parser_sop_type == 3'h4);

assign  prl_hdrst_st_reset_from_pe           = prl_hdrst_st_hard_reset_from_pe || prl_hdrst_st_cable_reset_from_pe;     
assign  prl_hdrst_st_reset_rec_by_phy        = prl_hdrst_st_hard_reset_rec_by_phy || prl_hdrst_st_cable_reset_rec_by_phy;     

assign  prl_hdrst_st_reset_complete_by_phy   = prl_hdrst_send_ack && !prl_hdrst_send_ack_result ;


//hard reset complete timer timeout
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_hdrst_st_hardreset_complete_timer <= 3'h0;
       end
       else if(prl_hdrst_st_is_wait_for_phy_hard_reset_complete) begin
           if(prl_time_scale_1ms) begin
              prl_hdrst_st_hardreset_complete_timer <= prl_hdrst_st_hardreset_complete_timer + 1'h1;
           end
       end
       else begin
              prl_hdrst_st_hardreset_complete_timer <= 3'h0;
       end
end

assign  prl_hdrst_st_reset_rec_phy_timeout = (prl_hdrst_st_hardreset_complete_timer == T_HDRSTCOMPLETE); 

//hard reset req informed to pe
assign  prl_hdrst_st_reset_req_to_pe      = prl_hdrst_st_is_phy_hard_reset_request;
assign  prl_hdrst_st_reset_complete_by_pe = pe2pl_hard_reset_ack || pe2pl_cable_reset_ack;


always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_hdrst_st_reset_complete_by_phy_keep <= 1'h0;
              prl_hdrst_st_reset_timeout_keep         <= 1'h0;
       end
       else if(prl_hdrst_st_is_wait_for_phy_hard_reset_complete) begin
           if(prl_hdrst_st_reset_complete_by_phy) begin
              prl_hdrst_st_reset_complete_by_phy_keep <= 1'h1;
           end

           if(prl_hdrst_st_reset_rec_phy_timeout) begin
              prl_hdrst_st_reset_timeout_keep         <= 1'h1;
           end

       end
       else if(prl_hdrst_st_is_indicate_hard_reset) begin
              prl_hdrst_st_reset_complete_by_phy_keep <= 1'h0;
              prl_hdrst_st_reset_timeout_keep         <= 1'h0;
       end
end

//========================================================================================
//========================================================================================
//               PRL Tx Construct Signal Generate
//========================================================================================
//========================================================================================

//========================================================================================
//========================================================================================
//               PRL & PE Control Signal Generate
//========================================================================================
//========================================================================================

//========================================================================================
//========================================================================================
//               PRL TX ST & IF Control Signal Generate
//========================================================================================
//========================================================================================

always @(*) begin
        prl_tx_st_message_if_ack        = 1'b0;
        prl_tx_st_message_if_ack_result = 2'b0;

        if(prl_tx_st_is_transmission_error) begin
             prl_tx_st_message_if_ack        = 1'b1;
             prl_tx_st_message_if_ack_result = 2'h1;
        end
        else if(prl_tx_st_is_message_sent) begin
             prl_tx_st_message_if_ack        = 1'b1;
        end
        else if(prl_tx_st_is_discard_message) begin
             prl_tx_st_message_if_ack        = 1'b1;
             prl_tx_st_message_if_ack_result = 2'h3;
        end

end



//========================================================================================
//========================================================================================
//               PRL RX ST Control Signal Generate
//========================================================================================
//========================================================================================


//========================================================================================
//========================================================================================
//               PRL HD RST Signal Generate
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_hdrst_send_req <= 1'h0;
       end
       else if(prl_hdrst_st_is_request_hard_reset) begin
              prl_hdrst_send_req <= 1'h1;
       end
       else if(prl_hdrst_send_ack && !prl_hdrst_send_ack_result ) begin
              prl_hdrst_send_req <= 1'h0;
       end
       else if(prl_hdrst_send_ack && prl_hdrst_send_ack_result) begin
          if(prl_hdrst_st_is_wait_for_phy_hard_reset_complete) begin
              prl_hdrst_send_req <= 1'h1;
          end
	  else begin
              prl_hdrst_send_req <= 1'h0;
          end
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              pl2pe_hard_reset_req <= 1'h0;
       end
       else if(pe2pl_hard_reset_ack) begin
              pl2pe_hard_reset_req <= 1'h0;
       end
       else if(prl_hdrst_st_is_phy_hard_reset_request && prl_hdrst_st_hard_reset_from_pe) begin
              pl2pe_hard_reset_req <= 1'h1;
       end
       else if(prl_hdrst_st_is_indicate_hard_reset || prl_hdrst_st_hard_reset_rec_by_phy) begin
              pl2pe_hard_reset_req <= 1'h1;
       end
end


always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              pl2pe_cable_reset_req <= 1'h0;
       end
       else if(pe2pl_cable_reset_ack) begin
              pl2pe_cable_reset_req <= 1'h0;
       end
       else if(prl_hdrst_st_is_phy_hard_reset_request && prl_hdrst_st_cable_reset_from_pe) begin
              pl2pe_cable_reset_req <= 1'h1;
       end
       else if(prl_hdrst_st_is_indicate_hard_reset || prl_hdrst_st_cable_reset_rec_by_phy) begin
              pl2pe_cable_reset_req <= 1'h1;
       end
end

//========================================================================================
//========================================================================================
//               PRL Control PHY RX Chanel 
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl2phy_rx_packet_select <= 1'h0;
       end
       else if(prl_tx_st_is_src_sink_tx ) begin
              prl2phy_rx_packet_select <= 1'h1;
       end
       else if(prl_tx_st_is_src_source_tx ) begin
              prl2phy_rx_packet_select <= 1'h0;
       end
       else if(prl_rx_st_enter_send_goodcrc ) begin
              prl2phy_rx_packet_select <= 1'h0;
       end
       else if(prl_rx_st_exit_send_goodcrc ) begin
              prl2phy_rx_packet_select <= 1'h1;
       end
       else if(prl_tx_st_is_wait_for_phy_response && prl_tx_st_message_construct_ack && !prl_tx_st_message_construct_ack_result) begin
              prl2phy_rx_packet_select <= 1'h1;
       end
       else if(prl_tx_st_rec_crc_timeout || prl_tx_st_rec_goodcrc) begin
              prl2phy_rx_packet_select <= 1'h0;
       end
end


assign  prl_rx_st_enter_send_goodcrc = (prl_rx_cur_st != PRL_RX_SEND_GOODCRC) && (prl_rx_nxt_st == PRL_RX_SEND_GOODCRC);
assign  prl_rx_st_exit_send_goodcrc  = (prl_rx_cur_st == PRL_RX_SEND_GOODCRC) && (prl_rx_nxt_st != PRL_RX_SEND_GOODCRC);

//========================================================================================
//========================================================================================
//               PRL Time Scale 
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_time_scale_cnt_10us        <= 5'h0;
              prl_time_scale_cnt_100us       <= 4'h0;
              prl_time_scale_cnt_1ms         <= 4'h0;
       end
       else  begin
          if(prl_time_scale_cnt_10us == 5'd19) begin
              prl_time_scale_cnt_10us        <= 5'h0;
          end
	  else begin
              prl_time_scale_cnt_10us        <= prl_time_scale_cnt_10us + 1'h1;
          end

          if(prl_time_scale_10us) begin
              if(prl_time_scale_cnt_10us == 4'd9) begin
                  prl_time_scale_cnt_100us        <= 4'h0;
              end
	      else begin
                  prl_time_scale_cnt_100us        <= prl_time_scale_cnt_100us + 1'h1;
              end
          end

          if(prl_time_scale_100us) begin
              if(prl_time_scale_cnt_1ms == 4'd9) begin
                  prl_time_scale_cnt_1ms        <= 4'h0;
              end
	      else begin
                  prl_time_scale_cnt_1ms        <= prl_time_scale_cnt_1ms + 1'h1;
              end
          end

       end
end

assign    prl_time_scale_10us       = (prl_time_scale_cnt_10us == 5'd19);
assign    prl_time_scale_100us      = prl_time_scale_10us  && (prl_time_scale_cnt_100us == 4'd9);
assign    prl_time_scale_1ms        = prl_time_scale_100us && (prl_time_scale_cnt_1ms   == 4'd9);

//assign    prl_time_scale_100us      = prl_time_scale_10us;
//assign    prl_time_scale_1ms        = prl_time_scale_10us;





endmodule


