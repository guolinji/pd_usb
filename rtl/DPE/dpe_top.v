`include timescale.v
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

    //analog&pe signal
    
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

    //pe&pl rx signal
    pl2pe_rx_en,
    pl2pe_rx_result,
    pl2pe_rx_type,
    pl2pe_rx_sop_type,
    pl2pe_rx_info,

    //pe&pl reset handshake
    pl2pe_hard_reset_req,
    pe2pl_hard_reset_ack
);

input              clk;
input              rst_n;

//pe&pl tx signal
output             pe2pl_tx_en;
output    [ 6:0]   pe2pl_tx_type;
output    [ 2:0]   pe2pl_tx_sop_type;
output    [ 8:0]   pe2pl_tx_info;
output    [38:0]   pe2pl_tx_ex_info;
input              pl2pe_tx_ack;
input     [ 1:0]   pl2pe_tx_result;

output             pe2pl_tx_ams_begin;
output             pe2pl_tx_ams_end;

//pe&pl rx signal
input              pl2pe_rx_en;
input   [ 2:0]     pl2pe_rx_result;
input   [ 6:0]     pl2pe_rx_type;
input   [ 2:0]     pl2pe_rx_sop_type;
input   [65:0]     pl2pe_rx_info;

//pe&pl reset handshake
output             pe2pl_hard_reset_ack;
output             pe2pl_cable_reset_ack;
input              pl2pe_hard_reset_req;
input              pl2pe_cable_reset_req;

parameter  FREQ_MULTI_300K                  = 4;
parameter  WIDTH_MULTI_300K                 = 2;

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
localparam PE_SRC_HARD_RESET                = 5'd12;
localparam PE_SRC_HARD_RESET_RECEIVED       = 5'd13;
localparam PE_SRC_SEND_SOFT_RESET           = 5'd14;
localparam PE_SRC_SOFT_RESET                = 5'd15;
localparam NA_STATE                         = 5'h1f;

localparam NUM_HARDRESETCOUNT               = 2'd2;

reg       [4:0] pe_cur_st;
reg       [4:0] pe_nxt_st;
reg       [4:0] pe_cur_st_d;
reg       [4:0] entry_state;
reg       [4:0] exit_state;

//========================================================================================
//========================================================================================
//              transmit result
//========================================================================================
//========================================================================================
assign without_goodcrc              = pl2pe_tx_ack && pl2pe_tx_result[1:0]!=2'b00;

//========================================================================================
//========================================================================================
//              receive message
//========================================================================================
//========================================================================================
//           pl2pe_rx_en;
//[ 2:0]     pl2pe_rx_result;
//[ 6:0]     pl2pe_rx_type;
//[ 2:0]     pl2pe_rx_sop_type;
//[65:0]     pl2pe_rx_info;
assign request_msg_received     = pl2pe_rx_en && pl2pe_rx_type[6:5]==2'b0 && pl2pe_rx_type[4:0]==5'bxxx;

assign accept_msg_received          = pl2pe_rx_en_reg && pl2pe_rx_type_reg[6:5]==2'b0 && pl2pe_rx_type[4:0]==5'bxxx;
assign get_pps_status_msg_received  =
assign get_source_cap_msg_received  =
assign goodcrc_msg_received         =
assign reject_msg_received          =
assign soft_reset_msg_received      =

request_msg_received
bist_msg_received

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pl2pe_rx_en_reg             <= 1'b0;
        pl2pe_rx_result_reg         <= 3'b0;
        pl2pe_rx_type_reg           <= 7'b0;
        pl2pe_rx_sop_type_reg       <= 3'b0;
        pl2pe_rx_info_reg           <= 66'b0;
    end else if (pl2pe_rx_en) begin
        pl2pe_rx_en_reg             <= 1'b1;
        pl2pe_rx_result_reg         <= pl2pe_rx_result;
        pl2pe_rx_type_reg           <= pl2pe_rx_type;
        pl2pe_rx_sop_type_reg       <= pl2pe_rx_sop_type;
        pl2pe_rx_info_reg           <= pl2pe_rx_info;
    end else begin
        pl2pe_rx_en_reg             <= 1'b0;
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
        pe_cur_st <= pe_nxt_st;
    end
end

always @(*) begin
    pe_nxt_st = pe_cur_st;

    case(pe_cur_st)
    PE_SRC_STARTUP: begin
        //Entry: reset the protocol Layer
        //Shall remain in this state until a plug is Attached
        if (PL2PE_reset_done & DPM2PE_attached) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end
    end
    PE_SRC_DISCOVERY: begin
        //Entry: start SourceCapabilityTimer
        if (pl2pe_hard_reset_req) begin
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
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end
    end
    PE_SRC_SEND_CAPABILITIES: begin
        //Entry: request PL to send Source_Capabilities
        //If a GoodCRC Message is received then the Policy Engine Shall:
        //      Stop the NoResponseTimer .
        //      Reset the HardResetCounter to zero. Note that the HardResetCounter Shall only be set to zero in this state and at power up;
        //      its value Shall be maintained during a Hard Reset.
        //      Initialize and run the SenderResponseTimer.
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (request_msg_received) begin
            pe_nxt_st = PE_SRC_NEGOTIATE_CAPABILITY;
        end else if (without_goodcrc) begin
            pe_nxt_st = PE_SRC_DISCOVERY;
        end else if (SenderResponseTimer_out) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end else if (NoResponseTimer_out && HardResetCounter>NUM_HARDRESETCOUNT) begin
            pe_nxt_st = PE_SRC_DISABLED;
        end
    end
    PE_SRC_NEGOTIATE_CAPABILITY: begin
        //Entry: PE2DPM_evaluate_req
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (PE2DPM_evaluate_result[0] && PE2DPM_evaluate_result[2:1]==2'b0) begin
            pe_nxt_st = PE_SRC_TRANSITION_SUPPLY; // request can be met
        end else if (PE2DPM_evaluate_result[0]) begin
            pe_nxt_st = PE_SRC_CAPABILITY_RESPONSE; // request cannot be met
        end
    end
    PE_SRC_TRANSITION_SUPPLY: begin
        //Entry: send Accept message
        //       PE2DPM_trans_supply
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (DPM2PE_trans_finish) begin
            pe_nxt_st = PE_SRC_READY;
        end else if (???A Protocol Error occurs) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end
        //Exit: send PS_RDY message
    end
    PE_SRC_TRANSITION_TO_DEFAULT: begin
        //Entry: 
        //       indicate to the Device Policy Manager that the power supply Shall Hard Reset (see Section 7.1.5)
        //       request a reset of the local hardware
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (DPM2PE_trans_finish) begin
            pe_nxt_st = PE_SRC_STARTUP;
        end
        //Exit: 
        //      initialize and run the NoResponseTimer. Note that the NoResponseTimer Shall continue to run in every state until it is stopped or times out.
        //      inform the Protocol Layer that the Hard Reset is complete.
    end
    PE_SRC_CAPABILITY_RESPONSE: begin
        //Entry: 
        //       send Reject message
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (explicit_contract & reject_msg_sent) begin
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
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (request_msg_received) begin
            pe_nxt_st = PE_SRC_NEGOTIATE_CAPABILITY;
        end else if (get_source_cap_msg_received) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (sourcePPScommTimer_out) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end else if (DPM2PE_alert) begin
            pe_nxt_st = PE_SRC_SEND_SOURCE_ALERT;
        end else if (get_pps_status_msg_received) begin
            pe_nxt_st = PE_SRC_GIVE_PPS_STATUS;
        end else if (bist_msg_received & bist_carrier_mode & safe_5v) begin
            pe_nxt_st = PE_BIST_CARRIER_MODE;
        end
        //Exit: 
        //      notify PL that the first Message in an AMS will follow if the source is initiating an AMS
    end
    PE_SRC_SEND_SOURCE_ALERT: begin
        //Entry: 
        //       send Alert message
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (alert_msg_sent) begin
            pe_nxt_st = PE_SRC_READY;
        end
    end
    PE_SRC_GIVE_PPS_STATUS: begin
        //Entry: 
        //       request the present Source PPS status and send PPS_Status message
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (pps_status_msg_sent) begin
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
    PE_SRC_HARD_RESET: begin
        //Entry: request PHY generation of HardReset Signaling
        //       start PSHardResetTimer
        //       incr HardResetCounter
        if (pl2pe_hard_reset_req) begin
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
    PE_SRC_SEND_SOFT_RESET: begin
        //Info: entered from any state when a Protocol Error is detected by PL during a Non-interruptible AMS
        //or a Message has not been sent after retries to the Sink.
        //The main exceptions to this rule are when:
        //        1. in PE_SRC_SEND_CAPABILITIES, there is a Source_Capabilities Message
        //        sending failure and the source is not presently attached
        //        2. the voltage is in transition due to a New Explict Contract
        //        being negotiated. In this case a Hard Reset will be generated
        //Note that Protocol Errors occurring in the following situations
        //shall not lead to a Soft Reset, but shall result in a transition to the PE_SRC_READY:
        //        1. Protocol Errors occurring during Interruptible AMS
        //        2. the first message in any AMS sequence has not yet been sent. 
        //        i.e. an unexpeted Message is received instead of the expected GoodCRC message response.
        //Entry: 
        //       request PL to perform a Soft Reset, then send a Soft_Reset Message to the sink
        //       initialize and run the SenderResponseTimer
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_msg_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (accept_msg_received) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (SenderResponseTimer_out | ???PL indicates that a transmission error has occurred) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end
    end
    PE_SRC_SOFT_RESET: begin
        //Info: entered from any state when a Soft_Reset Message is received from PL
        //Entry: 
        //       shall reset the PL and request the PL to send an Accept Message
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (accept_msg_sent) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (???PL indicates that a transmission error has occurred) begin
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

// exit state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        exit_state <= NA_STATE;
    end else if (pe_cur_st != pe_nxt_st) begin
        exit_state <= pe_cur_st;
    end else begin
        exit_state <= NA_STATE;
end


//========================================================================================
//              AMS begin/end
//========================================================================================
pe2pl_tx_ams_begin
assign pe2pl_tx_ams_end = (entry_state==PE_SRC_READY) && (fst_msg_of_ams_sent);

//========================================================================================
//              Hard reset request
//========================================================================================
assign pe2pl_tx_hardreset = (entry_state==PE_SRC_HARD_RESET);

//========================================================================================
//              Counters
//========================================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        HardResetCounter <= 2'h0;
    end else if ((pe_cur_st==PE_SRC_SEND_CAPABILITIES) && goodcrc_msg_received) begin
        HardResetCounter <= 2'h0;
    end else if (entry_state==PE_SRC_HARD_RESET) begin
        HardResetCounter <= HardResetCounter + 1'h1;
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
dpe_timer #(.VALUE(8*FREQ_MULTI_300K),.WIDTH(4+WIDTH_MULTI_300K)) U_SenderResponseTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (SenderResponseTimer_start)
    ,.stop      (SenderResponseTimer_stop)
    ,.timeout   (SenderResponseTimer_out)
);

assign SourceCapabilityTimer_start = (entry_state==PE_SRC_DISCOVERY);
assign SourceCapabilityTimer_stop  = (exit_state ==PE_SRC_DISCOVERY);
dpe_timer #(.VALUE(45*FREQ_MULTI_300K) ,.WIDTH(6+WIDTH_MULTI_300K)) U_SourceCapabilityTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (SourceCapabilityTimer_start)
    ,.stop      (SourceCapabilityTimer_stop)
    ,.timeout   (SourceCapabilityTimer_out)
);

assign NoResponseTimer_start = (exit_state==PE_SRC_TRANSITION_TO_DEFAULT);
assign NoResponseTimer_stop  = ((pe_cur_st==PE_SRC_SEND_CAPABILITIES) && goodcrc_msg_received);
dpe_timer #(.VALUE(1515*FREQ_MULTI_300K) ,.WIDTH(11+WIDTH_MULTI_300K)) U_NoResponseTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (NoResponseTimer_start)
    ,.stop      (NoResponseTimer_stop)
    ,.timeout   (NoResponseTimer_out)
);

assign BISTContModeTimer_start = (entry_state==PE_BIST_CARRIER_MODE);
assign BISTContModeTimer_stop  = (exit_state ==PE_BIST_CARRIER_MODE);
dpe_timer #(.VALUE(13*FREQ_MULTI_300K) ,.WIDTH(4+WIDTH_MULTI_300K)) U_BISTContModeTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (BISTContModeTimer_start)
    ,.stop      (BISTContModeTimer_stop)
    ,.timeout   (BISTContModeTimer_out)
);

assign PSHardResetTimer_start = (entry_state==PE_SRC_HARD_RESET || entry_state==PE_SRC_HARD_RESET_RECEIVED);
assign PSHardResetTimer_stop  = (exit_state ==PE_SRC_HARD_RESET || exit_state ==PE_SRC_HARD_RESET_RECEIVED);
dpe_timer #(.VALUE(9*FREQ_MULTI_300K) ,.WIDTH(4+WIDTH_MULTI_300K)) U_PSHardResetTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (PSHardResetTimer_start)
    ,.stop      (PSHardResetTimer_stop)
    ,.timeout   (PSHardResetTimer_out)
);

assign SourcePPSCommTimer_start = (entry_state==PE_SRC_READY) && explicit_contract && pps_apdo;
assign SourcePPSCommTimer_stop  = (exit_state ==PE_SRC_READY);
dpe_timer #(.VALUE(4500*FREQ_MULTI_300K) ,.WIDTH(13+WIDTH_MULTI_300K)) U_SourcePPSCommTimer (
     .clk       (clk)
    ,.rst_n     (rst_n)
    ,.start     (SourcePPSCommTimer_start)
    ,.stop      (SourcePPSCommTimer_stop)
    ,.timeout   (SourcePPSCommTimer_out)
);

endmodule

//a plug is attached
