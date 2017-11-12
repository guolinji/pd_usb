`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:01:05 05/21/2017
// Design Name:   bmc_encoder
// Module Name:   C:/Users/Administrator/Desktop/PD/CRC/tb_bmc_encoder.v
// Project Name:  crc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: bmc_encoder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module phy_top(
    clk,
    rst_n,

    pl2phy_tx_bist_carrier_mode,

    pl2phy_tx_packet_en,
    pl2phy_tx_packet_type,
    phy2pl_tx_packet_done,
    phy2pl_tx_packet_result,

    pl2phy_rx_packet_select,
    phy2pl_rx_packet_en,
    phy2pl_rx_packet_type,
    phy2pl_rx_packet_done,
    phy2pl_rx_packet_result,

    pl2phy_tx_payload_en,
    pl2phy_tx_payload,
    pl2phy_tx_payload_last,
    phy2pl_tx_payload_done,

    phy2pl_rx_payload,
    phy2pl_rx_payload_en,

    pl2phy_reset_req,
    phy2pl_tx_phy_reset_done,
    pl2phy_tx_phy_reset_req,

    phy_cc_signal

);

parameter          TIME_SCALE_FLAG =  0;  //0:2.4M  1:4.8M 2:9.6M

input     clk;
input     rst_n;

//tx
input     pl2phy_tx_bist_carrier_mode;

input     pl2phy_tx_packet_en;
input     [2:0] pl2phy_tx_packet_type;
output    phy2pl_tx_packet_done;
output    phy2pl_tx_packet_result;

input     pl2phy_reset_req;
output    phy2pl_tx_phy_reset_done;
input     pl2phy_tx_phy_reset_req;
//rx
input     pl2phy_rx_packet_select;
output    phy2pl_rx_packet_en;
output    [2:0] phy2pl_rx_packet_type;
output    phy2pl_rx_packet_done;
output    [1:0] phy2pl_rx_packet_result;

//tx payload
input     pl2phy_tx_payload_en;
input     [7:0] pl2phy_tx_payload;
input     pl2phy_tx_payload_last;
output    phy2pl_tx_payload_done;

//rx payload
output    [7:0] phy2pl_rx_payload;
output    phy2pl_rx_payload_en;

inout     phy_cc_signal;

wire      phy_control_tx_rx_select;
wire      phy_control_tx_rx_clr;

wire      phy_control_tx_packet_en;
wire      [2:0] phy_control_tx_packet_type;
wire      phy_control_tx_packet_done;

wire      phy_definition_of_idle_en;
wire      phy_definition_of_idle_done;
wire      phy_definition_of_idle_result;

wire      phy_control_rx_packet_en;
wire      [2:0] phy_control_rx_packet_type;
wire      phy_control_rx_paylaod_en;
wire      [3:0] phy_control_rx_paylaod;
wire      phy_control_rx_packet_eop;
wire      phy_control_rx_packet_crc_error;
wire      phy_control_rx_packet_payload_error;
wire      phy_control_rx_packet_timeout;

//crc if
wire      [31:0] phy_tx_packet_crc;

//bmc encoder
wire      phy_bmc_encoder_data_en;
wire      [4:0] phy_bmc_encoder_data;
wire      phy_bmc_encoder_data_preamble;
wire      phy_bmc_encoder_data_done;
wire      phy_bmc_encoder_hold_lowbmc_done;


//bmc decoder
wire      phy_bmc_decoder_data;
wire      phy_bmc_decoder_data_en;


reg                rst_n_reg_0;
reg                rst_n_reg_1;
wire               rst_n_mix;

reg                pl_rst_req;

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              rst_n_reg_0              <= 1'h0;
              rst_n_reg_1              <= 1'h0;
       end
       else if(pl2phy_reset_req) begin
              rst_n_reg_0              <= 1'h0;
              rst_n_reg_1              <= 1'h0;
       end
       else begin
              rst_n_reg_0              <= 1'h1;
              rst_n_reg_1              <= rst_n_reg_0;
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              pl_rst_req               <= 1'h0;
       end
       else if(pl2phy_tx_phy_reset_req) begin
              pl_rst_req               <= 1'h0;
       end
       else begin
              pl_rst_req               <= 1'h1;
       end
end

assign  phy2pl_tx_phy_reset_done  = pl_rst_req;

assign  rst_n_mix  = rst_n && rst_n_reg_1 && pl_rst_req;



        phy_control_tx_rx phy_control_tx_rx(
		.clk(clk), 
		.rst_n(rst_n_mix), 

                .phy_control_tx_rx_select(phy_control_tx_rx_select),
                .phy_control_tx_rx_clr(phy_control_tx_rx_clr),

                //tx
                .pl2phy_tx_packet_en(pl2phy_tx_packet_en),
                .pl2phy_tx_packet_type(pl2phy_tx_packet_type),
                .phy2pl_tx_packet_done(phy2pl_tx_packet_done),
                .phy2pl_tx_packet_result(phy2pl_tx_packet_result),

                .phy_control_tx_packet_en(phy_control_tx_packet_en),
                .phy_control_tx_packet_type(phy_control_tx_packet_type),
                .phy_control_tx_packet_done(phy_bmc_encoder_hold_lowbmc_done),

                .phy_definition_of_idle_en(phy_definition_of_idle_en),
                .phy_definition_of_idle_done(phy_definition_of_idle_done),
                .phy_definition_of_idle_result(phy_definition_of_idle_result),
                //rx
                .pl2phy_rx_packet_select(pl2phy_rx_packet_select),
                .phy2pl_rx_packet_en(phy2pl_rx_packet_en),
                .phy2pl_rx_packet_type(phy2pl_rx_packet_type),
                .phy2pl_rx_packet_done(phy2pl_rx_packet_done),
                .phy2pl_rx_packet_result(phy2pl_rx_packet_result),
                .phy2pl_rx_payload(phy2pl_rx_payload),
                .phy2pl_rx_payload_en(phy2pl_rx_payload_en),

                .phy_control_rx_packet_en(phy_control_rx_packet_en),
                .phy_control_rx_packet_type(phy_control_rx_packet_type),
                .phy_control_rx_paylaod(phy_control_rx_paylaod),
                .phy_control_rx_paylaod_en(phy_control_rx_paylaod_en),
                .phy_control_rx_packet_eop(phy_control_rx_packet_eop),
                .phy_control_rx_packet_crc_error(phy_control_rx_packet_crc_error),
                .phy_control_rx_packet_payload_error(phy_control_rx_packet_payload_error),
                .phy_control_rx_packet_timeout(phy_control_rx_packet_timeout)

        );

        phy_tx_packet_editor phy_tx_packet_editor(
		.clk(clk), 
		.rst_n(rst_n_mix), 

                .pl2phy_tx_payload(pl2phy_tx_payload),
                .pl2phy_tx_payload_last(pl2phy_tx_payload_last),
                .phy2pl_tx_payload_done(phy2pl_tx_payload_done),

                .phy_tx_bist_en(pl2phy_tx_bist_carrier_mode),
                .phy_tx_packet_en(phy_control_tx_packet_en),
                .phy_tx_packet_type(phy_control_tx_packet_type),

                .phy_tx_packet_crc(phy_tx_packet_crc),

                .phy_bmc_encoder_data_en(phy_bmc_encoder_data_en),
                .phy_bmc_encoder_data(phy_bmc_encoder_data),
                .phy_bmc_encoder_data_preamble(phy_bmc_encoder_data_preamble),
                .phy_bmc_encoder_data_done(phy_bmc_encoder_done),
                .phy_bmc_encoder_hold_lowbmc_done(phy_bmc_encoder_hold_lowbmc_done)

        );

	phy_bmc_encoder #(TIME_SCALE_FLAG) phy_bmc_encoder(
		.clk(clk), 
		.rst_n(rst_n_mix), 

		.phy_bmc_encoder_data(phy_bmc_encoder_data), 
		.phy_bmc_encoder_data_en(phy_bmc_encoder_data_en), 
		.phy_bmc_encoder_data_preamble(phy_bmc_encoder_data_preamble), 
		.phy_bmc_encoder_data_done(phy_bmc_encoder_done), 
                .phy_bmc_encoder_hold_lowbmc_done(phy_bmc_encoder_hold_lowbmc_done),

		.phy_bmc_encoder_drive_data(phy_bmc_encoder_drive_data),
		.phy_bmc_encoder_drive_en(phy_bmc_encoder_drive_en)
	);

        phy_bmc_decoder #(TIME_SCALE_FLAG) phy_bmc_decoder(
                .clk(clk),
                .rst_n(rst_n_mix),
            
                .phy_bmc_decoder_in(phy_cc_signal),
                .phy_bmc_decoder_clr(phy_control_tx_rx_clr),
                .phy_bmc_decoder_dis(phy_control_tx_rx_select),
            
                .phy_bmc_decoder_out(phy_bmc_decoder_data),
                .phy_bmc_decoder_out_en(phy_bmc_decoder_data_en)
                );

        phy_sop_detect phy_sop_detect(
                .clk(clk),
                .rst_n(rst_n_mix),

                .phy_sop_detect_clr(phy_control_tx_rx_clr),

                .phy_bmc_decoder_data(phy_bmc_decoder_data),
                .phy_bmc_decoder_data_en(phy_bmc_decoder_data_en),

                .phy_sop_detect_type(phy_control_rx_packet_type),
                .phy_sop_detect_type_en(phy_control_rx_packet_en),
                .phy_sop_detect_payload_out(phy_control_rx_paylaod),
                .phy_sop_detect_payload_out_en(phy_control_rx_paylaod_en),
                .phy_sop_detect_eop(phy_control_rx_packet_eop),
                .phy_sop_detect_payload_error(phy_control_rx_packet_payload_error),
                .phy_sop_detect_timeout(phy_control_rx_packet_timeout)
                );

         phy_crc32_tx_rx phy_crc32_tx_rx(
                .clk(clk),
                .rst_n(rst_n_mix),


                .phy_crc_tx_rx_select(phy_control_tx_rx_select),

                .phy_tx_packet_data_en(pl2phy_tx_payload_en),
                .phy_tx_packet_data_in(pl2phy_tx_payload),
                .phy_tx_packet_data_last(pl2phy_tx_payload_last),
                .phy_tx_packet_crc(phy_tx_packet_crc),

                .phy_rx_crc_data_in(phy_control_rx_paylaod),
                .phy_rx_crc_data_en(phy_control_rx_paylaod_en),
                .phy_rx_crc_data_last(phy_control_rx_packet_eop),
                .phy_rx_crc_out_fail(phy_control_rx_packet_crc_error)

         );

         phy_definition_of_idle phy_definition_of_idle(
                .clk(clk),
                .rst_n(rst_n_mix),

                .phy_cc_signal(phy_cc_signal),

                .phy_definition_of_idle_en(phy_definition_of_idle_en),
                .phy_definition_of_idle_done(phy_definition_of_idle_done),
                .phy_definition_of_idle_result(phy_definition_of_idle_result)
        );


//inout cc signal
assign  phy_cc_signal   = phy_bmc_encoder_drive_en ? (phy_bmc_encoder_drive_data ? 1'b0 : 1'b1)   : 1'bz;
 
endmodule

