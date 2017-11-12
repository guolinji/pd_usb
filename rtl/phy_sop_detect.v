 `include "timescale.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:21 05/21/2017 
// Design Name: 
// Module Name:    sop_detect_4b5b_decoder 
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
module phy_sop_detect(
    clk,
    rst_n,

    phy_sop_detect_clr,

    //bmc decoder data input
    phy_bmc_decoder_data,
    phy_bmc_decoder_data_en,

    //sop detect data output
    phy_sop_detect_type,
    phy_sop_detect_type_en,
    phy_sop_detect_payload_out,
    phy_sop_detect_payload_out_en,
    phy_sop_detect_eop,
    phy_sop_detect_payload_error,
    phy_sop_detect_timeout
    );

input     clk;
input     rst_n;

input     phy_bmc_decoder_data;
input     phy_bmc_decoder_data_en;

input     phy_sop_detect_clr;

output    [2:0] phy_sop_detect_type;
output    phy_sop_detect_type_en;
output    [3:0] phy_sop_detect_payload_out;
output    phy_sop_detect_payload_out_en;
output    phy_sop_detect_eop;
output    phy_sop_detect_payload_error;
output    phy_sop_detect_timeout;

localparam K_CODE_SYNC_1 = 5'b11000;
localparam K_CODE_SYNC_2 = 5'b10001;
localparam K_CODE_SYNC_3 = 5'b00110;
localparam K_CODE_RST_1  = 5'b00111;
localparam K_CODE_RST_2  = 5'b11001;
localparam K_CODE_EOP    = 5'b01101;

localparam PAYLOAD_TIMEOUT    = 16'hfff;

reg       [2:0] phy_sop_detect_type;
reg       phy_sop_detect_type_en;
reg       [3:0] phy_sop_detect_payload_out;
reg       phy_sop_detect_payload_out_en;
reg       phy_sop_detect_payload_error;
reg       phy_sop_detect_eop;

//preamble detect
reg       [5:0] phy_sop_detect_preamble_cnt;
wire      phy_sop_detect_preamble_done;
reg       phy_sop_detect_preamble_en;
wire      phy_sop_detect_preamble_error;

//paylaod detect
reg       [3:0] phy_sop_detect_payload_data;
wire      [4:0] phy_sop_detect_payload_data_wire;
reg       [2:0] phy_sop_detect_payload_cnt;
reg       phy_sop_detect_payload_en;
wire      phy_sop_detect_payload_done;
//k-code detect
reg       [1:0] phy_sop_detect_k_code_cnt;
wire      phy_sop_detect_k_code_done;
reg       phy_sop_detect_k_code_en;

reg       phy_sop_detect_k_code_1st_is_sync_1;
reg       phy_sop_detect_k_code_1st_is_rst_1;

reg       phy_sop_detect_k_code_2nd_is_sync_1;
reg       phy_sop_detect_k_code_2nd_is_sync_3;
reg       phy_sop_detect_k_code_2nd_is_rst_1;

reg       phy_sop_detect_k_code_3rd_is_sync_1;
reg       phy_sop_detect_k_code_3rd_is_sync_3;
reg       phy_sop_detect_k_code_3rd_is_rst_1;

reg       phy_sop_detect_k_code_4th_is_sync_2;
reg       phy_sop_detect_k_code_4th_is_sync_3;
reg       phy_sop_detect_k_code_4th_is_rst_2;


wire      phy_sop_detect_type_is_sop;
wire      phy_sop_detect_type_is_sopp;
wire      phy_sop_detect_type_is_soppp;
wire      phy_sop_detect_type_is_hardreset;
wire      phy_sop_detect_type_is_cablereset;

//timeout control
reg       [15:0] phy_sop_detect_timeout_cnt;
reg       phy_sop_detect_timeout_en;

//preamble detect
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_preamble_cnt <= 6'b0;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_preamble_cnt <= 6'b0;
       end
       else if(phy_sop_detect_preamble_done) begin
              phy_sop_detect_preamble_cnt <= 6'b0;
       end
       else if(phy_bmc_decoder_data_en && phy_sop_detect_preamble_en) begin
              phy_sop_detect_preamble_cnt <= phy_sop_detect_preamble_cnt + 1'b1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_preamble_en <= 1'b1;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_preamble_en <= 1'b1;
       end
       else if(phy_sop_detect_preamble_done) begin
              phy_sop_detect_preamble_en <= 1'b0;
       end
end

assign    phy_sop_detect_preamble_done = phy_bmc_decoder_data_en && (phy_sop_detect_preamble_cnt == 6'h3f);

assign    phy_sop_detect_preamble_error = phy_bmc_decoder_data_en && phy_sop_detect_preamble_en && (phy_sop_detect_preamble_cnt[0] != phy_bmc_decoder_data);

//payload detect
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_payload_data <= 4'b0;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_payload_data <= 4'b0;
       end
       else if(phy_sop_detect_payload_en && phy_bmc_decoder_data_en) begin
              phy_sop_detect_payload_data <= {phy_bmc_decoder_data, phy_sop_detect_payload_data[3:1]};
       end
end

assign    phy_sop_detect_payload_data_wire = {phy_bmc_decoder_data, phy_sop_detect_payload_data};

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_payload_cnt <= 3'h0;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_payload_cnt <= 3'h0;
       end
       else if(phy_sop_detect_payload_done) begin
              phy_sop_detect_payload_cnt <= 3'h0;
       end
       else if(phy_sop_detect_payload_en && phy_bmc_decoder_data_en) begin
              phy_sop_detect_payload_cnt <= phy_sop_detect_payload_cnt + 1'b1;
       end
end

assign    phy_sop_detect_payload_done = phy_bmc_decoder_data_en && (phy_sop_detect_payload_cnt == 3'h4);


//k-code detect
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_k_code_cnt <= 2'h0;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_k_code_cnt <= 2'h0;
       end
       else if(phy_sop_detect_k_code_en && phy_sop_detect_payload_done) begin
              phy_sop_detect_k_code_cnt <= phy_sop_detect_k_code_cnt + 1'b1;
       end
end

assign    phy_sop_detect_k_code_done = phy_sop_detect_payload_done && phy_sop_detect_k_code_en && (phy_sop_detect_k_code_cnt == 2'h3);

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_k_code_en <= 1'b0;
              phy_sop_detect_payload_en <= 1'b0;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_k_code_en <= 1'b0;
              phy_sop_detect_payload_en <= 1'b0;
       end
       else if(phy_sop_detect_k_code_done) begin
              phy_sop_detect_k_code_en <= 1'b0;
       end
       else if(phy_sop_detect_preamble_done) begin
              phy_sop_detect_k_code_en <= 1'b1;
              phy_sop_detect_payload_en <= 1'b1;
       end
       else if(phy_sop_detect_eop) begin
              phy_sop_detect_payload_en <= 1'b0;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_k_code_1st_is_sync_1 <= 1'b0;
              phy_sop_detect_k_code_1st_is_rst_1 <= 1'b0;

              phy_sop_detect_k_code_2nd_is_sync_1 <= 1'b0;
              phy_sop_detect_k_code_2nd_is_sync_3 <= 1'b0;
              phy_sop_detect_k_code_2nd_is_rst_1 <= 1'b0;

              phy_sop_detect_k_code_3rd_is_sync_1 <= 1'b0;
              phy_sop_detect_k_code_3rd_is_sync_3 <= 1'b0;
              phy_sop_detect_k_code_3rd_is_rst_1 <= 1'b0;

              phy_sop_detect_k_code_4th_is_sync_2 <= 1'b0;
              phy_sop_detect_k_code_4th_is_sync_3 <= 1'b0;
              phy_sop_detect_k_code_4th_is_rst_2 <= 1'b0;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_k_code_1st_is_sync_1 <= 1'b0;
              phy_sop_detect_k_code_1st_is_rst_1 <= 1'b0;

              phy_sop_detect_k_code_2nd_is_sync_1 <= 1'b0;
              phy_sop_detect_k_code_2nd_is_sync_3 <= 1'b0;
              phy_sop_detect_k_code_2nd_is_rst_1 <= 1'b0;

              phy_sop_detect_k_code_3rd_is_sync_1 <= 1'b0;
              phy_sop_detect_k_code_3rd_is_sync_3 <= 1'b0;
              phy_sop_detect_k_code_3rd_is_rst_1 <= 1'b0;

              phy_sop_detect_k_code_4th_is_sync_2 <= 1'b0;
              phy_sop_detect_k_code_4th_is_sync_3 <= 1'b0;
              phy_sop_detect_k_code_4th_is_rst_2 <= 1'b0;
       end
       else if(phy_sop_detect_payload_done && phy_sop_detect_k_code_en) begin
	   case(phy_sop_detect_k_code_cnt)
	       2'h0: begin
                    if(phy_sop_detect_payload_data_wire == K_CODE_SYNC_1) begin
                          phy_sop_detect_k_code_1st_is_sync_1 <= 1'b1;
		    end
                    else if(phy_sop_detect_payload_data_wire == K_CODE_RST_1) begin
                          phy_sop_detect_k_code_1st_is_rst_1 <= 1'b1;
		    end
	       end
	       2'h1: begin
                    if(phy_sop_detect_payload_data_wire == K_CODE_SYNC_1) begin
                          phy_sop_detect_k_code_2nd_is_sync_1 <= 1'b1;
		    end
                    else if(phy_sop_detect_payload_data_wire == K_CODE_SYNC_3) begin
                          phy_sop_detect_k_code_2nd_is_sync_3 <= 1'b1;
		    end
                    else if(phy_sop_detect_payload_data_wire == K_CODE_RST_1) begin
                          phy_sop_detect_k_code_2nd_is_rst_1 <= 1'b1;
		    end
	       end
	       2'h2: begin
                    if(phy_sop_detect_payload_data_wire == K_CODE_SYNC_1) begin
                          phy_sop_detect_k_code_3rd_is_sync_1 <= 1'b1;
		    end
                    else if(phy_sop_detect_payload_data_wire == K_CODE_SYNC_3) begin
                          phy_sop_detect_k_code_3rd_is_sync_3 <= 1'b1;
		    end
                    else if(phy_sop_detect_payload_data_wire == K_CODE_RST_1) begin
                          phy_sop_detect_k_code_3rd_is_rst_1 <= 1'b1;
		    end
	       end
	       2'h3: begin
                    if(phy_sop_detect_payload_data_wire == K_CODE_SYNC_2) begin
                          phy_sop_detect_k_code_4th_is_sync_2 <= 1'b1;
		    end
                    else if(phy_sop_detect_payload_data_wire == K_CODE_SYNC_3) begin
                          phy_sop_detect_k_code_4th_is_sync_3 <= 1'b1;
		    end
                    else if(phy_sop_detect_payload_data_wire == K_CODE_RST_2) begin
                          phy_sop_detect_k_code_4th_is_rst_2 <= 1'b1;
		    end
	       end
	       default;
	   endcase
       end
end





assign    phy_sop_detect_type_is_sop =
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_3rd_is_sync_1 ||
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_4th_is_sync_2 ||
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_3rd_is_sync_1 && phy_sop_detect_k_code_4th_is_sync_2 ||
                                 	phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_3rd_is_sync_1 && phy_sop_detect_k_code_4th_is_sync_2 ;

assign    phy_sop_detect_type_is_sopp =
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_3rd_is_sync_3 ||
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_4th_is_sync_3 ||
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_3rd_is_sync_3 && phy_sop_detect_k_code_4th_is_sync_3 ||
                                 	phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_3rd_is_sync_3 && phy_sop_detect_k_code_4th_is_sync_3 ;

assign    phy_sop_detect_type_is_soppp =
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_2nd_is_sync_3 && phy_sop_detect_k_code_3rd_is_sync_1 ||
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_2nd_is_sync_3 && phy_sop_detect_k_code_4th_is_sync_3 ||
                                 	phy_sop_detect_k_code_1st_is_sync_1 && phy_sop_detect_k_code_3rd_is_sync_1 && phy_sop_detect_k_code_4th_is_sync_3 ||
                                 	phy_sop_detect_k_code_2nd_is_sync_3 && phy_sop_detect_k_code_3rd_is_sync_1 && phy_sop_detect_k_code_4th_is_sync_3 ;

assign    phy_sop_detect_type_is_hardreset =
                                 	phy_sop_detect_k_code_1st_is_rst_1  && phy_sop_detect_k_code_2nd_is_rst_1  && phy_sop_detect_k_code_3rd_is_rst_1  ||
                                 	phy_sop_detect_k_code_1st_is_rst_1  && phy_sop_detect_k_code_2nd_is_rst_1  && phy_sop_detect_k_code_4th_is_rst_2  ||
                                 	phy_sop_detect_k_code_1st_is_rst_1  && phy_sop_detect_k_code_3rd_is_rst_1  && phy_sop_detect_k_code_4th_is_rst_2  ||
                                 	phy_sop_detect_k_code_2nd_is_rst_1  && phy_sop_detect_k_code_3rd_is_rst_1  && phy_sop_detect_k_code_4th_is_rst_2  ;

assign    phy_sop_detect_type_is_cablereset =
                                 	phy_sop_detect_k_code_1st_is_rst_1  && phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_3rd_is_rst_1  ||
                                 	phy_sop_detect_k_code_1st_is_rst_1  && phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_4th_is_sync_3 ||
                                 	phy_sop_detect_k_code_1st_is_rst_1  && phy_sop_detect_k_code_3rd_is_rst_1  && phy_sop_detect_k_code_4th_is_sync_3 ||
                                 	phy_sop_detect_k_code_2nd_is_sync_1 && phy_sop_detect_k_code_3rd_is_rst_1  && phy_sop_detect_k_code_4th_is_sync_3 ;



always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_type_en <= 1'b0;
       end
       else begin
              phy_sop_detect_type_en <= phy_sop_detect_k_code_done;
       end
end

always @(*) begin
              phy_sop_detect_type = 3'h0;

          if(phy_sop_detect_type_is_sopp) begin
              phy_sop_detect_type = 3'h1;
          end
          else if(phy_sop_detect_type_is_soppp) begin
              phy_sop_detect_type = 3'h2;
          end
          else if(phy_sop_detect_type_is_hardreset) begin
              phy_sop_detect_type = 3'h3;
          end
          else if(phy_sop_detect_type_is_cablereset) begin
              phy_sop_detect_type = 3'h4;
          end

end


always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_payload_out <= 4'h0;
              phy_sop_detect_payload_out_en <= 1'h0;
              phy_sop_detect_payload_error <= 1'h0;
              phy_sop_detect_eop <= 1'h0;
       end
       else if(phy_sop_detect_payload_done && !phy_sop_detect_k_code_en) begin
              phy_sop_detect_payload_out_en <= 1'h1;

	   case(phy_sop_detect_payload_data_wire)
	       5'b11110: phy_sop_detect_payload_out <= 4'h0;
	       5'b01001: phy_sop_detect_payload_out <= 4'h1;
	       5'b10100: phy_sop_detect_payload_out <= 4'h2;
	       5'b10101: phy_sop_detect_payload_out <= 4'h3;
	       5'b01010: phy_sop_detect_payload_out <= 4'h4;
	       5'b01011: phy_sop_detect_payload_out <= 4'h5;
	       5'b01110: phy_sop_detect_payload_out <= 4'h6;
	       5'b01111: phy_sop_detect_payload_out <= 4'h7;
	       5'b10010: phy_sop_detect_payload_out <= 4'h8;
	       5'b10011: phy_sop_detect_payload_out <= 4'h9;
	       5'b10110: phy_sop_detect_payload_out <= 4'ha;
	       5'b10111: phy_sop_detect_payload_out <= 4'hb;
	       5'b11010: phy_sop_detect_payload_out <= 4'hc;
	       5'b11011: phy_sop_detect_payload_out <= 4'hd;
	       5'b11100: phy_sop_detect_payload_out <= 4'he;
	       5'b11101: phy_sop_detect_payload_out <= 4'hf;
	       5'b01101: phy_sop_detect_eop <= 1'h1;
	       default: phy_sop_detect_payload_error <= 1'b1;
	   endcase
       end
       else begin
              phy_sop_detect_payload_out_en <= 1'h0;
              phy_sop_detect_payload_error <= 1'h0;
              phy_sop_detect_eop <= 1'h0;
       end
end


//timeout control
always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_timeout_cnt <= 16'h0;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_timeout_cnt <= 16'h0;
       end
       else if(phy_sop_detect_payload_done) begin
              phy_sop_detect_timeout_cnt <= 16'h0;
       end
       else if(phy_sop_detect_timeout_en) begin
              phy_sop_detect_timeout_cnt <= phy_sop_detect_timeout_cnt +1'h1;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_sop_detect_timeout_en <= 1'h0;
       end
       else if(phy_sop_detect_clr) begin
              phy_sop_detect_timeout_en <= 1'h0;
       end
       else if(phy_sop_detect_type_en && (phy_sop_detect_type_is_hardreset || phy_sop_detect_type_is_cablereset)) begin
              phy_sop_detect_timeout_en <= 1'h0;
       end
       else if(phy_sop_detect_timeout || phy_sop_detect_eop) begin
              phy_sop_detect_timeout_en <= 1'h0;
       end
       else if(phy_sop_detect_k_code_done) begin
              phy_sop_detect_timeout_en <= 1'h1;
       end
end


assign    phy_sop_detect_timeout = (phy_sop_detect_timeout_cnt == PAYLOAD_TIMEOUT);

endmodule
