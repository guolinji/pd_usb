`timescale 1ns / 1ps
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
module policy_engine (
    clk,
    rst_n,
    );

input     clk;
input     rst_n;

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
localparam PE_SRC_GET_SINK_CAP              = 4'd11
localparam PE_SRC_WAIT_NEW_CAPABILITIES     = 4'd12
localparam PE_SRC_SEND_SOFT_RESET           = 4'd13
localparam PE_SRC_SOFT_RESET                = 4'd14
localparam NA_STATE                         = 4'd15

localparam NUM_HARDRESETCOUNT               = 2
localparam NUM_CAPSCOUNT                    = 50

reg       [3:0] pe_cur_st;
reg       [3:0] pe_nxt_st;
reg       [3:0] entry_state;
reg       [3:0] exit_state;

//========================================================================================
//========================================================================================
//              transmit result
//========================================================================================
//========================================================================================
assign without_goodcrc              = PL2PE_Tx_ack && PL2PE_Tx_result[1:0]!=2'b00;

//========================================================================================
//========================================================================================
//              receive message
//========================================================================================
//========================================================================================
assign request_message_received     = PL2PE_Rx_en && PL2PE_Rx_type[6:5]==2'b0 && PL2PE_Rx_type[4:0]==5'bxxx;

//========================================================================================
//========================================================================================
//              pd source port state machine
//========================================================================================
//========================================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pe_cur_st <= PE_SRC_STARTUP;
    end
    else begin
        pe_cur_st <= pe_nxt_st;
    end
end

always @(*) begin
    pe_nxt_st = pe_cur_st;

    case(pe_cur_st)
    PE_SRC_STARTUP: begin
        //Entry: reset the CapsCounter
        //       reset the protocol Layer
        if (PL2PE_reset_done & DPM2PE_attached) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end
    end
    PE_SRC_DISCOVERY: begin
        //Entry: start SourceCapabilityTimer
        if (SourceCapabilityTimer_timeout && CapsCounter<=NUM_CAPSCOUNT) begin
            pe_nxt_st = PE_SRC_SEND_CAPABILITIES;
        end else if (NoResponseTimer_timeout && HardResetCounter>NUM_HARDRESETCOUNT) begin
            pe_nxt_st = PE_SRC_DISABLED;
        end
    end
    PE_SRC_SEND_CAPABILITIES: begin
        //Entry: request PL to send Source_Capabilities
        //       incr CapsCounter
//  If a GoodCRC Message is received then the Policy Engine Shall:
// Stop the NoResponseTimer .
// Reset the HardResetCounter and CapsCounter to zero. Note that the HardResetCounter Shall only be set to zero in this state and at power up; its value Shall be maintained during a Hard Reset.
// Initialize and run the SenderResponseTimer.
        if (request_message_received) begin
            pe_nxt_st = PE_SRC_NEGOTIATE_CAPABILITY;
        end else if (without_goodcrc) begin
            pe_nxt_st = PE_SRC_DISCOVERY;
        end else if (SenderResponseTimer_timeout) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end
    end
    PE_SRC_NEGOTIATE_CAPABILITY: begin
        //Entry: PE2DPM_evaluate_req
        if (PE2DPM_evaluate_result[0] && PE2DPM_evaluate_result[2:1]==2'b0) begin
            pe_nxt_st = PE_SRC_TRANSITION_SUPPLY;
        end else if (PE2DPM_evaluate_result[0]) begin
            pe_nxt_st = PE_SRC_CAPABILITY_RESPONSE;
        end
    end
    PE_SRC_TRANSITION_SUPPLY: begin
        //Entry: send Accept message
        //       PE2DPM_trans_supply
        if (DPM2PE_trans_finish) begin
            pe_nxt_st = PE_SRC_READY;
        end else if (???A Protocol Error occurs) begin
            pe_nxt_st = PE_SRC_HARD_RESET;
        end
        //Exit: send PS_RDY message
    end
    PE_SRC_READY: begin
    end
    PE_SRC_DISABLED: begin
        // only responsive to Hard Reset Signaling
    end
    PE_SRC_CAPABILITY_RESPONSE: begin
    end
    PE_SRC_HARD_RESET: begin
        //Entry: request PHY generation of HardReset Signaling
        //       start PSHardResetTimer
        //       incr HardResetCounter
        if (PSHardResetTimer_timeout) begin
            pe_nxt_st = PE_SRC_TRANSITION_TO_DEFAULT;
        end
    end
    PE_SRC_HARD_RESET_RECEIVED: begin
    end
    PE_SRC_TRANSITION_TO_DEFAULT: begin
        //Entry: 
       //       indicate to the Device Policy Manager that the power supply Shall Hard Reset (see Section 7.1.5)
       //       request a reset of the local hardware
       //       request the Device Policy Manager to set the Port Data Role to DFP and turn off VCONN.
        if (DPM2PE_trans_finish) begin
            pe_nxt_st = PE_SRC_STARTUP;
        end
        //Exit: 
       //      request the Device Policy Manager to turn on VCONN
       //      initialize and run the NoResponseTimer. Note that the NoResponseTimer Shall continue to run in every state until it is stopped or times out.
       //      inform the Protocol Layer that the Hard Reset is complete.
    end
    PE_SRC_GET_SINK_CAP: begin
    end
    PE_SRC_WAIT_NEW_CAPABILITIES: begin
    end
    PE_SRC_SEND_SOFT_RESET: begin
    end
    PE_SRC_SOFT_RESET: begin
    end
    default;
    endcase
end

// entry state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        entry_state <= NA_State;
    end else if (pe_cur_st != pe_nxt_st) begin
        entry_state <= pe_nxt_st;
    end else begin
        entry_state <= NA_State;
end

// exist state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        exit_state <= NA_State;
    end else if (pe_cur_st != pe_nxt_st) begin
        exit_state <= pe_cur_st;
    end else begin
        exit_state <= NA_State;
end

endmodule

