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
    pl2pe_cable_reset_req,
    pe2pl_hard_reset_ack,
    pe2pl_cable_reset_ack,
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


localparam PE_SRC_STARTUP                   = 4'd0
localparam PE_SRC_DISCOVERY                 = 4'd1
localparam PE_SRC_SEND_CAPABILITIES         = 4'd2
localparam PE_SRC_NEGOTIATE_CAPABILITY      = 4'd3
localparam PE_SRC_TRANSITION_SUPPLY         = 4'd4
localparam PE_SRC_READY                     = 4'd5
localparam PE_SRC_DISABLED                  = 4'd6
localparam PE_SRC_CAPABILITY_RESPONSE       = 4'd7
localparam PE_SRC_HARD_RESET                = 4'd8
localparam PE_SRC_HARD_RESET_RECEIVED       = 4'd9
localparam PE_SRC_TRANSITION_TO_DEFAULT     = 4'd10
localparam PE_SRC_SEND_SOFT_RESET           = 4'd13
localparam PE_SRC_SOFT_RESET                = 4'd14
PE_SRC_SEND_SOURCE_ALERT
PE_SRC_GIVE_PPS_STATUS
PE_BIST_CARRIER_MODE
localparam NA_STATE                         = 4'd15

localparam NUM_HARDRESETCOUNT               = 2

reg       [3:0] pe_cur_st;
reg       [3:0] pe_nxt_st;
reg       [3:0] entry_state;
reg       [3:0] exit_state;

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
assign request_message_received     = pl2pe_rx_en && pl2pe_rx_type[6:5]==2'b0 && pl2pe_rx_type[4:0]==5'bxxx;

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
        end else if (soft_reset_message_received) begin
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
        end else if (soft_reset_message_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (request_message_received) begin
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
        end else if (soft_reset_message_received) begin
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
        end else if (soft_reset_message_received) begin
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
        end else if (soft_reset_message_received) begin
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
        end else if (soft_reset_message_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (explicit_contract & reject_message_sent) begin
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
        end else if (soft_reset_message_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (request_message_received) begin
            pe_nxt_st = PE_SRC_NEGOTIATE_CAPABILITY;
        end else if (get_source_cap_message_received) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (sourcePPScommTimer_out) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end else if (DPM2PE_alert) begin
            pe_nxt_st = PE_SRC_SEND_SOURCE_ALERT;
        end else if (get_pps_status_message_received) begin
            pe_nxt_st = PE_SRC_GIVE_PPS_STATUS;
        end else if (bist_message_received & bist_carrier_mode & safe_5v) begin
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
        end else if (soft_reset_message_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (alert_message_sent) begin
            pe_nxt_st = PE_SRC_READY;
        end
    end
    PE_SRC_GIVE_PPS_STATUS: begin
        //Entry: 
        //       request the present Source PPS status and send PPS_Status message
        if (pl2pe_hard_reset_req) begin
            pe_nxt_st = PE_SRC_HARD_RESET_RECEIVED;
        end else if (soft_reset_message_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (pps_status_message_sent) begin
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
        end else if (soft_reset_message_received) begin
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
        end else if (soft_reset_message_received) begin
            pe_nxt_st = PE_SRC_SOFT_RESET;
        end else if (accept_message_received) begin
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
        end else if (accept_message_sent) begin
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
        entry_state <= NA_State;
    end else if (pe_cur_st != pe_cur_st_d) begin
        entry_state <= pe_cur_st;
    end else begin
        entry_state <= NA_State;
end

// exit state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        exit_state <= NA_State;
    end else if (pe_cur_st != pe_nxt_st) begin
        exit_state <= pe_cur_st;
    end else begin
        exit_state <= NA_State;
end


//========================================================================================
//              Counters
//========================================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        HardResetCounter <= 2'h0;
    end else if ((pe_cur_st==PE_SRC_SEND_CAPABILITIES) & goodcrc_message_received) begin
        HardResetCounter <= 2'h0;
    end else if (entry_state==PE_SRC_HARD_RESET) begin
        HardResetCounter <= HardResetCounter + 1'h1;
    end
end

//========================================================================================
//              Timers
//========================================================================================



endmodule

//a plug is attached
//
//SourceCapabilityTimer
//SenderResponseTimer
//NoResponseTimer
//SourcePPSCommTimer
//BISTContModeTimer
//PSHardResetTimer
//
//HardResetCounter
