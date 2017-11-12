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
module prl_top(
    clk,
    rst_n,

    //pe&pl tx signal
    pe2pl_tx_en,
    pe2pl_tx_type,
    pe2pl_tx_sop_type,
    pe2pl_tx_info,
    pe2pl_tx_ex_info,
    pl2pe_tx_ack,
    pl2pe_tx_result,
    
    pe2pl_tx_ams_begin,
    pe2pl_tx_ams_end,

    pe2pl_tx_bist_carrier_mode,

    //pe&pl rx signal
    pl2pe_rx_en,
    pl2pe_rx_type,
    pl2pe_rx_sop_type,
    pl2pe_rx_info,

    //pe&pl reset handshake
    pl2pe_hard_reset_req,
    pe2pl_hard_reset_ack,

    //phy&pl tx signal
    prl2phy_tx_packet_en,
    prl2phy_tx_packet_type,
    phy2prl_tx_packet_done,
    phy2prl_tx_packet_result,
    
    prl2phy_tx_payload_en,
    prl2phy_tx_payload,
    prl2phy_tx_payload_last,
    phy2prl_tx_payload_done,
    
    phy2prl_tx_phy_reset_done,
    prl2phy_tx_phy_reset_req,

    pe2pl_reset_req,
    prl2phy_reset_req,

    prl2phy_tx_bist_carrier_mode,

    //phy&pl rx signal
    prl2phy_rx_packet_select,
    phy2prl_rx_packet_en,
    phy2prl_rx_packet_type,
    phy2prl_rx_packet_done,
    phy2prl_rx_packet_result,
    
    phy2prl_rx_payload,
    phy2prl_rx_payload_req
    
    
);

parameter          TIME_SCALE_FLAG =  0;  //0:2.4M  1:4.8M 2:9.6M

input              clk;
input              rst_n;

//pe&pl tx signal
input              pe2pl_tx_en;
input    [ 6:0]    pe2pl_tx_type;
input    [ 2:0]    pe2pl_tx_sop_type;
input    [ 4:0]    pe2pl_tx_info;
input    [35:0]    pe2pl_tx_ex_info;
output             pl2pe_tx_ack;
output   [ 1:0]    pl2pe_tx_result;

input              pe2pl_tx_ams_begin;
input              pe2pl_tx_ams_end;

input              pe2pl_tx_bist_carrier_mode;

input              pe2pl_hard_reset_ack;
output             pl2pe_hard_reset_req;

//pe&pl rx signal
output             pl2pe_rx_en;
output   [ 6:0]    pl2pe_rx_type;
output   [ 2:0]    pl2pe_rx_sop_type;
output   [22:0]    pl2pe_rx_info;


//phy&pl tx signal
output             prl2phy_tx_packet_en;
output   [ 2:0]    prl2phy_tx_packet_type;
input              phy2prl_tx_packet_done;
input              phy2prl_tx_packet_result;

output             prl2phy_tx_payload_en;
output   [ 7:0]    prl2phy_tx_payload;
output             prl2phy_tx_payload_last;
input              phy2prl_tx_payload_done;

input              phy2prl_tx_phy_reset_done;
output             prl2phy_tx_phy_reset_req;

input              pe2pl_reset_req;
output             prl2phy_reset_req;

output             prl2phy_tx_bist_carrier_mode;

//phy&pl rx signal
output             prl2phy_rx_packet_select;
input              phy2prl_rx_packet_en;
input    [ 2:0]    phy2prl_rx_packet_type;
input              phy2prl_rx_packet_done;
input    [ 1:0]    phy2prl_rx_packet_result;

input    [ 7:0]    phy2prl_rx_payload;
input              phy2prl_rx_payload_req;




wire               prl_rx_st_inform_pe_en;

wire               prl_tx_if_en;
wire     [ 2:0]    prl_tx_if_sop_type;
wire     [ 1:0]    prl_tx_if_message_type;
wire     [ 4:0]    prl_tx_if_header_type;
wire     [ 8:0]    prl_tx_if_ex_message_data_size;

