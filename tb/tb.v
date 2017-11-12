`include "timescale.v"

module tb;

	// Inputs
	reg clk;
	reg rst_n;

//pe&pl tx signal  -master
reg                pe2pl_tx_en_m;
reg      [ 6:0]    pe2pl_tx_type_m;
reg      [ 2:0]    pe2pl_tx_sop_type_m;
reg      [ 4:0]    pe2pl_tx_info_m;
reg      [35:0]    pe2pl_tx_ex_info_m;
wire               pl2pe_tx_ack_m;
wire     [ 1:0]    pl2pe_tx_result_m;

reg                pe2pl_tx_ams_begin_m;
reg                pe2pl_tx_ams_end_m;

reg                pe2pl_hard_reset_ack_m;
reg                pe2pl_cable_reset_ack_m;
wire               pl2pe_hard_reset_req_m;
wire               pl2pe_cable_reset_req_m;

reg                pe2pl_tx_bist_carrier_mode_m;
//pe&pl rx signal  -master
wire               pl2pe_rx_en_m;
wire     [ 2:0]    pl2pe_rx_result_m;
wire     [ 6:0]    pl2pe_rx_type_m;
wire     [ 2:0]    pl2pe_rx_sop_type_m;
wire     [22:0]    pl2pe_rx_info_m;


//pe&pl tx signal  -slave
reg                pe2pl_tx_en_s;
reg      [ 6:0]    pe2pl_tx_type_s;
reg      [ 2:0]    pe2pl_tx_sop_type_s;
reg      [ 4:0]    pe2pl_tx_info_s;
reg      [35:0]    pe2pl_tx_ex_info_s;
wire               pl2pe_tx_ack_s;
wire     [ 1:0]    pl2pe_tx_result_s;

reg                pe2pl_tx_ams_begin_s;
reg                pe2pl_tx_ams_end_s;

reg                pe2pl_hard_reset_ack_s;
reg                pe2pl_cable_reset_ack_s;
wire               pl2pe_hard_reset_req_s;
wire               pl2pe_cable_reset_req_s;

reg                pe2pl_tx_bist_carrier_mode_s;
//pe&pl rx signal  -master
wire               pl2pe_rx_en_s;
wire     [ 2:0]    pl2pe_rx_result_s;
wire     [ 6:0]    pl2pe_rx_type_s;
wire     [ 2:0]    pl2pe_rx_sop_type_s;
wire     [22:0]    pl2pe_rx_info_s;



wire               phy_cc_signal;


//phy&pl tx signal  -master
wire                prl2phy_tx_packet_en_m;
wire      [ 2:0]    prl2phy_tx_packet_type_m;
wire                phy2prl_tx_packet_done_m;
wire                phy2prl_tx_packet_result_m;

wire                prl2phy_tx_payload_en_m;
wire      [ 7:0]    prl2phy_tx_payload_m;
wire                prl2phy_tx_payload_last_m;
wire                phy2prl_tx_payload_done_m;



//phy&pl rx signal  -master
wire                prl2phy_rx_packet_select_m;
wire                phy2prl_rx_packet_en_m;
wire      [ 2:0]    phy2prl_rx_packet_type_m;
wire                phy2prl_rx_packet_done_m;
wire      [ 1:0]    phy2prl_rx_packet_result_m;

wire      [ 7:0]    phy2prl_rx_payload_m;
wire                phy2prl_rx_payload_req_m;

wire                prl2phy_tx_bist_carrier_mode_m;
//phy&pl tx signal  -slave
wire                prl2phy_tx_packet_en_s;
wire      [ 2:0]    prl2phy_tx_packet_type_s;
wire                phy2prl_tx_packet_done_s;
wire                phy2prl_tx_packet_result_s;

wire                prl2phy_tx_payload_en_s;
wire      [ 7:0]    prl2phy_tx_payload_s;
wire                prl2phy_tx_payload_last_s;
wire                phy2prl_tx_payload_done_s;

wire                prl2phy_tx_bist_carrier_mode_s;


//phy&pl rx signal  -slave
wire                prl2phy_rx_packet_select_s;
wire                phy2prl_rx_packet_en_s;
wire      [ 2:0]    phy2prl_rx_packet_type_s;
wire                phy2prl_rx_packet_done_s;
wire      [ 1:0]    phy2prl_rx_packet_result_s;

wire      [ 7:0]    phy2prl_rx_payload_s;
wire                phy2prl_rx_payload_req_s;

wire   [ 0:0]      pe2ana_trans_en;
wire   [ 0:0]      pe2ana_trans_pdotype;
wire   [ 9:0]      pe2ana_trans_voltage;
wire   [ 9:0]      pe2ana_trans_current;
wire   [ 0:0]      ana2pe_attached;
wire   [ 0:0]      ana2pe_trans_finish;
wire   [15:0]      ana2pe_pps_voltage;
wire   [ 7:0]      ana2pe_pps_current;
wire   [ 1:0]      ana2pe_pps_ptf;
wire   [ 0:0]      ana2pe_pps_omf;
wire   [ 0:0]      ana2pe_alert;

pd_top DUT (
    .clk                    (clk),
    .rst_n                  (rst_n),

    //global signal
    .i_support_5amps         (1'b1),
    .i_pdo_selidx            (4'b0),

    //analog&pe signal
    .ana2pe_attached         (ana2pe_attached),
    .pe2ana_trans_en         (pe2ana_trans_en),
    .pe2ana_trans_pdotype    (pe2ana_trans_pdotype),
    .pe2ana_trans_voltage    (pe2ana_trans_voltage),
    .pe2ana_trans_current    (pe2ana_trans_current),
    .ana2pe_trans_finish     (ana2pe_trans_finish),
    .ana2pe_pps_voltage      (ana2pe_pps_voltage),
    .ana2pe_pps_current      (ana2pe_pps_current),
    .ana2pe_pps_ptf          (ana2pe_pps_ptf),
    .ana2pe_pps_omf          (ana2pe_pps_omf),
    .ana2pe_alert            (ana2pe_alert),

    .phy_cc_signal           (phy_cc_signal)
);

ana_model u_ana (
    .clk                    (clk),
    .rst_n                  (rst_n),

    .ana2pe_attached         (ana2pe_attached),
    .pe2ana_trans_en         (pe2ana_trans_en),
    .pe2ana_trans_pdotype    (pe2ana_trans_pdotype),
    .pe2ana_trans_voltage    (pe2ana_trans_voltage),
    .pe2ana_trans_current    (pe2ana_trans_current),
    .ana2pe_trans_finish     (ana2pe_trans_finish),
    .ana2pe_pps_voltage      (ana2pe_pps_voltage),
    .ana2pe_pps_current      (ana2pe_pps_current),
    .ana2pe_pps_ptf          (ana2pe_pps_ptf),
    .ana2pe_pps_omf          (ana2pe_pps_omf),
    .ana2pe_alert            (ana2pe_alert)
);

prl_top prl_top_s(
    .clk                               (clk                               ),
    .rst_n                             (rst_n                             ),
                                                                          
    //pe&pl tx signal                   /pe&pl tx signal
    .pe2pl_tx_en                       (pe2pl_tx_en_s                     ),
    .pe2pl_tx_type                     (pe2pl_tx_type_s                   ),
    .pe2pl_tx_sop_type                 (pe2pl_tx_sop_type_s               ),
    .pe2pl_tx_info                     (pe2pl_tx_info_s                   ),
    .pe2pl_tx_ex_info                  (pe2pl_tx_ex_info_s                ),
    .pl2pe_tx_ack                      (pl2pe_tx_ack_s                    ),
    .pl2pe_tx_result                   (pl2pe_tx_result_s                 ),
                                                                          
    .pe2pl_tx_ams_begin                (pe2pl_tx_ams_begin_s              ),
    .pe2pl_tx_ams_end                  (pe2pl_tx_ams_end_s                ),
                                                                          
    .pe2pl_tx_bist_carrier_mode        (pe2pl_tx_bist_carrier_mode_s      ),
    //pe&pl rx signal                   /pe&pl rx signal
    .pl2pe_rx_en                       (pl2pe_rx_en_s                     ),
    //.pl2pe_rx_result                   (pl2pe_rx_result_s                 ),
    .pl2pe_rx_type                     (pl2pe_rx_type_s                   ),
    .pl2pe_rx_sop_type                 (pl2pe_rx_sop_type_s               ),
    .pl2pe_rx_info                     (pl2pe_rx_info_s                   ),
                                                                          
    //pe&pl reset handshake             /pe&pl reset handshake
    .pl2pe_hard_reset_req              (pl2pe_hard_reset_req_s            ),
    //.pl2pe_cable_reset_req             (pl2pe_cable_reset_req_s           ),
    .pe2pl_hard_reset_ack              (pe2pl_hard_reset_ack_s            ),
    //.pe2pl_cable_reset_ack             (pe2pl_cable_reset_ack_s           ),
                                                                          
    //phy&pl tx signal                  /phy&pl tx signal
    .prl2phy_tx_packet_en              (prl2phy_tx_packet_en_s            ),
    .prl2phy_tx_packet_type            (prl2phy_tx_packet_type_s          ),
    .phy2prl_tx_packet_done            (phy2prl_tx_packet_done_s          ),
    .phy2prl_tx_packet_result          (phy2prl_tx_packet_result_s        ),
                                                                          
    .prl2phy_tx_payload_en             (prl2phy_tx_payload_en_s           ),
    .prl2phy_tx_payload                (prl2phy_tx_payload_s              ),
    .prl2phy_tx_payload_last           (prl2phy_tx_payload_last_s         ),
    .phy2prl_tx_payload_done           (phy2prl_tx_payload_done_s         ),
                                                                          
    .phy2prl_tx_phy_reset_done         (1'b0                              ),
    .prl2phy_tx_phy_reset_req          (),
                                                                          
    .pe2pl_reset_req                   (1'b0                              ),
    .prl2phy_reset_req                 (                                  ),
                                                                          
    .prl2phy_tx_bist_carrier_mode      (prl2phy_tx_bist_carrier_mode_s    ),
                                                                          
    //phy&pl rx signal                  /phy&pl rx signal
    .prl2phy_rx_packet_select          (prl2phy_rx_packet_select_s        ),
    .phy2prl_rx_packet_en              (phy2prl_rx_packet_en_s            ),
    .phy2prl_rx_packet_type            (phy2prl_rx_packet_type_s          ),
    .phy2prl_rx_packet_done            (phy2prl_rx_packet_done_s          ),
    .phy2prl_rx_packet_result          (phy2prl_rx_packet_result_s        ),
                                                                          
    .phy2prl_rx_payload                (phy2prl_rx_payload_s              ),
    .phy2prl_rx_payload_req            (phy2prl_rx_payload_req_s          )
    
    
);


phy_top phy_top_s(
    .clk                               (clk                               ),
    .rst_n                             (rst_n                             ),
                                                                          
    .pl2phy_tx_packet_en               (prl2phy_tx_packet_en_s             ),
    .pl2phy_tx_packet_type             (prl2phy_tx_packet_type_s           ),
    .phy2pl_tx_packet_done             (phy2prl_tx_packet_done_s           ),
    .phy2pl_tx_packet_result           (phy2prl_tx_packet_result_s         ),
                                                                          
    .pl2phy_tx_bist_carrier_mode       (prl2phy_tx_bist_carrier_mode_s     ),
                                                                          
    .pl2phy_rx_packet_select           (prl2phy_rx_packet_select_s         ),
    .phy2pl_rx_packet_en               (phy2prl_rx_packet_en_s             ),
    .phy2pl_rx_packet_type             (phy2prl_rx_packet_type_s           ),
    .phy2pl_rx_packet_done             (phy2prl_rx_packet_done_s           ),
    .phy2pl_rx_packet_result           (phy2prl_rx_packet_result_s         ),
                                                                          
    .pl2phy_tx_payload_en              (prl2phy_tx_payload_en_s            ),
    .pl2phy_tx_payload                 (prl2phy_tx_payload_s               ),
    .pl2phy_tx_payload_last            (prl2phy_tx_payload_last_s          ),
    .phy2pl_tx_payload_done            (phy2prl_tx_payload_done_s          ),
                                                                          
    .phy2pl_rx_payload                 (phy2prl_rx_payload_s               ),
    .phy2pl_rx_payload_en              (phy2prl_rx_payload_req_s            ),
                                                                          
    .pl2phy_reset_req                  (1'b0                  ),
    .pl2phy_tx_phy_reset_req           (1'b0                  ),
    .phy2pl_tx_phy_reset_done          (                 ),
                                                                          
    .phy_cc_signal                     (phy_cc_signal                     )

);


pullup(phy_cc_signal);

always #208 clk = ~clk;

initial begin
    // Initialize Inputs
    clk = 0;
    rst_n = 0;

	#1500;
	rst_n = 1;
	#1500;
    $display($stime, "-->Initial done.");

    #200000000
    $finish();
end

initial begin
    $fsdbDumpfile("sim.fsdb");
    $fsdbDumpvars;
end

endmodule

