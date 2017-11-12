`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:21 05/21/2017 
// Design Name: 
// Module Name:    tx_packet_editor 
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
module phy_tx_packet_editor(
    clk,
    rst_n,

    pl2phy_tx_payload,
    pl2phy_tx_payload_last,
    phy2pl_tx_payload_done,

    phy_tx_bist_en,

    phy_tx_packet_en,
    phy_tx_packet_type,

    phy_tx_packet_crc,

    phy_bmc_encoder_data_en,
    phy_bmc_encoder_data,
    phy_bmc_encoder_data_preamble,
    phy_bmc_encoder_data_done,
    phy_bmc_encoder_hold_lowbmc_done

    );

input     clk;
input     rst_n;

input     [7:0] pl2phy_tx_payload;
input     pl2phy_tx_payload_last;
output    phy2pl_tx_payload_done;

output    phy_bmc_encoder_data_en;
output    [4:0] phy_bmc_encoder_data;
output    phy_bmc_encoder_data_preamble;
input     phy_bmc_encoder_data_done;
input     phy_bmc_encoder_hold_lowbmc_done;

input     [31:0] phy_tx_packet_crc;

input     phy_tx_bist_en;

input     phy_tx_packet_en;
input     [2:0] phy_tx_packet_type;

reg       phy_bmc_encoder_data_en;
reg       [4:0] phy_bmc_encoder_data;
reg       phy_bmc_encoder_data_preamble;



localparam TX_IDLE     = 3'h0;
localparam TX_PREABBLE = 3'h1;
localparam TX_SOP      = 3'h2;
localparam TX_PAYLAOD  = 3'h3;
localparam TX_CRC      = 3'h4;
localparam TX_EOP      = 3'h5;
localparam TX_HOLD_BMC = 3'h6;

localparam K_CODE_SYNC_1 = 5'b11000;
localparam K_CODE_SYNC_2 = 5'b10001;
localparam K_CODE_SYNC_3 = 5'b00110;
localparam K_CODE_RST_1  = 5'b00111;
localparam K_CODE_RST_2  = 5'b11001;
localparam K_CODE_EOP    = 5'b01101;

localparam SOP_TYPE_SOP         = 3'h0;
localparam SOP_TYPE_SOPP        = 3'h1;
localparam SOP_TYPE_SOPPP       = 3'h2;
localparam SOP_TYPE_HARDRESET   = 3'h3;
localparam SOP_TYPE_CABLERESET  = 3'h4;

reg       [2:0] phy_tx_packet_cur_st;
reg       [2:0] phy_tx_packet_nxt_st;

wire      phy_tx_packet_cur_is_idle;
wire      phy_tx_packet_cur_is_preamble;
wire      phy_tx_packet_cur_is_sop;
wire      phy_tx_packet_cur_is_payload;
wire      phy_tx_packet_cur_is_crc;
wire      phy_tx_packet_cur_is_eop;
wire      phy_tx_packet_cur_is_hold_bmc;

wire      phy_tx_packet_preamble_done;
wire      phy_tx_packet_sop_done;
wire      phy_tx_packet_payload_done;
wire      phy_tx_packet_crc_done;
wire      phy_tx_packet_eop_done;
wire      phy_tx_packet_hold_bmc_done;

wire      phy_tx_packet_no_payload;

reg       [2:0] phy_tx_packet_cnt;
wire      [3:0] phy_tx_packet_data;
wire      [3:0] phy_tx_packet_payload_data;
wire      [3:0] phy_tx_packet_crc_data;




always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_tx_packet_cur_st <= TX_IDLE;
       end
       else begin
              phy_tx_packet_cur_st <= phy_tx_packet_nxt_st;
       end
end

always @(*) begin
        phy_tx_packet_nxt_st = phy_tx_packet_cur_st;

        case(phy_tx_packet_cur_st)
          TX_IDLE: begin
            if(phy_tx_packet_en) begin
               phy_tx_packet_nxt_st = TX_PREABBLE;
            end
            else if(phy_tx_bist_en) begin
               phy_tx_packet_nxt_st = TX_PREABBLE;
            end
          end
          TX_PREABBLE: begin
            if(phy_tx_packet_preamble_done) begin
               if(phy_tx_bist_en) begin
                   phy_tx_packet_nxt_st = TX_PREABBLE;
               end
               else if(phy_tx_packet_en) begin
                   phy_tx_packet_nxt_st = TX_SOP;
               end
	       else begin
                   phy_tx_packet_nxt_st = TX_IDLE;
               end
            end
          end
          TX_SOP: begin
            if(phy_tx_packet_sop_done && phy_tx_packet_no_payload) begin
               phy_tx_packet_nxt_st = TX_HOLD_BMC;
            end
            else if(phy_tx_packet_sop_done) begin
               phy_tx_packet_nxt_st = TX_PAYLAOD;
            end
          end
          TX_PAYLAOD: begin
            if(phy_tx_packet_payload_done) begin
               phy_tx_packet_nxt_st = TX_CRC;
            end
          end
          TX_CRC: begin
            if(phy_tx_packet_crc_done) begin
               phy_tx_packet_nxt_st = TX_EOP;
            end
          end
          TX_EOP: begin
            if(phy_tx_packet_eop_done) begin
               phy_tx_packet_nxt_st = TX_HOLD_BMC;
            end
          end
          TX_HOLD_BMC: begin
            if(phy_tx_packet_hold_bmc_done) begin
               phy_tx_packet_nxt_st = TX_IDLE;
            end
          end
	  default;
        endcase
end

assign    phy_tx_packet_cur_is_idle        = (phy_tx_packet_cur_st == TX_IDLE);
assign    phy_tx_packet_cur_is_preamble    = (phy_tx_packet_cur_st == TX_PREABBLE);
assign    phy_tx_packet_cur_is_sop         = (phy_tx_packet_cur_st == TX_SOP);
assign    phy_tx_packet_cur_is_payload     = (phy_tx_packet_cur_st == TX_PAYLAOD);
assign    phy_tx_packet_cur_is_crc         = (phy_tx_packet_cur_st == TX_CRC);
assign    phy_tx_packet_cur_is_eop         = (phy_tx_packet_cur_st == TX_EOP);
assign    phy_tx_packet_cur_is_hold_bmc    = (phy_tx_packet_cur_st == TX_HOLD_BMC);

//bmc period
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_tx_packet_cnt <= 3'h0;
       end
       else if(phy_tx_packet_preamble_done || phy_tx_packet_crc_done || phy_tx_packet_payload_done || phy_tx_packet_sop_done) begin
              phy_tx_packet_cnt <= 3'h0;
       end
       else if(phy_bmc_encoder_data_done) begin
              phy_tx_packet_cnt <= phy_tx_packet_cnt + 1'h1;
       end
end

assign    phy_tx_packet_preamble_done = phy_tx_packet_cur_is_preamble && phy_bmc_encoder_data_done;
assign    phy_tx_packet_sop_done      = phy_tx_packet_cur_is_sop      && phy_bmc_encoder_data_done && (phy_tx_packet_cnt[1:0] == 2'h3);
assign    phy_tx_packet_payload_done  = phy_tx_packet_cur_is_payload  && phy_bmc_encoder_data_done && pl2phy_tx_payload_last && (phy_tx_packet_cnt[0] == 1'h1);
assign    phy_tx_packet_crc_done      = phy_tx_packet_cur_is_crc      && phy_bmc_encoder_data_done && (phy_tx_packet_cnt[2:0] == 3'h7);
assign    phy_tx_packet_eop_done      = phy_tx_packet_cur_is_eop      && phy_bmc_encoder_data_done;
assign    phy_tx_packet_hold_bmc_done = phy_tx_packet_cur_is_hold_bmc && phy_bmc_encoder_hold_lowbmc_done;

assign    phy_tx_packet_no_payload    = (phy_tx_packet_type == SOP_TYPE_HARDRESET) || (phy_tx_packet_type == SOP_TYPE_CABLERESET);

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_bmc_encoder_data_en <= 1'h0;
              phy_bmc_encoder_data <= 5'h0;
              phy_bmc_encoder_data_preamble <= 1'h0;
       end
       else if(phy_bmc_encoder_data_done) begin
              phy_bmc_encoder_data_en <= 1'h0;
              phy_bmc_encoder_data <= 5'h0;
              phy_bmc_encoder_data_preamble <= 1'h0;
       end
       else if(phy_tx_packet_cur_is_preamble) begin
              phy_bmc_encoder_data_en <= 1'h1;
              phy_bmc_encoder_data_preamble <= 1'h1;
       end
       else if(phy_tx_packet_cur_is_sop) begin
              phy_bmc_encoder_data_en <= 1'h1;
              phy_bmc_encoder_data_preamble <= 1'h0;

	      case(phy_tx_packet_type) 
		  SOP_TYPE_SOP: begin
			  case(phy_tx_packet_cnt[1:0])
			      2'h3:       phy_bmc_encoder_data <= K_CODE_SYNC_2;
			      default:    phy_bmc_encoder_data <= K_CODE_SYNC_1;
			  endcase
		  end
		  SOP_TYPE_SOPP: begin
			  case(phy_tx_packet_cnt[1:0])
			      2'h0, 2'h1: phy_bmc_encoder_data <= K_CODE_SYNC_1;
			      default:    phy_bmc_encoder_data <= K_CODE_SYNC_3;
			  endcase
		  end
		  SOP_TYPE_SOPPP: begin
			  case(phy_tx_packet_cnt[1:0])
			      2'h0, 2'h2: phy_bmc_encoder_data <= K_CODE_SYNC_1;
			      default:    phy_bmc_encoder_data <= K_CODE_SYNC_3;
			  endcase
		  end
		  SOP_TYPE_HARDRESET: begin
			  case(phy_tx_packet_cnt[1:0])
			      2'h3:       phy_bmc_encoder_data <= K_CODE_RST_2;
			      default:    phy_bmc_encoder_data <= K_CODE_RST_1;
			  endcase
		  end
		  SOP_TYPE_CABLERESET: begin
			  case(phy_tx_packet_cnt[1:0])
			      2'h0, 2'h2: phy_bmc_encoder_data <= K_CODE_RST_1;
			      2'h1:       phy_bmc_encoder_data <= K_CODE_SYNC_1;
			      default:    phy_bmc_encoder_data <= K_CODE_SYNC_3;
			  endcase
		  end
		  default;
	      endcase
       end
       else if(phy_tx_packet_cur_is_payload || phy_tx_packet_cur_is_crc) begin
              phy_bmc_encoder_data_en <= 1'h1;

	      case(phy_tx_packet_data)
	          4'h0: phy_bmc_encoder_data <= 5'b11110;
	          4'h1: phy_bmc_encoder_data <= 5'b01001;
	          4'h2: phy_bmc_encoder_data <= 5'b10100;
	          4'h3: phy_bmc_encoder_data <= 5'b10101;
	          4'h4: phy_bmc_encoder_data <= 5'b01010;
	          4'h5: phy_bmc_encoder_data <= 5'b01011;
	          4'h6: phy_bmc_encoder_data <= 5'b01110;
	          4'h7: phy_bmc_encoder_data <= 5'b01111;
	          4'h8: phy_bmc_encoder_data <= 5'b10010;
	          4'h9: phy_bmc_encoder_data <= 5'b10011;
	          4'ha: phy_bmc_encoder_data <= 5'b10110;
	          4'hb: phy_bmc_encoder_data <= 5'b10111;
	          4'hc: phy_bmc_encoder_data <= 5'b11010;
	          4'hd: phy_bmc_encoder_data <= 5'b11011;
	          4'he: phy_bmc_encoder_data <= 5'b11100;
	          4'hf: phy_bmc_encoder_data <= 5'b11101;
	          default;
	      endcase
       end
       else if(phy_tx_packet_cur_is_eop) begin
              phy_bmc_encoder_data_en <= 1'h1;
	      phy_bmc_encoder_data <= K_CODE_EOP;
       end
       else if(phy_tx_packet_cur_is_hold_bmc) begin
              phy_bmc_encoder_data_en <= 1'h0;
       end

end


assign    phy_tx_packet_payload_data    = phy_tx_packet_cnt[0] ? pl2phy_tx_payload[7:4] : pl2phy_tx_payload[3:0]; 
assign    phy_tx_packet_crc_data        = 
	                              (phy_tx_packet_cnt[2:0] == 3'h0) ? phy_tx_packet_crc[ 3: 0] :
	                              (phy_tx_packet_cnt[2:0] == 3'h1) ? phy_tx_packet_crc[ 7: 4] :
	                              (phy_tx_packet_cnt[2:0] == 3'h2) ? phy_tx_packet_crc[11: 8] :
	                              (phy_tx_packet_cnt[2:0] == 3'h3) ? phy_tx_packet_crc[15:12] :
	                              (phy_tx_packet_cnt[2:0] == 3'h4) ? phy_tx_packet_crc[19:16] :
	                              (phy_tx_packet_cnt[2:0] == 3'h5) ? phy_tx_packet_crc[23:20] :
	                              (phy_tx_packet_cnt[2:0] == 3'h6) ? phy_tx_packet_crc[27:24] :
    	                                                                 phy_tx_packet_crc[31:28] ;
assign    phy_tx_packet_data            = phy_tx_packet_cur_is_payload ? phy_tx_packet_payload_data : phy_tx_packet_crc_data;

assign    phy2pl_tx_payload_done    = phy_tx_packet_cur_is_payload && phy_bmc_encoder_data_done && (phy_tx_packet_cnt[0] == 1'h1);

endmodule