wire               prl_tx_st_message_if_ack;
wire     [ 1:0]    prl_tx_st_message_if_ack_result;

wire               prl_tx_st_message_construct_reset;
wire               prl_tx_st_message_construct_req;
wire     [ 2:0]    prl_tx_st_messageid_counter;
wire               prl_tx_st_message_construct_ack;
wire               prl_tx_st_message_construct_ack_result;


wire               prl_rx_st_send_goodcrc_req;
wire     [ 1:0]    prl_rx_st_send_goodcrc_sop_type;
wire     [ 2:0]    prl_rx_st_send_goodcrc_messageid;
wire               prl_rx_st_send_goodcrc_ack;
wire               prl_rx_st_send_goodcrc_ack_result;


wire               prl_hdrst_send_req;
wire               prl_hdrst_send_ack;
wire               prl_hdrst_send_ack_result;

wire     [ 3:0]    prl_tx_if_source_cap_table_select;
wire               prl_tx_if_source_cap_current;

wire               prl_tx_if_ex_pps_status_flag_omf;
wire               prl_tx_if_ex_pps_status_flag_ptp;
wire     [ 7:0]    prl_tx_if_ex_pps_status_output_current;
wire     [15:0]    prl_tx_if_ex_pps_status_output_voltage;

wire               prl_rx_parser_message_req;
//wire     [ 2:0]    prl_rx_parser_message_result;
wire     [ 1:0]    prl_rx_parser_message_type;
wire     [ 2:0]    prl_rx_parser_sop_type;
wire     [ 4:0]    prl_rx_parser_header_type;
wire     [ 2:0]    prl_rx_parser_message_id;
wire     [ 8:0]    prl_rx_parser_message_ex_data_size;

wire               prl_rx_parser_data_bist_mode;

wire               prl_rx_parser_data_request_pdo_type;
wire     [10:0]    prl_rx_parser_data_request_op_cur;
wire     [ 9:0]    prl_rx_parser_data_request_max_op_cur;
wire               prl_rx_parser_data_request_mismatch_flag;



reg                rst_n_reg_0;
reg                rst_n_reg_1;
wire               rst_n_mix;

assign  prl2phy_reset_req  = pe2pl_reset_req;

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              rst_n_reg_0              <= 1'h0;
              rst_n_reg_1              <= 1'h0;
       end
       else if(pe2pl_reset_req) begin
              rst_n_reg_0              <= 1'h0;
              rst_n_reg_1              <= 1'h0;
       end
       else begin
              rst_n_reg_0              <= 1'h1;
              rst_n_reg_1              <= rst_n_reg_0;
       end
end

assign  rst_n_mix  = rst_n && rst_n_reg_1;


prl_ctl_state_machine #(TIME_SCALE_FLAG) prl_ctl_state_machine(
    .clk                                      (clk                                      ),
    .rst_n                                    (rst_n_mix                                ),
                                                                                        
    .pe2pl_tx_ams_begin                       (pe2pl_tx_ams_begin                       ),
    .pe2pl_tx_ams_end                         (pe2pl_tx_ams_end                         ),
                                                                                        
    .pe2pl_tx_bist_carrier_mode               (pe2pl_tx_bist_carrier_mode               ),
                                                                                        
    .prl2phy_tx_phy_reset_req                 (prl2phy_tx_phy_reset_req                 ),
    .phy2prl_tx_phy_reset_done                (phy2prl_tx_phy_reset_done                ),
                                                                                        
    .prl2phy_rx_packet_select                 (prl2phy_rx_packet_select                 ),
    .prl2phy_tx_bist_carrier_mode             (prl2phy_tx_bist_carrier_mode             ),
                                                                                        
    //pe&pl reset handshake                   
    .pl2pe_hard_reset_req                     (pl2pe_hard_reset_req                     ),
    .pe2pl_hard_reset_ack                     (pe2pl_hard_reset_ack                     ),
                                                                                        
    //prl rx st & rx if signal               
    .prl_rx_st_inform_pe_en                   (prl_rx_st_inform_pe_en                   ),
                                                                                        
    //rx parser message signal              
    .prl_rx_parser_message_req                (prl_rx_parser_message_req                ),
