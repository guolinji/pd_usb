`include "timescale.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:21 05/21/2017
// Design Name: 
// Module Name:    PD
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
module pd_top (
    clk,
    rst_n,

    //global signal
    i_support_5amps,
    i_pdo_selidx,

    //analog&pe signal
    ana2pe_attached,
    pe2ana_trans_en,
    pe2ana_trans_pdotype,
    pe2ana_trans_voltage,
    pe2ana_trans_current,
    ana2pe_trans_finish,
    ana2pe_pps_voltage,
    ana2pe_pps_current,
    ana2pe_pps_ptf,
    ana2pe_pps_omf,
    ana2pe_alert,

    phy_cc_signal
);

parameter  TIME_SCALE_FLAG =  0;  //0:2.4M  1:4.8M 2:9.6M
parameter  FREQ_MULTI_300K                  = 8;
parameter  WIDTH_MULTI_300K                 = 3;


input              clk;
input              rst_n;
inout              phy_cc_signal;


//global signal
input               i_support_5amps;
input   [ 3:0]      i_pdo_selidx;

//analog&pe signal
input   [ 0:0]      ana2pe_attached;
output  [ 0:0]      pe2ana_trans_en;
output  [ 0:0]      pe2ana_trans_pdotype;
output  [ 9:0]      pe2ana_trans_voltage;
output  [ 9:0]      pe2ana_trans_current;
input   [ 0:0]      ana2pe_trans_finish;
input   [15:0]      ana2pe_pps_voltage;
input   [ 7:0]      ana2pe_pps_current;
input   [ 1:0]      ana2pe_pps_ptf;
input   [ 0:0]      ana2pe_pps_omf;
input   [ 0:0]      ana2pe_alert;

wire    [ 0:0]      ana2pe_attached;
wire    [ 0:0]      pe2ana_trans_en;
wire    [ 0:0]      pe2ana_trans_pdotype;
wire    [ 9:0]      pe2ana_trans_voltage;
wire    [ 9:0]      pe2ana_trans_current;
wire    [ 0:0]      ana2pe_trans_finish;
wire    [15:0]      ana2pe_pps_voltage;
wire    [ 7:0]      ana2pe_pps_current;
wire    [ 1:0]      ana2pe_pps_ptf;
wire    [ 0:0]      ana2pe_pps_omf;
wire    [ 0:0]      ana2pe_alert;

//pe&pl tx signal
wire               pe2pl_tx_en;
wire     [ 6:0]    pe2pl_tx_type;
wire     [ 2:0]    pe2pl_tx_sop_type;
wire     [ 4:0]    pe2pl_tx_info;
wire     [35:0]    pe2pl_tx_ex_info;
wire               pl2pe_tx_ack;
wire     [ 1:0]    pl2pe_tx_result;

wire               pe2pl_tx_ams_begin;
wire               pe2pl_tx_ams_end;

wire               pe2pl_tx_bist_carrier_mode;

wire               pe2pl_hard_reset_ack;
wire               pl2pe_hard_reset_req;

//pe&pl rx signal
wire               pl2pe_rx_en;
wire     [ 6:0]    pl2pe_rx_type;
wire     [ 2:0]    pl2pe_rx_sop_type;
wire     [22:0]    pl2pe_rx_info;


//phy&pl tx signal
wire               prl2phy_tx_packet_en;
wire     [ 2:0]    prl2phy_tx_packet_type;
wire               phy2prl_tx_packet_done;
wire               phy2prl_tx_packet_result;

wire               prl2phy_tx_payload_en;
wire     [ 7:0]    prl2phy_tx_payload;
wire               prl2phy_tx_payload_last;
wire               phy2prl_tx_payload_done;

wire               phy2prl_tx_phy_reset_done;
wire               prl2phy_tx_phy_reset_req;

wire               pe2pl_reset_req;
wire               prl2phy_reset_req;

wire               prl2phy_tx_bist_carrier_mode;

//phy&pl rx signal
wire               prl2phy_rx_packet_select;
wire               phy2prl_rx_packet_en;
wire     [ 2:0]    phy2prl_rx_packet_type;
wire               phy2prl_rx_packet_done;
wire     [ 1:0]    phy2prl_rx_packet_result;

wire     [ 7:0]    phy2prl_rx_payload;
wire               phy2prl_rx_payload_req;

dpe_top #(.FREQ_MULTI_300K(FREQ_MULTI_300K),.WIDTH_MULTI_300K(WIDTH_MULTI_300K)) dpe_top(
    .clk                               (clk),
    .rst_n                             (rst_n),
                                                                          
    //global signal
    .i_support_5amps                   (i_support_5amps),
    .i_pdo_selidx                      (i_pdo_selidx),

    //analog&pe signal
    .ana2pe_attached                   (ana2pe_attached),
    .pe2ana_trans_en                   (pe2ana_trans_en),
    .pe2ana_trans_pdotype              (pe2ana_trans_pdotype),
    .pe2ana_trans_voltage              (pe2ana_trans_voltage),
    .pe2ana_trans_current              (pe2ana_trans_current),
    .ana2pe_trans_finish               (ana2pe_trans_finish),
    .ana2pe_pps_voltage                (ana2pe_pps_voltage),
    .ana2pe_pps_current                (ana2pe_pps_current),
    .ana2pe_pps_ptf                    (ana2pe_pps_ptf),
    .ana2pe_pps_omf                    (ana2pe_pps_omf),
    .ana2pe_alert                      (ana2pe_alert),

    .pe2pl_reset_req                   (pe2pl_reset_req),

    //pe&pl tx signal
    .pe2pl_tx_en                       (pe2pl_tx_en),
    .pe2pl_tx_type                     (pe2pl_tx_type),
    .pe2pl_tx_sop_type                 (pe2pl_tx_sop_type),
    .pe2pl_tx_info                     (pe2pl_tx_info),
    .pe2pl_tx_ex_info                  (pe2pl_tx_ex_info),
    .pl2pe_tx_ack                      (pl2pe_tx_ack),
    .pl2pe_tx_result                   (pl2pe_tx_result),

    .pe2pl_tx_ams_begin                (pe2pl_tx_ams_begin),
    .pe2pl_tx_ams_end                  (pe2pl_tx_ams_end),

    .pe2pl_tx_bist_carrier_mode        (pe2pl_tx_bist_carrier_mode),

    //pe&pl rx signal
    .pl2pe_rx_en                       (pl2pe_rx_en),
    .pl2pe_rx_type                     (pl2pe_rx_type),
    .pl2pe_rx_sop_type                 (pl2pe_rx_sop_type),
    .pl2pe_rx_info                     (pl2pe_rx_info),

    //pe&pl reset handshake
    .pl2pe_hard_reset_req              (pl2pe_hard_reset_req),
    .pe2pl_hard_reset_ack              (pe2pl_hard_reset_ack)
);

prl_top #(TIME_SCALE_FLAG) prl_top(
    .clk                               (clk                               ),
    .rst_n                             (rst_n                             ),
                                                                          
    //pe&pl tx signal                   /pe&pl tx signal
    .pe2pl_tx_en                       (pe2pl_tx_en                       ),
    .pe2pl_tx_type                     (pe2pl_tx_type                     ),
    .pe2pl_tx_sop_type                 (pe2pl_tx_sop_type                 ),
    .pe2pl_tx_info                     (pe2pl_tx_info                     ),
    .pe2pl_tx_ex_info                  (pe2pl_tx_ex_info                  ),
    .pl2pe_tx_ack                      (pl2pe_tx_ack                      ),
    .pl2pe_tx_result                   (pl2pe_tx_result                   ),
                                                                          
    .pe2pl_tx_ams_begin                (pe2pl_tx_ams_begin                ),
    .pe2pl_tx_ams_end                  (pe2pl_tx_ams_end                  ),
                                                                          
    .pe2pl_tx_bist_carrier_mode        (pe2pl_tx_bist_carrier_mode        ),
    //pe&pl rx signal                   /pe&pl rx signal
    .pl2pe_rx_en                       (pl2pe_rx_en                       ),
    //.pl2pe_rx_result                   (pl2pe_rx_result                   ),
    .pl2pe_rx_type                     (pl2pe_rx_type                     ),
    .pl2pe_rx_sop_type                 (pl2pe_rx_sop_type                 ),
    .pl2pe_rx_info                     (pl2pe_rx_info                     ),
                                                                          
    //pe&pl reset handshake             /pe&pl reset handshake
    .pl2pe_hard_reset_req              (pl2pe_hard_reset_req              ),
    //.pl2pe_cable_reset_req             (pl2pe_cable_reset_req             ),
    .pe2pl_hard_reset_ack              (pe2pl_hard_reset_ack              ),
    //.pe2pl_cable_reset_ack             (pe2pl_cable_reset_ack             ),
                                                                          
    //phy&pl tx signal                  /phy&pl tx signal
    .prl2phy_tx_packet_en              (prl2phy_tx_packet_en              ),
    .prl2phy_tx_packet_type            (prl2phy_tx_packet_type            ),
    .phy2prl_tx_packet_done            (phy2prl_tx_packet_done            ),
    .phy2prl_tx_packet_result          (phy2prl_tx_packet_result          ),
                                                                          
    .prl2phy_tx_payload_en             (prl2phy_tx_payload_en             ),
    .prl2phy_tx_payload                (prl2phy_tx_payload                ),
    .prl2phy_tx_payload_last           (prl2phy_tx_payload_last           ),
    .phy2prl_tx_payload_done           (phy2prl_tx_payload_done           ),
                                                                          
    .phy2prl_tx_phy_reset_done         (1'b0                              ),
    .prl2phy_tx_phy_reset_req          (),
                                                                          
    .pe2pl_reset_req                   (1'b0                              ),
    .prl2phy_reset_req                 (                                  ),
                                                                          
    .prl2phy_tx_bist_carrier_mode      (prl2phy_tx_bist_carrier_mode      ),
                                                                          
    //phy&pl rx signal                  /phy&pl rx signal
    .prl2phy_rx_packet_select          (prl2phy_rx_packet_select          ),
    .phy2prl_rx_packet_en              (phy2prl_rx_packet_en              ),
    .phy2prl_rx_packet_type            (phy2prl_rx_packet_type            ),
    .phy2prl_rx_packet_done            (phy2prl_rx_packet_done            ),
    .phy2prl_rx_packet_result          (phy2prl_rx_packet_result          ),
                                                                          
    .phy2prl_rx_payload                (phy2prl_rx_payload                ),
    .phy2prl_rx_payload_req            (phy2prl_rx_payload_req            )
    
);


phy_top #(TIME_SCALE_FLAG) phy_top(
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
                                                                          
    .pl2phy_tx_packet_en               (prl2phy_tx_packet_en               ),
    .pl2phy_tx_packet_type             (prl2phy_tx_packet_type             ),
    .phy2pl_tx_packet_done             (phy2prl_tx_packet_done             ),
    .phy2pl_tx_packet_result           (phy2prl_tx_packet_result           ),
                                                                          
    .pl2phy_tx_bist_carrier_mode       (prl2phy_tx_bist_carrier_mode       ),
                                                                          
    .pl2phy_rx_packet_select           (prl2phy_rx_packet_select           ),
    .phy2pl_rx_packet_en               (phy2prl_rx_packet_en               ),
    .phy2pl_rx_packet_type             (phy2prl_rx_packet_type             ),
    .phy2pl_rx_packet_done             (phy2prl_rx_packet_done             ),
    .phy2pl_rx_packet_result           (phy2prl_rx_packet_result           ),
                                                                          
    .pl2phy_tx_payload_en              (prl2phy_tx_payload_en              ),
    .pl2phy_tx_payload                 (prl2phy_tx_payload                 ),
    .pl2phy_tx_payload_last            (prl2phy_tx_payload_last            ),
    .phy2pl_tx_payload_done            (phy2prl_tx_payload_done            ),
                                                                          
    .phy2pl_rx_payload                 (phy2prl_rx_payload                 ),
    .phy2pl_rx_payload_en              (phy2prl_rx_payload_req             ),
                                                                          
    .pl2phy_reset_req                  (1'b0                               ),
    .pl2phy_tx_phy_reset_req           (1'b0                               ),
    .phy2pl_tx_phy_reset_done          (                                   ),
                                                                          
    .phy_cc_signal                     (phy_cc_signal                      )

);

endmodule

