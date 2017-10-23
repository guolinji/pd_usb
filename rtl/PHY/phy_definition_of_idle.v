`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:22:44 05/21/2017 
// Design Name: 
// Module Name:    definition_of_idle 
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
module phy_definition_of_idle(
    clk,
    rst_n,

    phy_cc_signal,

    phy_definition_of_idle_en,
    phy_definition_of_idle_done,
    phy_definition_of_idle_result
    );

input     clk;
input     rst_n;

input     phy_cc_signal;        

input     phy_definition_of_idle_en;        
output    phy_definition_of_idle_done;        
output    phy_definition_of_idle_result;        

localparam CC_IDLE_PERIOD = 10'd30;
localparam CC_IDLE_LIMIT  = 3'd3;

wire      phy_definition_of_idle_cnt_done;
reg       [9:0] phy_definition_of_idle_cnt;

reg       cc_signal_dly1;
reg       cc_signal_dly2;
reg       cc_signal_dly3;
wire      cc_signal_trans_dege;
reg       [2:0] cc_signal_trans_dege_cnt;



always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              phy_definition_of_idle_cnt <= 10'h0;
       end
       else  if(phy_definition_of_idle_done) begin
              phy_definition_of_idle_cnt <= 10'h0;
       end
       else  if(phy_definition_of_idle_en) begin
              phy_definition_of_idle_cnt <= phy_definition_of_idle_cnt + 1'h1;
       end
end


assign  phy_definition_of_idle_cnt_done   = (phy_definition_of_idle_cnt == CC_IDLE_PERIOD);





always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              cc_signal_dly1 <= 1'b1;
              cc_signal_dly2 <= 1'b1;
              cc_signal_dly3 <= 1'b1;
       end
       else if(phy_definition_of_idle_en) begin
              cc_signal_dly1 <= phy_cc_signal;
              cc_signal_dly2 <= cc_signal_dly1;
              cc_signal_dly3 <= cc_signal_dly2;
       end
end


assign  cc_signal_trans_dege   = cc_signal_dly2 ^ cc_signal_dly3;


always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              cc_signal_trans_dege_cnt <= 3'h0;
       end
       else  if(phy_definition_of_idle_done) begin
              cc_signal_trans_dege_cnt <= 3'h0;
       end
       else  if(cc_signal_trans_dege && phy_definition_of_idle_en) begin
              cc_signal_trans_dege_cnt <= cc_signal_trans_dege_cnt + 1'h1;
       end
end



assign  phy_definition_of_idle_done     = phy_definition_of_idle_cnt_done || (cc_signal_trans_dege_cnt == 3'h7);
assign  phy_definition_of_idle_result   = (cc_signal_trans_dege_cnt < CC_IDLE_LIMIT);



endmodule


