 `include "timescale.v"
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
module prl_tx_message_path(
    clk,
    rst_n,

    //prl&phy tx control if
    prl2phy_tx_packet_en,
    prl2phy_tx_packet_type,
    phy2prl_tx_packet_done,
    phy2prl_tx_packet_result,

    //prl&phy tx data if
    prl2phy_tx_payload_en,
    prl2phy_tx_payload,
    prl2phy_tx_payload_last,
    phy2prl_tx_payload_done,

    //prl tx if message decode 
    prl_tx_if_sop_type,
    prl_tx_if_message_type,
    prl_tx_if_header_type,


    prl_tx_if_source_cap_table_select,
    prl_tx_if_source_cap_current,


    prl_tx_if_ex_message_data_size,

    prl_tx_if_ex_pps_status_flag_omf,
    prl_tx_if_ex_pps_status_flag_ptp,
    prl_tx_if_ex_pps_status_output_current,
    prl_tx_if_ex_pps_status_output_voltage,

    //prl tx st signal
    prl_tx_st_message_construct_reset,
    prl_tx_st_message_construct_req,
    prl_tx_st_messageid_counter,
    prl_tx_st_message_construct_ack,
    prl_tx_st_message_construct_ack_result,

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

//prl&phy tx control if
output             prl2phy_tx_packet_en;
output   [ 2:0]    prl2phy_tx_packet_type;
input              phy2prl_tx_packet_done;
input              phy2prl_tx_packet_result;

output             prl2phy_tx_payload_en;
output   [ 7:0]    prl2phy_tx_payload;
output             prl2phy_tx_payload_last;
input              phy2prl_tx_payload_done;

//prl tx if message decode 
input    [ 2:0]    prl_tx_if_sop_type;
input    [ 1:0]    prl_tx_if_message_type;
input    [ 4:0]    prl_tx_if_header_type;

input    [ 3:0]    prl_tx_if_source_cap_table_select;
input              prl_tx_if_source_cap_current;

input    [ 8:0]    prl_tx_if_ex_message_data_size;

input              prl_tx_if_ex_pps_status_flag_omf;
input              prl_tx_if_ex_pps_status_flag_ptp;
input    [ 7:0]    prl_tx_if_ex_pps_status_output_current;
input    [15:0]    prl_tx_if_ex_pps_status_output_voltage;

//prl tx st signal
input              prl_tx_st_message_construct_reset;
input              prl_tx_st_message_construct_req;
input    [ 2:0]    prl_tx_st_messageid_counter;
output             prl_tx_st_message_construct_ack;
output             prl_tx_st_message_construct_ack_result;


//prl rx construct signal
input              prl_rx_st_send_goodcrc_req;
input    [ 1:0]    prl_rx_st_send_goodcrc_sop_type;
input    [ 2:0]    prl_rx_st_send_goodcrc_messageid;
output             prl_rx_st_send_goodcrc_ack;
output             prl_rx_st_send_goodcrc_ack_result;


//prl hdrst construct signal
input              prl_hdrst_send_req;
output             prl_hdrst_send_ack;
output             prl_hdrst_send_ack_result;



localparam PRL_TX_CONSTRUCT_IDLE                   = 3'h0;
localparam PRL_TX_CONSTRUCT_MESSAGE_HEADER         = 3'h2;
localparam PRL_TX_CONSTRUCT_MESSAGE_EXTENDED       = 3'h3;
localparam PRL_TX_CONSTRUCT_MESSAGE_DATA           = 3'h4;
localparam PRL_TX_CONSTRUCT_ERROR                  = 3'h5;
localparam PRL_TX_CONSTRUCT_DONE                   = 3'h6;

reg                prl2phy_tx_packet_en;
reg      [ 2:0]    prl2phy_tx_packet_type;
reg                prl2phy_tx_payload_en;

reg                prl_tx_st_message_construct_ack;
reg                prl_tx_st_message_construct_ack_result;
reg                prl_rx_st_send_goodcrc_ack;
reg                prl_rx_st_send_goodcrc_ack_result;
reg                prl_hdrst_send_ack;
reg                prl_hdrst_send_ack_result;

reg                [7:0] prl2phy_tx_payload;
reg                prl2phy_tx_payload_last;
wire               phy2prl_tx_payload_done;

reg                [4:0] prl_tx_construct_payload_cnt;
reg                [4:0] prl_tx_construct_payload_size;
wire               prl_tx_construct_payload_cnt_done;

reg                [2:0] prl_tx_construct_data_size;

reg                [2:0] prl_tx_construct_cur_st;
reg                [2:0] prl_tx_construct_nxt_st;
wire               prl_tx_construct_st_change;

wire               prl_tx_construct_st_is_idle;
wire               prl_tx_construct_st_is_control_message;
wire               prl_tx_construct_st_is_data_message;
wire               prl_tx_construct_st_is_extended_message;
wire               prl_tx_construct_st_is_error;
wire               prl_tx_construct_st_is_done;

wire               [1:0] prl_tx_if_message_type;
wire               [4:0] prl_tx_if_header_type;

wire               prl_tx_construct_message_extended_done;
wire               prl_tx_construct_message_data_done;
wire               prl_tx_construct_message_header_done;

//Capabilities Message 
reg                [31:0] prl_tx_construct_source_cap_data0;
reg                [31:0] prl_tx_construct_source_cap_data1;
reg                [31:0] prl_tx_construct_source_cap_data2;
reg                [31:0] prl_tx_construct_source_cap_data3;
reg                [31:0] prl_tx_construct_source_cap_data4;
reg                [31:0] prl_tx_construct_source_cap_data5;


//========================================================================================
//========================================================================================
//               PRL Message Construct State Machine
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_construct_cur_st <= PRL_TX_CONSTRUCT_IDLE;
       end
       else if(prl_tx_st_message_construct_reset) begin
              prl_tx_construct_cur_st <= PRL_TX_CONSTRUCT_IDLE;
       end
       else if(phy2prl_tx_packet_done && phy2prl_tx_packet_result) begin
              prl_tx_construct_cur_st <= PRL_TX_CONSTRUCT_ERROR;
       end
       else begin
              prl_tx_construct_cur_st <= prl_tx_construct_nxt_st;
       end
end

assign prl_tx_construct_st_change = (prl_tx_construct_nxt_st != prl_tx_construct_cur_st);
assign prl_tx_construct_st_is_idle             = (prl_tx_construct_cur_st == PRL_TX_CONSTRUCT_IDLE);
assign prl_tx_construct_st_is_control_message  = (prl_tx_construct_cur_st == PRL_TX_CONSTRUCT_MESSAGE_HEADER);
assign prl_tx_construct_st_is_data_message     = (prl_tx_construct_cur_st == PRL_TX_CONSTRUCT_MESSAGE_DATA);
assign prl_tx_construct_st_is_extended_message = (prl_tx_construct_cur_st == PRL_TX_CONSTRUCT_MESSAGE_EXTENDED);
assign prl_tx_construct_st_is_error            = (prl_tx_construct_cur_st == PRL_TX_CONSTRUCT_ERROR);
assign prl_tx_construct_st_is_done             = (prl_tx_construct_cur_st == PRL_TX_CONSTRUCT_DONE);

always @(*) begin
        prl_tx_construct_nxt_st = prl_tx_construct_cur_st;

        case(prl_tx_construct_cur_st)
          PRL_TX_CONSTRUCT_IDLE: begin
            if(prl_tx_st_message_construct_req || prl_rx_st_send_goodcrc_req) begin
               prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_MESSAGE_HEADER;
            end
            //else if(prl_hdrst_send_req ) begin
            //   prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_DONE;
            //end
          end
          PRL_TX_CONSTRUCT_MESSAGE_HEADER: begin
            if(prl_tx_construct_message_header_done) begin
               if(prl_tx_if_message_type == 2'h0) begin  //control message
                  prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_DONE;
               end
               else if(prl_tx_if_message_type == 2'h1) begin  //data message
                  prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_MESSAGE_DATA;
               end
               else if(prl_tx_if_message_type == 2'h2) begin  //extended message
                  prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_MESSAGE_EXTENDED;
               end
            end
          end
          PRL_TX_CONSTRUCT_MESSAGE_EXTENDED: begin
            if(prl_tx_construct_message_extended_done) begin
               prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_MESSAGE_DATA;
            end
          end
          PRL_TX_CONSTRUCT_MESSAGE_DATA: begin
            if(prl_tx_construct_message_data_done) begin
               prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_DONE;
            end
          end
          PRL_TX_CONSTRUCT_ERROR: begin
               prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_IDLE;
          end
          PRL_TX_CONSTRUCT_DONE: begin
            if(phy2prl_tx_packet_done) begin
               prl_tx_construct_nxt_st = PRL_TX_CONSTRUCT_IDLE;
            end
          end
	  default;
        endcase
end

//tx construct control signal genereate
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_tx_construct_payload_cnt <= 5'h0;
       end
       else if(prl_tx_st_message_construct_reset) begin
              prl_tx_construct_payload_cnt <= 5'h0;
       end
       else if(prl_tx_construct_st_change) begin
              prl_tx_construct_payload_cnt <= 5'h0;
       end
       else if(phy2prl_tx_payload_done) begin
              prl_tx_construct_payload_cnt <= prl_tx_construct_payload_cnt + 1'h1;
       end
end

assign prl_tx_construct_payload_cnt_done = (prl_tx_construct_payload_cnt == prl_tx_construct_payload_size);

always @(*) begin
        prl_tx_construct_payload_size = 5'h2;

       if(prl_tx_construct_st_is_data_message) begin
          if((prl_tx_if_header_type == 5'b0_0001) && (prl_tx_if_message_type == 2'h1)) begin   //source capbility
             case(prl_tx_if_source_cap_table_select)
                4'h0: begin
                   prl_tx_construct_payload_size = 5'd8;
                end
                4'h3: begin
                   prl_tx_construct_payload_size = 5'd12;
                end
                4'h5,4'h7: begin
                   prl_tx_construct_payload_size = 5'd20;
                end
                4'h6,4'h8: begin
                   prl_tx_construct_payload_size = 5'd24;
                end
                default: begin
                   prl_tx_construct_payload_size = 5'd16;
                end
             endcase
          end
          else if((prl_tx_if_header_type == 5'b0_0010) && (prl_tx_if_message_type == 2'h2)) begin   //status message 
                   prl_tx_construct_payload_size = 5'd5;
          end
          else begin
             prl_tx_construct_payload_size = 5'd4;
          end
       end
end


assign prl_tx_construct_message_header_done   = (prl_tx_construct_payload_cnt_done && prl_tx_construct_st_is_control_message);
assign prl_tx_construct_message_data_done     = (prl_tx_construct_payload_cnt_done && prl_tx_construct_st_is_data_message);
assign prl_tx_construct_message_extended_done = (prl_tx_construct_payload_cnt_done && prl_tx_construct_st_is_extended_message);


always @(*) begin
        prl_tx_construct_data_size = 3'h0;

       if(prl_tx_if_message_type == 2'h1) begin
          if(prl_tx_if_header_type == 5'b0_0001) begin   //source capbility
             case(prl_tx_if_source_cap_table_select)
                4'h0: begin
                   prl_tx_construct_data_size = 3'd2;
                end
                4'h3: begin
                   prl_tx_construct_data_size = 3'd3;
                end
                4'h5,4'h7: begin
                   prl_tx_construct_data_size = 3'd5;
                end
                4'h6,4'h8: begin
                   prl_tx_construct_data_size = 3'd6;
                end
                default: begin
                   prl_tx_construct_data_size = 3'd4;
                end
             endcase
          end
          else begin
             prl_tx_construct_data_size = 3'd1;
          end
       end
end

//========================================================================================
//========================================================================================
//               PRL Construct Message & ST IF
//========================================================================================
//========================================================================================
always @(*) begin

              prl_tx_st_message_construct_ack          = 1'h0;
              prl_tx_st_message_construct_ack_result   = 1'h0;

       if(prl_tx_st_message_construct_req) begin
           //if(!prl_tx_construct_st_is_idle) begin
           //       prl_tx_st_message_construct_ack          = 1'h1;
           //       prl_tx_st_message_construct_ack_result   = 1'h1;
           //end
           if(prl_tx_construct_st_is_error) begin
                  prl_tx_st_message_construct_ack          = 1'h1;
                  prl_tx_st_message_construct_ack_result   = 1'h1;
           end
           else if(prl_tx_construct_st_is_done && phy2prl_tx_packet_done) begin
                  prl_tx_st_message_construct_ack          = 1'h1;
           end
       end
end


always @(*) begin

              prl_rx_st_send_goodcrc_ack          = 1'h0;
              prl_rx_st_send_goodcrc_ack_result   = 1'h0;

       if(prl_rx_st_send_goodcrc_req) begin
           //if(!prl_tx_construct_st_is_idle) begin
           //       prl_rx_st_send_goodcrc_ack          = 1'h1;
           //       prl_rx_st_send_goodcrc_ack_result   = 1'h1;
           //end
           if(prl_tx_construct_st_is_error) begin
                  prl_rx_st_send_goodcrc_ack          = 1'h1;
                  prl_rx_st_send_goodcrc_ack_result   = 1'h1;
           end
           else if(prl_tx_construct_st_is_done && phy2prl_tx_packet_done) begin
                  prl_rx_st_send_goodcrc_ack          = 1'h1;
           end
       end
end


always @(*) begin

              prl_hdrst_send_ack                  = 1'h0;
              prl_hdrst_send_ack_result           = 1'h0;

       if(prl_hdrst_send_req) begin
           //if(!prl_tx_construct_st_is_idle) begin
           //       prl_hdrst_send_ack                  = 1'h1;
           //       prl_hdrst_send_ack_result           = 1'h1;
           //end
           if(phy2prl_tx_packet_done) begin
                  prl_hdrst_send_ack                  = 1'h1;
                  prl_hdrst_send_ack_result           = phy2prl_tx_packet_result;
           end
       end
end



//========================================================================================
//========================================================================================
//               PRL Construct Message & PHY IF
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl2phy_tx_packet_en    <= 1'h0;
              prl2phy_tx_packet_type  <= 3'h0;
       end
       else if(prl_tx_st_message_construct_reset) begin
              prl2phy_tx_packet_en    <= 1'h0;
              prl2phy_tx_packet_type  <= 3'h0;
       end
       else if(phy2prl_tx_packet_done) begin
              prl2phy_tx_packet_en    <= 1'h0;
              prl2phy_tx_packet_type  <= 3'h0;
       end
       else if(prl_hdrst_send_req ) begin
              prl2phy_tx_packet_en    <= 1'h1;
              prl2phy_tx_packet_type  <= prl_tx_if_sop_type;
       end
       else if(prl_tx_construct_st_is_control_message ) begin
           //if(prl_hdrst_send_req || prl_tx_st_message_construct_req || prl_rx_st_send_goodcrc_req) begin
              prl2phy_tx_packet_en    <= 1'h1;
              prl2phy_tx_packet_type  <= prl_tx_if_sop_type;
           //end
       end
end


//========================================================================================
//========================================================================================
//               PRL Construct Message 
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl2phy_tx_payload_en   <= 1'h0;
              prl2phy_tx_payload      <= 8'h0;
              prl2phy_tx_payload_last <= 1'h0;
       end
       else if(prl_tx_st_message_construct_reset) begin
              prl2phy_tx_payload_en   <= 1'h0;
              prl2phy_tx_payload      <= 8'h0;
              prl2phy_tx_payload_last <= 1'h0;
       end
       else if(phy2prl_tx_payload_done) begin
              prl2phy_tx_payload_en   <= 1'h0;
              prl2phy_tx_payload      <= 8'h0;
              prl2phy_tx_payload_last <= 1'h0;
       end
       else if(prl_tx_construct_st_is_control_message && !prl_tx_construct_payload_cnt_done ) begin  //Control Message Header
           if(prl_tx_st_message_construct_req) begin
                if(prl_tx_construct_payload_cnt == 5'd0) begin
                    prl2phy_tx_payload_en        <= 1'h1;
                    prl2phy_tx_payload[4:0]      <= prl_tx_if_header_type;
                    prl2phy_tx_payload[5]        <= (prl_tx_if_sop_type == 3'h0)? 1'b1 : 1'b0;       //DFP
                    prl2phy_tx_payload[7:6]      <= 2'b10;
                end
	        else begin
                    prl2phy_tx_payload_en        <= 1'h1;
                    prl2phy_tx_payload[0]        <= (prl_tx_if_sop_type == 3'h0)? 1'b1 : 1'b0;       //Source 
                    prl2phy_tx_payload[3:1]      <= prl_tx_st_messageid_counter;
                    prl2phy_tx_payload[6:4]      <= prl_tx_construct_data_size;
                    prl2phy_tx_payload[7]        <= (prl_tx_if_message_type == 2'h2)? 1'b1 : 1'b0;       //extended message 
                    prl2phy_tx_payload_last      <= (prl_tx_if_message_type == 2'h0) ? 1'h1 : 1'b0;
                end
           end
	   else begin
                if(prl_tx_construct_payload_cnt == 5'd0) begin
                    prl2phy_tx_payload_en        <= 1'h1;
                    prl2phy_tx_payload[4:0]      <= 5'b0_0001;
                    prl2phy_tx_payload[5]        <= (prl_rx_st_send_goodcrc_sop_type == 2'h0)? 1'b1 : 1'b0;       //DFP
                    prl2phy_tx_payload[7:6]      <= 2'b10;
                end
	        else begin
                    prl2phy_tx_payload_en        <= 1'h1;
                    prl2phy_tx_payload[0]        <= (prl_rx_st_send_goodcrc_sop_type == 2'h0)? 1'b1 : 1'b0;       //Source 
                    prl2phy_tx_payload[3:1]      <= prl_rx_st_send_goodcrc_messageid;
                    prl2phy_tx_payload[6:4]      <= 3'h0;
                    prl2phy_tx_payload[7]        <= 1'b0;
                    prl2phy_tx_payload_last      <= 1'h1;
                end
           end


       end
       else if(prl_tx_construct_st_is_extended_message && !prl_tx_construct_payload_cnt_done ) begin  //Extended Message Header
          if(prl_tx_construct_payload_cnt == 5'd0) begin
              prl2phy_tx_payload_en        <= 1'h1;
              prl2phy_tx_payload[7:0]      <= prl_tx_if_ex_message_data_size[7:0];
          end
	  else begin
              prl2phy_tx_payload_en        <= 1'h1;
              prl2phy_tx_payload[0]        <= prl_tx_if_ex_message_data_size[8];
              prl2phy_tx_payload[7:1]      <= 7'h0;
          end
       end
       else if(prl_tx_construct_st_is_data_message && !prl_tx_construct_payload_cnt_done ) begin  //Data Message Header
           if(prl_tx_if_message_type == 2'h1) begin  //data message
               if(prl_tx_if_header_type == 5'b0_0001) begin  //source cap
                        prl2phy_tx_payload_en        <= 1'h1;

                        if((prl_tx_construct_payload_cnt + 1'b1) == prl_tx_construct_payload_size) begin  //source cap
                                prl2phy_tx_payload_last        <= 1'h1;
                        end


                        case(prl_tx_construct_payload_cnt) 
	                             5'd0 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data0[7:0];
	                             5'd1 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data0[15:8];
	                             5'd2 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data0[23:16];
	                             5'd3 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data0[31:24];
	                             5'd4 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data1[7:0];
	                             5'd5 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data1[15:8];
	                             5'd6 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data1[23:16];
	                             5'd7 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data1[31:24];
	                             5'd8 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data2[7:0];
	                             5'd9 : prl2phy_tx_payload           <= prl_tx_construct_source_cap_data2[15:8];
	                             5'd10: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data2[23:16];
	                             5'd11: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data2[31:24];
	                             5'd12: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data3[7:0];
	                             5'd13: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data3[15:8];
	                             5'd14: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data3[23:16];
	                             5'd15: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data3[31:24];
	                             5'd16: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data4[7:0];
	                             5'd17: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data4[15:8];
	                             5'd18: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data4[23:16];
	                             5'd19: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data4[31:24];
	                             5'd20: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data5[7:0];
	                             5'd21: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data5[15:8];
	                             5'd22: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data5[23:16];
	                             5'd23: prl2phy_tx_payload           <= prl_tx_construct_source_cap_data5[31:24];
                                     default;
	                endcase
               end
               else if(prl_tx_if_header_type == 5'b0_0010) begin //request
                        if(prl_tx_construct_payload_cnt == 5'd3) begin 
                                 prl2phy_tx_payload_en        <= 1'h1;
                                 prl2phy_tx_payload           <= 8'h30;
                                 prl2phy_tx_payload_last      <= 1'h1;
                        end
			else begin
                                 prl2phy_tx_payload_en        <= 1'h1;
                                 prl2phy_tx_payload           <= 8'h50;
                        end
               end
               else if(prl_tx_if_header_type == 5'b0_0011) begin //bist
                        if(prl_tx_construct_payload_cnt == 5'd3) begin 
                                 prl2phy_tx_payload_en        <= 1'h1;
                                 prl2phy_tx_payload           <= {4'b1000, 4'h0};
                                 prl2phy_tx_payload_last      <= 1'h1;
                        end
			else begin
                                 prl2phy_tx_payload_en        <= 1'h1;
                                 prl2phy_tx_payload           <= 8'h0;
                        end
               end
           end
	   else begin //extended message
               if(prl_tx_if_header_type == 5'b0_1100) begin  //pps status
                        prl2phy_tx_payload_en        <= 1'h1;

                        case(prl_tx_construct_payload_cnt) 
	                             5'd0 : prl2phy_tx_payload           <= {4'h0, prl_tx_if_ex_pps_status_flag_omf, prl_tx_if_ex_pps_status_flag_ptp, 1'b0};
	                             5'd1 : prl2phy_tx_payload           <= prl_tx_if_ex_pps_status_output_current;
	                             5'd2 : prl2phy_tx_payload           <= prl_tx_if_ex_pps_status_output_voltage[7:0];
	                             5'd3 : prl2phy_tx_payload           <= prl_tx_if_ex_pps_status_output_voltage[15:8];
                                     default;
	                endcase

                        prl2phy_tx_payload_last      <= (prl_tx_construct_payload_cnt == 5'd3);
               end
           end
       end
end


//========================================================================================
//========================================================================================
//               PRL Construct Source Cap Message 
//========================================================================================
//========================================================================================

always @(*) begin
        prl_tx_construct_source_cap_data0[31:30] = 2'd0;
        prl_tx_construct_source_cap_data0[29:20] = 10'd0;
        prl_tx_construct_source_cap_data0[19:10] = 10'd100;  //5V
        prl_tx_construct_source_cap_data0[9:0]   = 10'd300;  //3A

       if(prl_tx_if_source_cap_current && (prl_tx_if_source_cap_table_select > 4'd13)) begin  
            prl_tx_construct_source_cap_data0[9:0]   = 10'd500;
       end


end


always @(*) begin
        prl_tx_construct_source_cap_data1[31:30] = 2'd0;
        prl_tx_construct_source_cap_data1[29:20] = 10'd0;
        prl_tx_construct_source_cap_data1[19:10] = 10'd180;  //9V
        prl_tx_construct_source_cap_data1[9:0]   = 10'd300;  //3A

       case(prl_tx_if_source_cap_table_select) 
          4'h0: begin
               prl_tx_construct_source_cap_data1[31:30] = 2'd3;
               prl_tx_construct_source_cap_data1[29:17] = 13'd59;   //5.9V
               prl_tx_construct_source_cap_data1[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data1[7:0]   = 8'd60;    //3A
          end
          4'h1: begin
              prl_tx_construct_source_cap_data1[31:30] = 2'd0;
              prl_tx_construct_source_cap_data1[29:20] = 10'd100;
              prl_tx_construct_source_cap_data1[19:10] = 10'd180;  //9V
              prl_tx_construct_source_cap_data1[9:0]   = 10'd200;  //2A
          end
          4'h9, 4'ha, 4'hd: begin
              prl_tx_construct_source_cap_data1[31:30] = 2'd0;
              prl_tx_construct_source_cap_data1[29:20] = 10'd100;
              prl_tx_construct_source_cap_data1[19:10] = 10'd120;  //6V
              prl_tx_construct_source_cap_data1[9:0]   = 10'd300;  //3A
          end
          4'he: begin
              prl_tx_construct_source_cap_data1[31:30] = 2'd0;
              prl_tx_construct_source_cap_data1[29:20] = 10'd100;
              prl_tx_construct_source_cap_data1[19:10] = 10'd120;  //6V
              prl_tx_construct_source_cap_data1[9:0]   = (prl_tx_if_source_cap_current) ? 10'd450 : 10'd300;  //4.5A
          end
          4'hf: begin
              prl_tx_construct_source_cap_data1[31:30] = 2'd0;
              prl_tx_construct_source_cap_data1[29:20] = 10'd100;
              prl_tx_construct_source_cap_data1[19:10] = 10'd180;  //9V
              prl_tx_construct_source_cap_data1[9:0]   = (prl_tx_if_source_cap_current) ? 10'd400 : 10'd300;  //4A
          end
          default;
       endcase

end


always @(*) begin
        prl_tx_construct_source_cap_data2[31:30] = 2'd0;
        prl_tx_construct_source_cap_data2[29:20] = 10'd0;
        prl_tx_construct_source_cap_data2[19:10] = 10'd140;  //7V
        prl_tx_construct_source_cap_data2[9:0]   = 10'd300;  //3A

       case(prl_tx_if_source_cap_table_select) 
          4'h1: begin
               prl_tx_construct_source_cap_data2[31:30] = 2'd3;
               prl_tx_construct_source_cap_data2[29:17] = 13'd59;   //5.9V
               prl_tx_construct_source_cap_data2[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data2[7:0]   = 8'd60;    //3A
          end
          4'h2: begin
               prl_tx_construct_source_cap_data2[31:30] = 2'd3;
               prl_tx_construct_source_cap_data2[29:17] = 13'd59;   //5.9V
               prl_tx_construct_source_cap_data2[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data2[7:0]   = (prl_tx_if_source_cap_current) ? 8'd72 : 8'd60;    //3.6A
          end
          4'h3: begin
               prl_tx_construct_source_cap_data2[31:30] = 2'd3;
               prl_tx_construct_source_cap_data2[29:17] = 13'd110;  //11V
               prl_tx_construct_source_cap_data2[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data2[7:0]   = 8'd60;    //3A
          end
          4'h4: begin
               prl_tx_construct_source_cap_data2[31:30] = 2'd3;
               prl_tx_construct_source_cap_data2[29:17] = 13'd110;  //11V
               prl_tx_construct_source_cap_data2[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data2[7:0]   = (prl_tx_if_source_cap_current) ? 8'd100 : 8'd60;   //5A
          end
          4'h5, 4'h6: begin
              prl_tx_construct_source_cap_data2[31:30] = 2'd0;
              prl_tx_construct_source_cap_data2[29:20] = 10'd100;
              prl_tx_construct_source_cap_data2[19:10] = 10'd300;  //15V
              prl_tx_construct_source_cap_data2[9:0]   = 10'd240;  //2.4A
          end
          4'h7, 4'h8: begin
              prl_tx_construct_source_cap_data2[31:30] = 2'd0;
              prl_tx_construct_source_cap_data2[29:20] = 10'd100;
              prl_tx_construct_source_cap_data2[19:10] = 10'd300;  //15V
              prl_tx_construct_source_cap_data2[9:0]   = 10'd300;  //3A
          end
          4'h9: begin
              prl_tx_construct_source_cap_data2[31:30] = 2'd0;
              prl_tx_construct_source_cap_data2[29:20] = 10'd100;
              prl_tx_construct_source_cap_data2[19:10] = 10'd140;  //7V
              prl_tx_construct_source_cap_data2[9:0]   = 10'd257;  //2.57A
          end
          4'hb, 4'hc, 4'hf: begin
              prl_tx_construct_source_cap_data2[31:30] = 2'd0;
              prl_tx_construct_source_cap_data2[29:20] = 10'd100;
              prl_tx_construct_source_cap_data2[19:10] = 10'd240;  //12V
              prl_tx_construct_source_cap_data2[9:0]   = 10'd300;  //3A
          end
          4'he: begin
              prl_tx_construct_source_cap_data2[31:30] = 2'd0;
              prl_tx_construct_source_cap_data2[29:20] = 10'd100;
              prl_tx_construct_source_cap_data2[19:10] = 10'd140;  //7V
              prl_tx_construct_source_cap_data2[9:0]   = (prl_tx_if_source_cap_current) ? 10'd386 : 10'd300;  //3.86A
          end
          default;
       endcase



end


always @(*) begin
        prl_tx_construct_source_cap_data3[31:30] = 2'd0;
        prl_tx_construct_source_cap_data3[29:20] = 10'd0;
        prl_tx_construct_source_cap_data3[19:10] = 10'd180;  //9V
        prl_tx_construct_source_cap_data3[9:0]   = 10'd300;  //3A

       case(prl_tx_if_source_cap_table_select) 
          4'h1, 4'h2: begin
               prl_tx_construct_source_cap_data3[31:30] = 2'd3;
               prl_tx_construct_source_cap_data3[29:17] = 13'd110;  //11V
               prl_tx_construct_source_cap_data3[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data3[7:0]   = 8'd40;    //2A
          end
          4'h4, 4'h5, 4'h7: begin
               prl_tx_construct_source_cap_data3[31:30] = 2'd3;
               prl_tx_construct_source_cap_data3[29:17] = 13'd110;  //11V
               prl_tx_construct_source_cap_data3[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data3[7:0]   = 8'd60;    //2A
          end
          4'h6, 4'h8: begin
               prl_tx_construct_source_cap_data3[31:30] = 2'd3;
               prl_tx_construct_source_cap_data3[29:17] = 13'd59;   //11V
               prl_tx_construct_source_cap_data3[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data3[7:0]   = (prl_tx_if_source_cap_current) ? 8'd100 : 8'd60;   //5A
          end
          4'h9: begin
               prl_tx_construct_source_cap_data3[31:30] = 2'd0;
               prl_tx_construct_source_cap_data3[29:20] = 10'd100;
               prl_tx_construct_source_cap_data3[19:10] = 10'd180;  //9V
               prl_tx_construct_source_cap_data3[9:0]   = 10'd200;  //2A
          end
          4'hb, 4'hf: begin
               prl_tx_construct_source_cap_data3[31:30] = 2'd0;
               prl_tx_construct_source_cap_data3[29:20] = 10'd100;
               prl_tx_construct_source_cap_data3[19:10] = 10'd300;  //15V
               prl_tx_construct_source_cap_data3[9:0]   = 10'd240;  //2.4A
          end
          4'hb: begin
               prl_tx_construct_source_cap_data3[31:30] = 2'd0;
               prl_tx_construct_source_cap_data3[29:20] = 10'd100;
               prl_tx_construct_source_cap_data3[19:10] = 10'd300;  //15V
               prl_tx_construct_source_cap_data3[9:0]   = 10'd300;  //3A
          end
          4'hd: begin
               prl_tx_construct_source_cap_data3[31:30] = 2'd0;
               prl_tx_construct_source_cap_data3[29:20] = 10'd100;
               prl_tx_construct_source_cap_data3[19:10] = 10'd180;  //9V
               prl_tx_construct_source_cap_data3[9:0]   = 10'd278;  //2.78A
          end
          default;
       endcase

end


always @(*) begin
        prl_tx_construct_source_cap_data4[31:30] = 2'd3;
        prl_tx_construct_source_cap_data4[29:17] = 13'd160;  //16V
        prl_tx_construct_source_cap_data4[16:8]  = 9'd30;    //3V
        prl_tx_construct_source_cap_data4[7:0]   = 8'd48;    //2.4A

       case(prl_tx_if_source_cap_table_select) 
          4'h6: begin
               prl_tx_construct_source_cap_data4[31:30] = 2'd3;
               prl_tx_construct_source_cap_data4[29:17] = 13'd110;  //11V
               prl_tx_construct_source_cap_data4[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data4[7:0]   = (prl_tx_if_source_cap_current) ? 8'd80 : 8'd60;    //4A
          end
          4'h7: begin
               prl_tx_construct_source_cap_data4[31:30] = 2'd3;
               prl_tx_construct_source_cap_data4[29:17] = 13'd160;  //16V
               prl_tx_construct_source_cap_data4[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data4[7:0]   = 8'd60;    //3A
          end
          4'h8: begin
               prl_tx_construct_source_cap_data4[31:30] = 2'd3;
               prl_tx_construct_source_cap_data4[29:17] = 13'd110;  //11V
               prl_tx_construct_source_cap_data4[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data4[7:0]   = (prl_tx_if_source_cap_current) ? 8'd100 : 8'd60;    //5A
          end
          default;
       endcase

end

always @(*) begin
        prl_tx_construct_source_cap_data5[31:30] = 2'd3;
        prl_tx_construct_source_cap_data5[29:17] = 13'd160;  //16V
        prl_tx_construct_source_cap_data5[16:8]  = 9'd30;    //3V
        prl_tx_construct_source_cap_data5[7:0]   = 8'd48;    //2.4A

       case(prl_tx_if_source_cap_table_select) 
          4'h8: begin
               prl_tx_construct_source_cap_data5[31:30] = 2'd3;
               prl_tx_construct_source_cap_data5[29:17] = 13'd160;  //16V
               prl_tx_construct_source_cap_data5[16:8]  = 9'd30;    //3V
               prl_tx_construct_source_cap_data5[7:0]   = 8'd60;    //3A
          end
          default;
       endcase
end



endmodule