//    .prl_rx_parser_message_result             (prl_rx_parser_message_result             ),
    .prl_rx_parser_message_type               (prl_rx_parser_message_type               ),
    .prl_rx_parser_sop_type                   (prl_rx_parser_sop_type                   ),
    .prl_rx_parser_header_type                (prl_rx_parser_header_type                ),
    .prl_rx_parser_message_id                 (prl_rx_parser_message_id                 ),
                                                                                        
    //prl tx st construct signal           
    .prl_tx_st_message_construct_reset        (prl_tx_st_message_construct_reset        ),
    .prl_tx_st_message_construct_req          (prl_tx_st_message_construct_req          ),
    .prl_tx_st_messageid_counter              (prl_tx_st_messageid_counter              ),
    .prl_tx_st_message_construct_ack          (prl_tx_st_message_construct_ack          ),
    .prl_tx_st_message_construct_ack_result   (prl_tx_st_message_construct_ack_result   ),
                                                                                        
    .prl_tx_st_message_if_ack                 (prl_tx_st_message_if_ack                 ),
    .prl_tx_st_message_if_ack_result          (prl_tx_st_message_if_ack_result          ),
                                                                                        
    //prl tx if signal                    
    .prl_tx_if_en                             (prl_tx_if_en                             ),
    .prl_tx_if_sop_type                       (prl_tx_if_sop_type                       ),
    .prl_tx_if_message_type                   (prl_tx_if_message_type                   ),
    .prl_tx_if_header_type                    (prl_tx_if_header_type                    ),
    .prl_tx_if_ex_message_data_size           (prl_tx_if_ex_message_data_size           ),
                                                                                        
    //prl rx construct signal            
    .prl_rx_st_send_goodcrc_req               (prl_rx_st_send_goodcrc_req               ),
    .prl_rx_st_send_goodcrc_sop_type          (prl_rx_st_send_goodcrc_sop_type          ),
    .prl_rx_st_send_goodcrc_messageid         (prl_rx_st_send_goodcrc_messageid         ),
    .prl_rx_st_send_goodcrc_ack               (prl_rx_st_send_goodcrc_ack               ),
    .prl_rx_st_send_goodcrc_ack_result        (prl_rx_st_send_goodcrc_ack_result        ),
                                                                                        
    //prl hdrst construct signal        
    .prl_hdrst_send_req                       (prl_hdrst_send_req                       ),
    .prl_hdrst_send_ack                       (prl_hdrst_send_ack                       ),
    .prl_hdrst_send_ack_result                (prl_hdrst_send_ack_result                )

);




prl_tx_message_if prl_tx_message_if(
    .clk                                      (clk                                      ),
    .rst_n                                    (rst_n_mix                                ),
                                                                                        
    //pe&pl if                            
    .pe2pl_tx_en                              (pe2pl_tx_en                              ),
    .pe2pl_tx_type                            (pe2pl_tx_type                            ),
    .pe2pl_tx_sop_type                        (pe2pl_tx_sop_type                        ),
    .pe2pl_tx_info                            (pe2pl_tx_info                            ),
    .pe2pl_tx_ex_info                         (pe2pl_tx_ex_info                         ),
    .pl2pe_tx_ack                             (pl2pe_tx_ack                             ),
    .pl2pe_tx_result                          (pl2pe_tx_result                          ),
                                                                                        
    //tx st&if if                        
    .prl_tx_st_message_if_ack                 (prl_tx_st_message_if_ack                 ),
    .prl_tx_st_message_if_ack_result          (prl_tx_st_message_if_ack_result          ),
                                                                                        
    //pl tx message decode if           
    .prl_tx_if_en                             (prl_tx_if_en                             ),
    .prl_tx_if_sop_type                       (prl_tx_if_sop_type                       ),
    .prl_tx_if_message_type                   (prl_tx_if_message_type                   ),
    .prl_tx_if_header_type                    (prl_tx_if_header_type                    ),
                                                                                        
    .prl_tx_if_source_cap_table_select        (prl_tx_if_source_cap_table_select        ),
    .prl_tx_if_source_cap_current             (prl_tx_if_source_cap_current             ),
                                                                                        
    .prl_tx_if_ex_message_data_size           (prl_tx_if_ex_message_data_size           ),
                                                                                        
    .prl_tx_if_ex_pps_status_flag_omf         (prl_tx_if_ex_pps_status_flag_omf         ),
    .prl_tx_if_ex_pps_status_flag_ptp         (prl_tx_if_ex_pps_status_flag_ptp         ),
    .prl_tx_if_ex_pps_status_output_current   (prl_tx_if_ex_pps_status_output_current   ),
    .prl_tx_if_ex_pps_status_output_voltage   (prl_tx_if_ex_pps_status_output_voltage   )

);



