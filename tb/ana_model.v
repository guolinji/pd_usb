`include "timescale.v"

module ana_model (
    clk,
    rst_n,
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
    ana2pe_alert
);

input              clk;
input              rst_n;

//analog&pe signal
input   [ 0:0]      pe2ana_trans_en;
input   [ 0:0]      pe2ana_trans_pdotype;
input   [ 9:0]      pe2ana_trans_voltage;
input   [ 9:0]      pe2ana_trans_current;
output  [ 0:0]      ana2pe_attached;
output  [ 0:0]      ana2pe_trans_finish;
output  [15:0]      ana2pe_pps_voltage;
output  [ 7:0]      ana2pe_pps_current;
output  [ 1:0]      ana2pe_pps_ptf;
output  [ 0:0]      ana2pe_pps_omf;
output  [ 0:0]      ana2pe_alert;

wire  [0:0]       ana2pe_attached;
wire  [15:0]      ana2pe_pps_voltage;
wire  [ 7:0]      ana2pe_pps_current;
wire  [ 1:0]      ana2pe_pps_ptf;
wire  [ 0:0]      ana2pe_pps_omf;

wire  [0:0]       ana2pe_alert;

reg   [0:0]       ana2pe_trans_finish;

assign ana2pe_attached = 1'b1;
assign ana2pe_pps_voltage = 16'd100;
assign ana2pe_pps_curreng = 16'd100;
assign ana2pe_pps_ptf = 2'b1;
assign ana2pe_pps_omf = 1'b1;

assign ana2pe_alert = 1'b0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ana2pe_trans_finish <= 1'b0;
    end else if (pe2ana_trans_en) begin
        ana2pe_trans_finish <= #100 1'b1;
    end else if (ana2pe_trans_finish) begin
        ana2pe_trans_finish <= 1'b0;
    end
end

endmodule

