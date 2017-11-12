`include "timescale.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:21 05/21/2017
// Design Name: 
// Module Name:    policy_engine
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
module dpe_top (
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

    pe2pl_reset_req,

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
    pe2pl_hard_reset_ack
);

input              clk;
input              rst_n;

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

output             pe2pl_reset_req;

//pe&pl tx signal
input              pl2pe_tx_ack;
input   [ 1:0]     pl2pe_tx_result;

output             pe2pl_tx_en;
output  [ 6:0]     pe2pl_tx_type;
output  [ 2:0]     pe2pl_tx_sop_type;
output  [ 4:0]     pe2pl_tx_info;
output  [35:0]     pe2pl_tx_ex_info;

output             pe2pl_tx_ams_begin;
output             pe2pl_tx_ams_end;

output             pe2pl_tx_bist_carrier_mode;

//pe&pl rx signal
input              pl2pe_rx_en;
input   [ 6:0]     pl2pe_rx_type;
input   [ 2:0]     pl2pe_rx_sop_type;
input   [22:0]     pl2pe_rx_info;

input              pl2pe_hard_reset_req;
output             pe2pl_hard_reset_ack;


parameter  FREQ_MULTI_300K                  = 8;
parameter  WIDTH_MULTI_300K                 = 3;

localparam PE_SRC_STARTUP                   = 5'd00;
localparam PE_SRC_DISCOVERY                 = 5'd01;
localparam PE_SRC_DISABLED                  = 5'd02;
localparam PE_SRC_SEND_CAPABILITIES         = 5'd03;
localparam PE_SRC_NEGOTIATE_CAPABILITY      = 5'd04;
localparam PE_SRC_TRANSITION_SUPPLY         = 5'd05;
localparam PE_SRC_TRANSITION_TO_DEFAULT     = 5'd06;
localparam PE_SRC_CAPABILITY_RESPONSE       = 5'd07;
localparam PE_SRC_READY                     = 5'd08;
localparam PE_SRC_SEND_SOURCE_ALERT         = 5'd09;
localparam PE_SRC_GIVE_PPS_STATUS           = 5'd10;
localparam PE_BIST_CARRIER_MODE             = 5'd11;
localparam PE_BIST_TEST_DATA                = 5'd12;
localparam PE_SRC_HARD_RESET                = 5'd13;
localparam PE_SRC_HARD_RESET_RECEIVED       = 5'd14;
localparam PE_SRC_SEND_SOFT_RESET           = 5'd15;
localparam PE_SRC_SOFT_RESET                = 5'd16;
localparam NA_STATE                         = 5'h1f;

localparam NUM_HARDRESETCOUNT               = 2'd2;


wire            tx_accept_msg;
wire            tx_ps_rdy_msg;
wire            tx_reject_msg;
wire            tx_soft_reset_msg;
wire            tx_srccap_msg;
wire            tx_alert_msg;
wire            tx_pps_status_msg;
wire            tx_hard_reset;

reg     [ 0:0]  pe2pl_tx_en;
reg     [ 6:0]  pe2pl_tx_type;
reg     [ 2:0]  pe2pl_tx_sop_type;
reg     [ 4:0]  pe2pl_tx_info;
reg     [35:0]  pe2pl_tx_ex_info;

reg     [ 0:0]  pl2pe_tx_ack_reg;
reg     [ 1:0]  pl2pe_tx_result_reg;

wire            tx_fail;
wire            tx_pass;

reg     [ 0:0]  pe2pl_reset_req;
reg     [ 2:0]  pe2pl_reset_d;
wire            pl2pe_reset_done;
wire            pe2pl_tx_bist_carrier_mode;

wire            accept_msg_received;
wire            reject_msg_received;
wire            get_source_cap_msg_received;
wire            soft_reset_msg_received;
wire            get_pps_status_msg_received;
wire            request_msg_received;
wire            bist_msg_received;
wire            hard_reset_sig_received;
wire            bist_carrier_mode;
wire            bist_test_data;
wire            request_can_met;
wire            request_cannot_met;

reg     [ 0:0]  pl2pe_rx_en_reg;
reg     [ 6:0]  pl2pe_rx_type_reg;
reg     [ 2:0]  pl2pe_rx_sop_type_reg;
reg     [22:0]  pl2pe_rx_info_reg;


reg     [ 0:0]  pe2ana_trans_en;
reg     [ 0:0]  pe2ana_trans_pdotype;
reg     [ 9:0]  pe2ana_trans_voltage;
reg     [ 9:0]  pe2ana_trans_current;


reg       [4:0] pe_cur_st;
reg       [4:0] pe_nxt_st;
reg       [4:0] pe_cur_st_d;
reg       [4:0] entry_state;
reg       [4:0] exit_state;

reg       [0:0] explicit_contract;

wire            pe2pl_tx_ams_begin;
wire            pe2pl_tx_ams_end;

reg       [1:0] HardResetCounter;

wire            SenderResponseTimer_start;
wire            SenderResponseTimer_stop;
wire            SenderResponseTimer_out;
wire            SourceCapabilityTimer_start;
wire            SourceCapabilityTimer_stop;
wire            SourceCapabilityTimer_out;
wire            NoResponseTimer_start;
wire            NoResponseTimer_stop;
wire            NoResponseTimer_out;
wire            BISTContModeTimer_start;
wire            BISTContModeTimer_stop;
wire            BISTContModeTimer_out;
wire            PSHardResetTimer_start;
wire            PSHardResetTimer_stop;
wire            PSHardResetTimer_out;
wire            SourcePPSCommTimer_start;
wire            SourcePPSCommTimer_stop;
wire            SourcePPSCommTimer_out;
wire            fst_msg_of_ams_sent;

//========================================================================================
//========================================================================================
//              transmit result
//========================================================================================
//========================================================================================
//Control Message	
//	Accept
//	GoodCRC
//	PS_RDY
//	Reject
//	Soft_Reset
//	
//Data Message	
//	Source_Capabilities
//	Alert
//	
//Extended Messages	
//	PPS_Status
//	
assign tx_accept_msg            = (entry_state==PE_SRC_TRANSITION_SUPPLY) || ((pe_cur_st==PE_SRC_SOFT_RESET) && pl2pe_reset_done);
assign tx_ps_rdy_msg            = (exit_state ==PE_SRC_TRANSITION_SUPPLY);
assign tx_reject_msg            = (entry_state==PE_SRC_CAPABILITY_RESPONSE);
assign tx_soft_reset_msg        = (pe_cur_st==PE_SRC_SOFT_RESET) && pl2pe_reset_done;

assign tx_srccap_msg            = (entry_state==PE_SRC_SEND_CAPABILITIES);
assign tx_alert_msg             = (entry_state==PE_SRC_SEND_SOURCE_ALERT);

assign tx_pps_status_msg        = (entry_state==PE_SRC_GIVE_PPS_STATUS);

assign tx_hard_reset            = (entry_state==PE_SRC_HARD_RESET);


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pe2pl_tx_en         <= 1'b0;
        pe2pl_tx_type       <= 7'b0;
        pe2pl_tx_sop_type   <= 3'b0;
        pe2pl_tx_info       <= 5'b0;
        pe2pl_tx_ex_info    <= 36'b0;
    //********************//
    // Control Message
    //********************//
    end else if (tx_accept_msg) begin   // Tx Accept Message
        pe2pl_tx_en         <= 1'b1;
        pe2pl_tx_type       <= {2'b00, 5'b0_0011};
    end else if (tx_ps_rdy_msg) begin   // Tx PS_RDY Message
        pe2pl_tx_en         <= 1'b1;
        pe2pl_tx_type       <= {2'b00, 5'b0_0110};
    end else if (tx_reject_msg) begin   // Tx Reject Message
        pe2pl_tx_en         <= 1'b1;
        pe2pl_tx_type       <= {2'b00, 5'b0_0100};
    end else if (tx_soft_reset_msg) begin   // Tx Soft_Reset Message
        pe2pl_tx_en         <= 1'b1;
        pe2pl_tx_type       <= {2'b00, 5'b0_1101};
    //********************//
    // Data Message
    //********************//
    end else if (tx_srccap_msg) begin   // Tx Source_Capabilities Message
        pe2pl_tx_en         <= 1'b1;
        pe2pl_tx_type       <= {2'b01, 5'b0_0001};
        pe2pl_tx_info       <= {i_support_5amps,i_pdo_selidx};
    end else if (tx_alert_msg) begin   // Tx Alert Message
        pe2pl_tx_en         <= 1'b1;
        pe2pl_tx_type       <= {2'b01, 5'b0_0110};
    //********************//
    // Extended Message
    //********************//
    end else if (tx_pps_status_msg) begin   // Tx PPS_Status Message
        pe2pl_tx_en         <= 1'b1;
        pe2pl_tx_type       <= {2'b10, 5'b0_1100};
        pe2pl_tx_ex_info    <= {ana2pe_pps_voltage, ana2pe_pps_current, ana2pe_pps_ptf, ana2pe_pps_omf, 9'd4}; // {output Voltage, output Current, PTF, OMF, Extended Msg Data size}
    //********************//
    // Hard Reset
    //********************//
    end else if (tx_hard_reset) begin   // Tx Hard Reset
        pe2pl_tx_en         <= 1'b1;
        pe2pl_tx_sop_type   <= 3'b011;
    end else begin
        pe2pl_tx_en         <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pl2pe_tx_ack_reg            <= 1'b0;
        pl2pe_tx_result_reg         <= 2'b0;
    end else if (pl2pe_tx_ack) begin
        pl2pe_tx_ack_reg            <= 1'b1;
        pl2pe_tx_result_reg         <= pl2pe_tx_result;
    end else begin
        pl2pe_tx_ack_reg            <= 1'b0;
    end
end

assign tx_fail                  = pl2pe_tx_ack_reg && (pl2pe_tx_result_reg[1:0]!=2'b00);
assign tx_pass                  = pl2pe_tx_ack_reg && (pl2pe_tx_result_reg[1:0]==2'b00);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pe2pl_reset_req <= 1'b0;
    end else if ((entry_state==PE_SRC_READY) || (entry_state==PE_SRC_SOFT_RESET)) begin
        pe2pl_reset_req <= 1'b1;
    end else if (pl2pe_reset_done) begin
        pe2pl_reset_req <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pe2pl_reset_d <= 3'b1;
    end else begin
        pe2pl_reset_d <= {pe2pl_reset_d[1:0], pe2pl_reset_req};
    end
end

// PL reset will finish in 2 cycle;
assign pl2pe_reset_done = pe2pl_reset_d[2];

assign pe2pl_tx_bist_carrier_mode = (pe_cur_st == PE_BIST_CARRIER_MODE);

//========================================================================================
//========================================================================================
//              receive message
//========================================================================================
//========================================================================================
//Control Message	
//	Accept
//	Get_PPS_Status
//	Get_Source_Cap
//	GoodCRC
//	Reject
//	Soft_Reset
//	
//Data Message	
//	Request
//	BIST
//	
//           pl2pe_rx_en;
//[ 2:0]     pl2pe_rx_result;
//[ 6:0]     pl2pe_rx_type;
//[ 2:0]     pl2pe_rx_sop_type;
//[22:0]     pl2pe_rx_info;
assign accept_msg_received          = pl2pe_rx_en_reg && pl2pe_rx_type_reg[6:5]==2'b0 && pl2pe_rx_type_reg[4:0]==5'b0_0011;
assign reject_msg_received          = pl2pe_rx_en_reg && pl2pe_rx_type_reg[6:5]==2'b0 && pl2pe_rx_type_reg[4:0]==5'b0_0100;
assign get_source_cap_msg_received  = pl2pe_rx_en_reg && pl2pe_rx_type_reg[6:5]==2'b0 && pl2pe_rx_type_reg[4:0]==5'b0_0111;
assign soft_reset_msg_received      = pl2pe_rx_en_reg && pl2pe_rx_type_reg[6:5]==2'b0 && pl2pe_rx_type_reg[4:0]==5'b0_1101;
assign get_pps_status_msg_received  = pl2pe_rx_en_reg && pl2pe_rx_type_reg[6:5]==2'b0 && pl2pe_rx_type_reg[4:0]==5'b1_0100;

assign request_msg_received         = pl2pe_rx_en_reg && pl2pe_rx_type_reg[6:5]==2'b1 && pl2pe_rx_type_reg[4:0]==5'b0_0010;
assign bist_msg_received            = pl2pe_rx_en_reg && pl2pe_rx_type_reg[6:5]==2'b1 && pl2pe_rx_type_reg[4:0]==5'b0_0011;

assign hard_reset_sig_received      = pl2pe_rx_en_reg && pl2pe_rx_sop_type_reg==3'd3;
assign bist_carrier_mode            = ~pl2pe_rx_info_reg[22];
assign bist_test_data               = pl2pe_rx_info_reg[22];

assign request_can_met              = ~pl2pe_rx_info_reg[20];
assign request_cannot_met           = pl2pe_rx_info_reg[20];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pl2pe_rx_en_reg             <= 1'b0;
        pl2pe_rx_type_reg           <= 7'b0;
        pl2pe_rx_sop_type_reg       <= 3'b0;
        pl2pe_rx_info_reg           <= 23'b0;
    end else if (pl2pe_rx_en) begin
        pl2pe_rx_en_reg             <= 1'b1;
        pl2pe_rx_type_reg           <= pl2pe_rx_type;
        pl2pe_rx_sop_type_reg       <= pl2pe_rx_sop_type;
        pl2pe_rx_info_reg           <= pl2pe_rx_info;
    end else begin
        pl2pe_rx_en_reg             <= 1'b0;
    end
end


//========================================================================================
//========================================================================================
//              analog interface
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pe2ana_trans_en         <= 1'b0;
        pe2ana_trans_pdotype    <= 1'b0;
        pe2ana_trans_voltage    <= 10'd100; // 100*50mV = 5V
        pe2ana_trans_current    <= 10'd300; // 300*10mA = 3A
    end else if (entry_state==PE_SRC_TRANSITION_TO_DEFAULT) begin
        pe2ana_trans_en         <= 1'b1;
        pe2ana_trans_pdotype    <= 1'b0;
        pe2ana_trans_voltage    <= 10'd100; // 100*50mV = 5V
        pe2ana_trans_current    <= 10'd300; // 300*10mA = 3A
    end else if (entry_state==PE_SRC_TRANSITION_SUPPLY) begin
        pe2ana_trans_en         <= 1'b1;
        pe2ana_trans_pdotype    <= pl2pe_rx_info_reg[21];
        pe2ana_trans_voltage    <= pl2pe_rx_info_reg[19:10];
        pe2ana_trans_current    <= pl2pe_rx_info_reg[9:0];
    end else if (ana2pe_trans_finish) begin
        pe2ana_trans_en         <= 1'b0;
    end
end

//========================================================================================
//========================================================================================
//              pd source port state machine
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pe_cur_st <= PE_SRC_STARTUP;
    end else begin
        pe_cur_st <= ana2pe_attached ? pe_nxt_st : PE_SRC_STARTUP;
    end
end

always @(*) begin
    pe_nxt_st = pe_cur_st;

    case(pe_cur_st)
    PE_SRC_STARTUP: begin
        //Entry: reset the protocol Layer
        //Shall remain in this state until a plug is Attached
        if (pl2pe_reset_done) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end
    end
    PE_SRC_DISCOVERY: begin
        //Entry: start SourceCapabilityTimer
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (SourceCapabilityTimer_out) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (NoResponseTimer_out && HardResetCounter>NUM_HARDRESETCOUNT) begin
            pe_nxt_st = PE_SRC_DISABLED;
        end
    end
    PE_SRC_DISABLED: begin
        // supply default power and unresponsive to PD messaging
        // but not to Hard Reset Signaling
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end
    end
    PE_SRC_SEND_CAPABILITIES: begin
        //Entry: request PL to send Source_Capabilities
        //If a GoodCRC Message is received then the Policy Engine Shall:
        //      Stop the NoResponseTimer.
        //      Reset the HardResetCounter to zero. Note that the HardResetCounter Shall only be set to zero in this state and at power up;
        //      its value Shall be maintained during a Hard Reset.
        //      Initialize and run the SenderResponseTimer.
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (request_msg_received) begin
            pe_nxt_st = PE_SRC_NEGOTIATE_CAPABILITY;
        end else if (tx_fail) begin
            pe_nxt_st = PE_SRC_DISCOVERY;
        end else if (SenderResponseTimer_out) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end else if (NoResponseTimer_out && HardResetCounter>NUM_HARDRESETCOUNT) begin
            pe_nxt_st = PE_SRC_DISABLED;
        end
    end
    PE_SRC_NEGOTIATE_CAPABILITY: begin
        //Entry: evaluate_req
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (request_can_met) begin
            pe_nxt_st = PE_SRC_TRANSITION_SUPPLY; // request can be met
        end else if (request_cannot_met) begin
            pe_nxt_st = PE_SRC_CAPABILITY_RESPONSE; // request cannot be met
        end
    end
    PE_SRC_TRANSITION_SUPPLY: begin
        //Entry: send Accept message
        //       pe2ana_trans_en
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (ana2pe_trans_finish) begin
            pe_nxt_st = PE_SRC_READY;
        end else if (tx_fail) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end
        //Exit: send PS_RDY message
    end
    PE_SRC_TRANSITION_TO_DEFAULT: begin
        //Entry: 
        //       indicate to the Device Policy Manager that the power supply Shall Hard Reset (see Section 7.1.5)
        //       request a reset of the local hardware
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (ana2pe_trans_finish) begin
            pe_nxt_st = PE_SRC_STARTUP;
        end
        //Exit: 
        //      initialize and run the NoResponseTimer. Note that the NoResponseTimer Shall continue to run in every state until it is stopped or times out.
        //      inform the Protocol Layer that the Hard Reset is complete.
    end
    PE_SRC_CAPABILITY_RESPONSE: begin
        //Entry: 
        //       send Reject message
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (explicit_contract & tx_pass) begin
            // there is an Explicit Contract and
            // A Reject Message has been sent
            pe_nxt_st = PE_SRC_READY;
        end
    end
    PE_SRC_READY: begin
        //Entry: 
        //       notify PL of the end of AMS
        //          --    if it is the result of Protocol Error that has not caused
        //          --    a Soft Reset, then do not notify since there is a Message
        //          --    to be processed
        //       initialize and run SourcePPSCommTimer if the current Explicit Contract is for a PPS APDO
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (request_msg_received) begin
            pe_nxt_st = PE_SRC_NEGOTIATE_CAPABILITY;
        end else if (get_source_cap_msg_received) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (SourcePPSCommTimer_out) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end else if (ana2pe_alert) begin
            pe_nxt_st = PE_SRC_SEND_SOURCE_ALERT;
        end else if (get_pps_status_msg_received) begin
            pe_nxt_st = PE_SRC_GIVE_PPS_STATUS;
        end else if (bist_msg_received & bist_carrier_mode) begin
            pe_nxt_st = PE_BIST_CARRIER_MODE;
        end else if (bist_msg_received & bist_test_data) begin
            pe_nxt_st = PE_BIST_TEST_DATA;
        end
        //Exit: 
        //      notify PL that the first Message in an AMS will follow if the source is initiating an AMS
    end
    PE_SRC_SEND_SOURCE_ALERT: begin
        //Entry: 
        //       send Alert message
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (tx_pass) begin
            pe_nxt_st = PE_SRC_READY;
        end
    end
    PE_SRC_GIVE_PPS_STATUS: begin
        //Entry: 
        //       request the present Source PPS status and send PPS_Status message
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (tx_pass) begin
            pe_nxt_st = PE_SRC_READY;
        end
    end
    PE_BIST_CARRIER_MODE: begin
        //Entry: 
        //       tell PL to go to BIST Carrier Mode
        //       initialize and run BISTContModeTimer
        if (BISTContModeTimer_out) begin
            pe_nxt_st = PE_SRC_TRANSITION_TO_DEFAULT;
        end
    end
    PE_BIST_TEST_DATA: begin
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end
    end
    PE_SRC_HARD_RESET: begin
        //Entry: request PHY generation of HardReset Signaling
        //       start PSHardResetTimer
        //       incr HardResetCounter
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (PSHardResetTimer_out) begin
            pe_nxt_st = PE_SRC_TRANSITION_TO_DEFAULT;
        end
    end
    PE_SRC_HARD_RESET_RECEIVED: begin
        //Info: entered from any state when Hard Reset Signaling is detected
        //Entry: 
        //       start PSHardResetTimer
        if (PSHardResetTimer_out) begin
            pe_nxt_st = PE_SRC_TRANSITION_TO_DEFAULT;
        end
    end
    PE_SRC_SOFT_RESET: begin
        //Info: entered from any state when a Soft_Reset Message is received from PL
        //Entry: 
        //       shall reset the PL and request the PL to send an Accept Message
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (tx_pass) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (tx_fail) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end
    end
    PE_SRC_SEND_SOFT_RESET: begin
        //Info: entered from any state when a Protocol Error is detected by PL during a Non-interruptible AMS
        //or a Message has not been sent after retries to the Sink.
        //The main exceptions to this rule are when:
        //        1. in PE_SRC_SEND_CAPABILITIES, there is a Source_Capabilities Message
        //        sending failure and the source is not presently attached
        //        2. the voltage is in transition due to a New Explicit Contract
        //        being negotiated. In this case a Hard Reset will be generated
        //Note that Protocol Errors occurring in the following situations
        //shall not lead to a Soft Reset, but shall result in a transition to the PE_SRC_READY:
        //        1. Protocol Errors occurring during Interruptible AMS
        //        2. the first message in any AMS sequence has not yet been sent. 
        //        i.e. an unexpeted Message is received instead of the expected GoodCRC message response.
        //Entry: 
        //       request PL to perform a Soft Reset, then send a Soft_Reset Message to the sink
        //       initialize and run the SenderResponseTimer
        if (hard_reset_sig_received) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (accept_msg_received) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (SenderResponseTimer_out | tx_fail) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end
    end
    default;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pe_cur_st_d <= PE_SRC_STARTUP;
    end else begin
        pe_cur_st_d <= pe_cur_st;
    end
end

// entry state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        entry_state <= NA_STATE;
    end else if (pe_cur_st != pe_cur_st_d) begin
        entry_state <= pe_cur_st;
    end else begin
        entry_state <= NA_STATE;
    end
end

// exit state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        exit_state <= NA_STATE;
    end else if (pe_cur_st != pe_nxt_st) begin
        exit_state <= pe_cur_st;
    end else begin
        exit_state <= NA_STATE;
    end
end


//========================================================================================
//              Explicit Contract
//========================================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        explicit_contract       <= 1'b0;
    end else if (entry_state==PE_SRC_STARTUP) begin
        explicit_contract       <= 1'b0;
    end else if ((pe_cur_st==PE_SRC_TRANSITION_SUPPLY) && (pe_nxt_st==PE_SRC_READY)) begin
        explicit_contract       <= 1'b1;
    end
end

//========================================================================================
//              AMS begin/end
//========================================================================================
assign fst_msg_of_ams_sent = 1'b1;
assign pe2pl_tx_ams_begin = (exit_state ==PE_SRC_READY) || (exit_state == PE_SRC_STARTUP);
assign pe2pl_tx_ams_end   = (entry_state==PE_SRC_READY) && (fst_msg_of_ams_sent);

//========================================================================================
//              Counters
//========================================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        HardResetCounter <= 2'h0;
    end else if ((pe_cur_st==PE_SRC_SEND_CAPABILITIES) && tx_pass) begin
        HardResetCounter <= 2'h0;
    end else if (entry_state==PE_SRC_HARD_RESET) begin
        HardResetCounter <= HardResetCounter + 2'h1;
    end
end

//========================================================================================
//              Timers
//========================================================================================
//                          min         max
//SenderResponseTimer       24ms        30ms
//SourceCapabilityTimer     100ms       200ms
//NoResponseTimer           4.5s        5.5s
//BISTContModeTimer         30ms        60ms
//PSHardResetTimer          25ms        35ms
//SourcePPSCommTimer                    15s

assign SenderResponseTimer_start = (entry_state==PE_SRC_SEND_CAPABILITIES || entry_state==PE_SRC_SEND_SOFT_RESET);
assign SenderResponseTimer_stop  = (exit_state ==PE_SRC_SEND_CAPABILITIES || exit_state ==PE_SRC_SEND_SOFT_RESET);
dpe_timer #(.VALUE(8000*FREQ_MULTI_300K),.WIDTH(13+WIDTH_MULTI_300K)) U_SenderResponseTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (SenderResponseTimer_start)
    ,.stop      (SenderResponseTimer_stop)
    ,.timeout   (SenderResponseTimer_out)
);

assign SourceCapabilityTimer_start = (entry_state==PE_SRC_DISCOVERY);
assign SourceCapabilityTimer_stop  = (exit_state ==PE_SRC_DISCOVERY);
dpe_timer #(.VALUE(45000*FREQ_MULTI_300K) ,.WIDTH(16+WIDTH_MULTI_300K)) U_SourceCapabilityTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (SourceCapabilityTimer_start)
    ,.stop      (SourceCapabilityTimer_stop)
    ,.timeout   (SourceCapabilityTimer_out)
);

assign NoResponseTimer_start = (exit_state==PE_SRC_TRANSITION_TO_DEFAULT);
assign NoResponseTimer_stop  = ((pe_cur_st==PE_SRC_SEND_CAPABILITIES) && tx_pass);
dpe_timer #(.VALUE(1515000*FREQ_MULTI_300K) ,.WIDTH(21+WIDTH_MULTI_300K)) U_NoResponseTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (NoResponseTimer_start)
    ,.stop      (NoResponseTimer_stop)
    ,.timeout   (NoResponseTimer_out)
);

assign BISTContModeTimer_start = (entry_state==PE_BIST_CARRIER_MODE);
assign BISTContModeTimer_stop  = (exit_state ==PE_BIST_CARRIER_MODE);
dpe_timer #(.VALUE(13000*FREQ_MULTI_300K) ,.WIDTH(14+WIDTH_MULTI_300K)) U_BISTContModeTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (BISTContModeTimer_start)
    ,.stop      (BISTContModeTimer_stop)
    ,.timeout   (BISTContModeTimer_out)
);

assign PSHardResetTimer_start = (entry_state==PE_SRC_HARD_RESET || entry_state==PE_SRC_HARD_RESET_RECEIVED);
assign PSHardResetTimer_stop  = (exit_state ==PE_SRC_HARD_RESET || exit_state ==PE_SRC_HARD_RESET_RECEIVED);
dpe_timer #(.VALUE(9000*FREQ_MULTI_300K) ,.WIDTH(14+WIDTH_MULTI_300K)) U_PSHardResetTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (PSHardResetTimer_start)
    ,.stop      (PSHardResetTimer_stop)
    ,.timeout   (PSHardResetTimer_out)
);

assign SourcePPSCommTimer_start = (entry_state==PE_SRC_READY) && explicit_contract && (ana2pe_trans_finish&&pl2pe_rx_info_reg[21]);
assign SourcePPSCommTimer_stop  = (exit_state ==PE_SRC_READY);
dpe_timer #(.VALUE(4500000*FREQ_MULTI_300K) ,.WIDTH(23+WIDTH_MULTI_300K)) U_SourcePPSCommTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (SourcePPSCommTimer_start)
    ,.stop      (SourcePPSCommTimer_stop)
    ,.timeout   (SourcePPSCommTimer_out)
);

endmodule

//       safe_5v