prl_tx_message_path prl_tx_message_path(
    .clk                                      (clk                                      ),
    .rst_n                                    (rst_n_mix                                ),
                                                                                        
    //prl&phy tx control if            
    .prl2phy_tx_packet_en                     (prl2phy_tx_packet_en                     ),
    .prl2phy_tx_packet_type                   (prl2phy_tx_packet_type                   ),
    .phy2prl_tx_packet_done                   (phy2prl_tx_packet_done                   ),
    .phy2prl_tx_packet_result                 (phy2prl_tx_packet_result                 ),
                                                                                        
    //prl&phy tx data if              
    .prl2phy_tx_payload_en                    (prl2phy_tx_payload_en                    ),
    .prl2phy_tx_payload                       (prl2phy_tx_payload                       ),
    .prl2phy_tx_payload_last                  (prl2phy_tx_payload_last                  ),
    .phy2prl_tx_payload_done                  (phy2prl_tx_payload_done                  ),
                                                                                        
    //prl tx if message decode      
    .prl_tx_if_sop_type                       (prl_tx_if_sop_type                       ),
    .prl_tx_if_message_type                   (prl_tx_if_message_type                   ),
    .prl_tx_if_header_type                    (prl_tx_if_header_type                    ),
                                                                                        
    .prl_tx_if_source_cap_table_select        (prl_tx_if_source_cap_table_select        ),
    .prl_tx_if_source_cap_current             (prl_tx_if_source_cap_current             ),
                                                                                        
    .prl_tx_if_ex_message_data_size           (prl_tx_if_ex_message_data_size           ),
                                                                                        
    .prl_tx_if_ex_pps_status_flag_omf         (prl_tx_if_ex_pps_status_flag_omf         ),
    .prl_tx_if_ex_pps_status_flag_ptp         (prl_tx_if_ex_pps_status_flag_ptp         ),
    .prl_tx_if_ex_pps_status_output_current   (prl_tx_if_ex_pps_status_output_current   ),
    .prl_tx_if_ex_pps_status_output_voltage   (prl_tx_if_ex_pps_status_output_voltage   ),
                                                                                        
    //prl tx st signal                    
    .prl_tx_st_message_construct_reset        (prl_tx_st_message_construct_reset        ),
    .prl_tx_st_message_construct_req          (prl_tx_st_message_construct_req          ),
    .prl_tx_st_messageid_counter              (prl_tx_st_messageid_counter              ),
    .prl_tx_st_message_construct_ack          (prl_tx_st_message_construct_ack          ),
    .prl_tx_st_message_construct_ack_result   (prl_tx_st_message_construct_ack_result   ),
                                                                                        
    //prl rx construct signal            
    .prl_rx_st_send_goodcrc_req               (prl_rx_st_send_goodcrc_req               ),
    .prl_rx_st_send_goodcrc_sop_type          (prl_rx_st_send_goodcrc_sop_type          ),
    .prl_rx_st_send_goodcrc_messageid         (prl_rx_st_send_goodcrc_messageid         ),
    .prl_rx_st_send_goodcrc_ack               (prl_rx_st_send_goodcrc_ack               ),
    .prl_rx_st_send_goodcrc_ack_result        (prl_rx_st_send_goodcrc_ack_result        ),
                                                                                        
    //prl hdrst construct signal        
    .prl_hdrst_send_req                       (prl_hdrst_send_req                       ),
    .prl_hdrst_send_ack                       (prl_hdrst_send_ack                       ),
    .prl_hdrst_send_ack_result                (prl_hdrst_send_ack_result                )
);



