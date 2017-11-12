`include timescale.v
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
    phy_cc_signal
);

input              clk;
input              rst_n;
inout              phy_cc_signal;

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

dpe_top dpe_top(
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
    .pe2pl_reset_req                   (1'b0                              ),
);

prl_top prl_top(
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


phy_top phy_top(
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
