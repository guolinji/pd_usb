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
module dpe_timer (
    clk,
    rst_n,
    start,
    stop,
    timeout
);

input              clk;
input              rst_n;
input              start;
input              stop;
output             timeout;

parameter VALUE    = 20;
parameter WIDTH    = 5;

reg [WIDTH-1 : 0]   timer_cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        timer_cnt <= WIDTH'b0;
    end else if (stop) begin
        timer_cnt <= WIDTH'b0;
    end else if (start) begin
        timer_cnt <= WIDTH'b1;
    end else if (timer_cnt==VALUE) begin
        timer_cnt <= timer_cnt;
    end else if (|timer_cnt) begin
        timer_cnt <= timer_cnt + WIDTH'b1;
    end
end

assign timeout = timer_cnt==VALUE;

endmodule