prl_rx_message_if prl_rx_message_if(
    .clk                                      (clk                                      ),
    .rst_n                                    (rst_n_mix                                ),
                                                                                        
    .pl2pe_rx_en                              (pl2pe_rx_en                              ),
    .pl2pe_rx_type                            (pl2pe_rx_type                            ),
    .pl2pe_rx_sop_type                        (pl2pe_rx_sop_type                        ),
    .pl2pe_rx_info                            (pl2pe_rx_info                            ),
                                                                                        
    .prl_rx_st_inform_pe_en                   (prl_rx_st_inform_pe_en                   ),
                                                                                        
    //prl rx parser header
    .prl_rx_parser_message_type               (prl_rx_parser_message_type               ),
    .prl_rx_parser_sop_type                   (prl_rx_parser_sop_type                   ),
    .prl_rx_parser_header_type                (prl_rx_parser_header_type                ),

    //bist message
    .prl_rx_parser_data_bist_mode             (prl_rx_parser_data_bist_mode             ),

    //request message
    .prl_rx_parser_data_request_pdo_type      (prl_rx_parser_data_request_pdo_type      ),
    .prl_rx_parser_data_request_op_cur        (prl_rx_parser_data_request_op_cur        ),
    .prl_rx_parser_data_request_max_op_cur    (prl_rx_parser_data_request_max_op_cur    ),
    .prl_rx_parser_data_request_mismatch_flag (prl_rx_parser_data_request_mismatch_flag )

);



prl_rx_message_path prl_rx_message_path(
    .clk                                      (clk                                      ),
    .rst_n                                    (rst_n_mix                                ),
                                                                                        
    .phy2prl_rx_packet_en                     (phy2prl_rx_packet_en                     ),
    .phy2prl_rx_packet_type                   (phy2prl_rx_packet_type                   ),
    .phy2prl_rx_packet_done                   (phy2prl_rx_packet_done                   ),
    .phy2prl_rx_packet_result                 (phy2prl_rx_packet_result                 ),
                                                                                        
    .phy2prl_rx_payload                       (phy2prl_rx_payload                       ),
    .phy2prl_rx_payload_req                   (phy2prl_rx_payload_req                   ),
                                                                                        
    .prl_tx_if_source_cap_table_select        (prl_tx_if_source_cap_table_select        ),
                                                                                        
    .prl_rx_parser_message_req                (prl_rx_parser_message_req                ),
    //.prl_rx_parser_message_result             (prl_rx_parser_message_result             ),
    .prl_rx_parser_message_type               (prl_rx_parser_message_type               ),
    .prl_rx_parser_sop_type                   (prl_rx_parser_sop_type                   ),
    .prl_rx_parser_header_type                (prl_rx_parser_header_type                ),
    .prl_rx_parser_message_id                 (prl_rx_parser_message_id                 ),
                                                                                        
    .prl_rx_parser_message_ex_data_size       (prl_rx_parser_message_ex_data_size       ),

    //bist message
    .prl_rx_parser_data_bist_mode             (prl_rx_parser_data_bist_mode             ),
  
    //request message
    .prl_rx_parser_data_request_pdo_type      (prl_rx_parser_data_request_pdo_type      ),
    .prl_rx_parser_data_request_op_cur        (prl_rx_parser_data_request_op_cur        ),
    .prl_rx_parser_data_request_max_op_cur    (prl_rx_parser_data_request_max_op_cur    ),
    .prl_rx_parser_data_request_mismatch_flag (prl_rx_parser_data_request_mismatch_flag )

);

endmodule




