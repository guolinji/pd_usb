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
module prl_rx_message_path(
    clk,
    rst_n,

    phy2prl_rx_packet_en,
    phy2prl_rx_packet_type,
    phy2prl_rx_packet_done,
    phy2prl_rx_packet_result,

    phy2prl_rx_payload,
    phy2prl_rx_payload_req,

    prl_tx_if_source_cap_table_select,

    prl_rx_parser_message_req,
    //prl_rx_parser_message_result,
    prl_rx_parser_message_type,
    prl_rx_parser_sop_type,
    prl_rx_parser_header_type,
    prl_rx_parser_message_id,

    prl_rx_parser_message_ex_data_size,
    
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


input              phy2prl_rx_packet_en;
input    [ 2:0]    phy2prl_rx_packet_type;
input              phy2prl_rx_packet_done;
input    [ 1:0]    phy2prl_rx_packet_result;

input    [ 7:0]    phy2prl_rx_payload;
input              phy2prl_rx_payload_req;

input    [ 3:0]    prl_tx_if_source_cap_table_select;

output             prl_rx_parser_message_req;
//output   [ 2:0]    prl_rx_parser_message_result;
output   [ 1:0]    prl_rx_parser_message_type;
output   [ 2:0]    prl_rx_parser_sop_type;
output   [ 4:0]    prl_rx_parser_header_type;
output   [ 2:0]    prl_rx_parser_message_id;
output   [ 8:0]    prl_rx_parser_message_ex_data_size;

output             prl_rx_parser_data_request_pdo_type;
output   [10:0]    prl_rx_parser_data_request_op_cur;
output   [ 9:0]    prl_rx_parser_data_request_max_op_cur;
output   [ 7:0]    prl_rx_parser_data_src_cap_max_vol;
output   [ 9:0]    prl_rx_parser_data_src_cap_voltage;
output   [ 9:0]    prl_rx_parser_data_src_cap_max_cur;

localparam PRL_RX_PARSER_IDLE                      = 3'h0;
localparam PRL_RX_PARSER_MESSAGE_HEADER            = 3'h1;
localparam PRL_RX_PARSER_MESSAGE_EXTENDED          = 3'h2;
localparam PRL_RX_PARSER_MESSAGE_DATA              = 3'h3;
localparam PRL_RX_PARSER_INFORM_MESSAGE            = 3'h4;

reg      [ 1:0]    prl_rx_parser_message_type;
reg      [ 4:0]    prl_rx_parser_header_type;
reg      [ 2:0]    prl_rx_parser_message_id;
reg      [ 8:0]    prl_rx_parser_message_ex_data_size;

reg                prl_rx_parser_data_request_pdo_type;
reg      [ 7:0]    prl_rx_parser_data_src_cap_max_vol;
reg      [ 9:0]    prl_rx_parser_data_src_cap_voltage;
reg      [ 9:0]    prl_rx_parser_data_src_cap_max_cur;
//state machine
reg      [ 2:0]    prl_rx_parser_cur_st;
reg      [ 2:0]    prl_rx_parser_nxt_st;

wire               prl_rx_parser_st_is_idle                     ; 
wire               prl_rx_parser_st_is_message_header           ; 
wire               prl_rx_parser_st_is_message_extended         ; 
wire               prl_rx_parser_st_is_message_data             ; 
wire               prl_rx_parser_st_is_inform_message           ; 

wire               prl_rx_parser_receive_req;
reg      [ 2:0]    prl_rx_parser_receive_data_cnt;
reg      [31:0]    prl_rx_parser_receive_data;
wire     [ 1:0]    prl_rx_parser_receive_message_type;
wire               prl_rx_parser_receive_is_sop_type;

wire               prl_rx_parser_receive_header_done;
wire               prl_rx_parser_receive_header_ex_done;
wire               prl_rx_parser_receive_data_done;
wire               prl_rx_parser_receive_stage_done;

wire               prl_rx_parser_receive_packet_done;


reg                prl_rx_parser_message_req;
//reg      [ 2:0]    prl_rx_parser_message_result;
//========================================================================================
//========================================================================================
//               PRL Message Construct State Machine
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_parser_cur_st <= PRL_RX_PARSER_IDLE;
       end
       else if(prl_rx_parser_receive_packet_done && !prl_rx_parser_st_is_inform_message) begin
              prl_rx_parser_cur_st <= PRL_RX_PARSER_IDLE;
       end
       else begin
              prl_rx_parser_cur_st <= prl_rx_parser_nxt_st;
       end
end

assign   prl_rx_parser_st_is_idle                      = (prl_rx_parser_cur_st == PRL_RX_PARSER_IDLE                );
assign   prl_rx_parser_st_is_message_header            = (prl_rx_parser_cur_st == PRL_RX_PARSER_MESSAGE_HEADER      );
assign   prl_rx_parser_st_is_message_extended          = (prl_rx_parser_cur_st == PRL_RX_PARSER_MESSAGE_EXTENDED    );
assign   prl_rx_parser_st_is_message_data              = (prl_rx_parser_cur_st == PRL_RX_PARSER_MESSAGE_DATA        );
assign   prl_rx_parser_st_is_inform_message            = (prl_rx_parser_cur_st == PRL_RX_PARSER_INFORM_MESSAGE      );


always @(*) begin
        prl_rx_parser_nxt_st = prl_rx_parser_cur_st;

        case(prl_rx_parser_cur_st)
          PRL_RX_PARSER_IDLE: begin
            if(prl_rx_parser_receive_req && prl_rx_parser_receive_is_sop_type) begin
                  prl_rx_parser_nxt_st = PRL_RX_PARSER_MESSAGE_HEADER;
            end
          end
          PRL_RX_PARSER_MESSAGE_HEADER: begin
            if(prl_rx_parser_receive_header_done) begin
               if(prl_rx_parser_receive_data[15]) begin  //extended message
                  prl_rx_parser_nxt_st = PRL_RX_PARSER_MESSAGE_EXTENDED;
               end
               else if(prl_rx_parser_receive_data[14:12] != 3'h0) begin  //data message
                  prl_rx_parser_nxt_st = PRL_RX_PARSER_MESSAGE_DATA;
               end
               else begin  //control message
                  prl_rx_parser_nxt_st = PRL_RX_PARSER_INFORM_MESSAGE;
               end
            end
          end
          PRL_RX_PARSER_MESSAGE_EXTENDED: begin
            if(prl_rx_parser_receive_header_ex_done) begin
                  prl_rx_parser_nxt_st = PRL_RX_PARSER_MESSAGE_DATA;
            end
          end
          PRL_RX_PARSER_MESSAGE_DATA: begin
            if(prl_rx_parser_receive_data_done) begin
                  prl_rx_parser_nxt_st = PRL_RX_PARSER_INFORM_MESSAGE;
            end
          end
          PRL_RX_PARSER_INFORM_MESSAGE: begin
            if(prl_rx_parser_receive_packet_done ) begin
               prl_rx_parser_nxt_st = PRL_RX_PARSER_IDLE;
            end
          end
	  default;
        endcase
end

//rx parser control signal genereate

assign prl_rx_parser_receive_req            = (prl_rx_parser_st_is_idle && phy2prl_rx_packet_en);
assign prl_rx_parser_receive_message_type   = prl_rx_parser_message_type;
assign prl_rx_parser_receive_is_sop_type    = (phy2prl_rx_packet_type < 3'h3);
assign prl_rx_parser_receive_packet_done    = phy2prl_rx_packet_done;


always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_parser_receive_data_cnt <= 3'h0;
       end
       else if(prl_rx_parser_receive_packet_done) begin
              prl_rx_parser_receive_data_cnt <= 3'h0;
       end
       else if(prl_rx_parser_receive_stage_done) begin
              prl_rx_parser_receive_data_cnt <= 3'h0;
       end
       else if(phy2prl_rx_payload_req ) begin
              prl_rx_parser_receive_data_cnt <= prl_rx_parser_receive_data_cnt + 1'h1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_parser_receive_data <= 32'h0;
       end
       //else if(prl_rx_parser_st_is_inform_message) begin
       //       prl_rx_parser_receive_data <= 32'h0;
       //end
       else if(phy2prl_rx_payload_req ) begin
           case(prl_rx_parser_receive_data_cnt[1:0])
              2'h0: prl_rx_parser_receive_data[ 7: 0] <= phy2prl_rx_payload;
              2'h1: prl_rx_parser_receive_data[15: 8] <= phy2prl_rx_payload;
              2'h2: prl_rx_parser_receive_data[23:16] <= phy2prl_rx_payload;
              2'h3: prl_rx_parser_receive_data[31:24] <= phy2prl_rx_payload;
	      default;
	   endcase
       end
end

assign prl_rx_parser_receive_stage_done       = prl_rx_parser_receive_header_done || prl_rx_parser_receive_header_ex_done || prl_rx_parser_receive_data_done;

assign prl_rx_parser_receive_header_done      = (prl_rx_parser_st_is_message_header   && (prl_rx_parser_receive_data_cnt == 3'h2));
assign prl_rx_parser_receive_header_ex_done   = (prl_rx_parser_st_is_message_extended && (prl_rx_parser_receive_data_cnt == 3'h2));
assign prl_rx_parser_receive_data_done        = (prl_rx_parser_st_is_message_data     && (prl_rx_parser_receive_data_cnt == 3'h4)); //????

//========================================================================================
//========================================================================================
//               PRL Parser Message 
//========================================================================================
//========================================================================================
//header parser
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_parser_message_type <= 2'h0;
              prl_rx_parser_header_type <= 5'h0;
              prl_rx_parser_message_id <= 3'h0;
       end
       else if(prl_rx_parser_receive_header_done) begin
          if(prl_rx_parser_receive_data[15]) begin
              prl_rx_parser_message_type <= 2'h2;
          end
          else if(prl_rx_parser_receive_data[14:12] != 3'h0) begin
              prl_rx_parser_message_type <= 2'h1;
          end
	  else begin
              prl_rx_parser_message_type <= 2'h0;
          end

              prl_rx_parser_header_type <= prl_rx_parser_receive_data[4:0];
              prl_rx_parser_message_id <= prl_rx_parser_receive_data[11:9];
       end
end

assign prl_rx_parser_sop_type        = phy2prl_rx_packet_type;

//extended header parser
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_parser_message_ex_data_size <= 9'h0;
       end
       else if(prl_rx_parser_receive_header_ex_done) begin
              prl_rx_parser_message_ex_data_size <= prl_rx_parser_receive_data[8:0];
       end
end

//data message parser
//request data message parser
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_parser_data_request_pdo_type        <= 1'h0;
       end
       else if(prl_rx_parser_receive_data_done) begin
           case(prl_rx_parser_receive_data[30:28])
	      3'h1: begin
                   prl_rx_parser_data_request_pdo_type        <= 1'h0;
              end
	      3'h2: begin
                   if(prl_tx_if_source_cap_table_select == 4'h0) begin
                         prl_rx_parser_data_request_pdo_type        <= 1'h1;
                   end
		   else begin
                         prl_rx_parser_data_request_pdo_type        <= 1'h0;
                   end
              end
	      3'h2: begin
                   if(prl_tx_if_source_cap_table_select < 4'h5) begin
                         prl_rx_parser_data_request_pdo_type        <= 1'h1;
                   end
		   else begin
                         prl_rx_parser_data_request_pdo_type        <= 1'h0;
                   end
              end
	      3'h3, 3'h4: begin
                   if(prl_tx_if_source_cap_table_select < 4'ha) begin
                         prl_rx_parser_data_request_pdo_type        <= 1'h1;
                   end
		   else begin
                         prl_rx_parser_data_request_pdo_type        <= 1'h0;
                   end
              end
	      3'h5, 3'h6: begin
                   prl_rx_parser_data_request_pdo_type        <= 1'h1;
              end
	      default;
	   endcase
       end
end


assign     prl_rx_parser_data_request_op_cur          = prl_rx_parser_data_request_pdo_type ?  prl_rx_parser_receive_data[19:9] : {1'b0, prl_rx_parser_receive_data[19:10]}; 
assign     prl_rx_parser_data_request_max_op_cur      = prl_rx_parser_data_request_pdo_type ? {3'h0, prl_rx_parser_receive_data[6:0]} : prl_rx_parser_receive_data[9:0]; 


always @(*) begin
       
              prl_rx_parser_data_src_cap_max_vol         = 8'd0;
              prl_rx_parser_data_src_cap_voltage         = 10'd100;
              prl_rx_parser_data_src_cap_max_cur         = 10'd300;
       
           casez({prl_rx_parser_receive_data[30:28], prl_tx_if_source_cap_table_select})
	      7'b000_111?: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd100;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd500;
              end
	      7'b001_0000, 7'b010_0001: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd59;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd60;
              end
	      7'b001_0011, 7'b001_01??, 7'b001_101?: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd180;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd300;
              end
	      7'b001_100?, 7'b001_1100: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd120;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd300;
              end
	      7'b001_1110: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd120;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd450;
              end
	      7'b001_1111: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd180;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd400;
              end
	      7'b010_0010: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd59;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd72;
              end
	      7'b010_0011: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd110;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd60;
              end
	      7'b010_0100: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd110;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd100;
              end
	      7'b010_0101, 7'b010_0110: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd300;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd240;
              end
	      7'b010_0111, 7'b010_1000: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd300;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd300;
              end
	      7'b010_1001: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd140;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd257;
              end
	      7'b010_1010, 7'b010_1101: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd140;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd300;
              end
	      7'b010_1011, 7'b010_1100, 7'b010_1111: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd240;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd300;
              end
	      7'b010_1110: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd140;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd386;
              end

	      7'b011_0001, 7'b011_0010: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd110;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd40;
              end
	      7'b011_010?, 7'b011_0111: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd110;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd60;
              end
	      7'b011_0110, 7'b011_1000: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd59;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd100;
              end
	      7'b001_1001: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd180;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd200;
              end
	      7'b001_1010, 7'b001_1110: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd180;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd300;
              end
	      7'b001_1011, 7'b001_1111: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd300;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd240;
              end
	      7'b001_1100: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd0;
                   prl_rx_parser_data_src_cap_voltage         = 10'd300;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd278;
              end

	      7'b100_0101: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd160;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd48;
              end
	      7'b100_0110: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd110;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd80;
              end
	      7'b100_0111: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd160;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd60;
              end
	      7'b100_1000: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd110;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd100;
              end

	      7'b101_0110: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd160;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd48;
              end
	      7'b101_1000: begin
                   prl_rx_parser_data_src_cap_max_vol         = 8'd160;
                   prl_rx_parser_data_src_cap_voltage         = 10'd30;
                   prl_rx_parser_data_src_cap_max_cur         = 10'd60;
              end
	      default;
	   endcase
end





//========================================================================================
//========================================================================================
//               PRL & PHY HandShake Control
//========================================================================================
//========================================================================================

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              prl_rx_parser_message_req <= 1'h0;
       end
       else if(phy2prl_rx_packet_done && prl_rx_parser_st_is_inform_message && (phy2prl_rx_packet_result == 2'h0)) begin
              prl_rx_parser_message_req <= 1'h1;
       end
       else begin
              prl_rx_parser_message_req <= 1'h0;
       end
end

//always @(posedge clk or negedge rst_n) begin
//       if(!rst_n) begin
//              prl_rx_parser_message_result <= 3'h0;
//       end
//       else if(phy2prl_rx_packet_done && !prl_rx_parser_st_is_inform_message) begin
//              prl_rx_parser_message_result <= 3'h4;
//       end
//       else if(phy2prl_rx_packet_done && prl_rx_parser_st_is_inform_message) begin
//              prl_rx_parser_message_result <= phy2prl_rx_packet_result;
//       end
//end









endmodule

