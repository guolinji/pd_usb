 `include "timescale.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:22:44 05/21/2017 
// Design Name: 
// Module Name:    crc32 
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
module phy_crc32(
    clk,
    rst_n,

    crc_data_in,
    crc_data_en,
    crc_data_last,

    crc_out_fail,
    crc_out
    );

input     clk;
input     rst_n;

input     [3:0] crc_data_in;        //the 4 bits data for crc calculaiton 
input     crc_data_en;              //the valid flag for crc data
input     crc_data_last;            //the last flag for crc data

output    crc_out_fail;             //the flag for crc fail
output    [31:0] crc_out;           //the crc result output 

integer   i;

reg       crc_out_en;
reg       crc_out_fail;
reg       [31:0] crc_out;



reg       [3:0] crc_data_en_keep;   
reg       [31:0] crc_reg;
wire      crc_bit_in_pre;

assign    crc_bit_in_pre =
                         	crc_data_en_keep[0] ?  (crc_data_in[0] ^ crc_reg[31]) :
                         	crc_data_en_keep[1] ?  (crc_data_in[1] ^ crc_reg[31]) :
                         	crc_data_en_keep[2] ?  (crc_data_in[2] ^ crc_reg[31]) :
                         	crc_data_en_keep[3] ?  (crc_data_in[3] ^ crc_reg[31]) : 1'b0 ;

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              crc_data_en_keep <= 4'h0;
       end
       else  begin
              crc_data_en_keep <= {crc_data_en_keep[2:0], (crc_data_en && !crc_data_last)};
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              crc_reg <= 32'hffff_ffff;
       end
       else  if(crc_out_en) begin
              crc_reg <= 32'hffff_ffff;
       end
       else  if(crc_data_en_keep != 4'h0) begin
              crc_reg[ 0] <=               crc_bit_in_pre;
              crc_reg[ 1] <= crc_reg[ 0] ^ crc_bit_in_pre;
              crc_reg[ 2] <= crc_reg[ 1] ^ crc_bit_in_pre;
              crc_reg[ 3] <= crc_reg[ 2];
              crc_reg[ 4] <= crc_reg[ 3] ^ crc_bit_in_pre;
              crc_reg[ 5] <= crc_reg[ 4] ^ crc_bit_in_pre;
              crc_reg[ 6] <= crc_reg[ 5];
              crc_reg[ 7] <= crc_reg[ 6] ^ crc_bit_in_pre;
              crc_reg[ 8] <= crc_reg[ 7] ^ crc_bit_in_pre;
              crc_reg[ 9] <= crc_reg[ 8];
              crc_reg[10] <= crc_reg[ 9] ^ crc_bit_in_pre;
              crc_reg[11] <= crc_reg[10] ^ crc_bit_in_pre;
              crc_reg[12] <= crc_reg[11] ^ crc_bit_in_pre;
              crc_reg[13] <= crc_reg[12];
              crc_reg[14] <= crc_reg[13];
              crc_reg[15] <= crc_reg[14];
              crc_reg[16] <= crc_reg[15] ^ crc_bit_in_pre;
              crc_reg[17] <= crc_reg[16];
              crc_reg[18] <= crc_reg[17];
              crc_reg[19] <= crc_reg[18];
              crc_reg[20] <= crc_reg[19];
              crc_reg[21] <= crc_reg[20];
              crc_reg[22] <= crc_reg[21] ^ crc_bit_in_pre;
              crc_reg[23] <= crc_reg[22] ^ crc_bit_in_pre;
              crc_reg[24] <= crc_reg[23];
              crc_reg[25] <= crc_reg[24];
              crc_reg[26] <= crc_reg[25] ^ crc_bit_in_pre;
              crc_reg[27] <= crc_reg[26];
              crc_reg[28] <= crc_reg[27];
              crc_reg[29] <= crc_reg[28];
              crc_reg[30] <= crc_reg[29];
              crc_reg[31] <= crc_reg[30];
       end
end

always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
              crc_out_en  <= 1'h0;
              crc_out_fail <= 1'h0;
              crc_out      <= 32'h0;
       end
       else if(crc_data_en && crc_data_last) begin
              crc_out_en <= 1'h1;

          if(crc_reg == 32'hc704_dd7b) begin
              crc_out_fail <= 1'h0;
          end
          else begin
              crc_out_fail <= 1'h1;
          end

          for(i=0;i<32;i=i+1) begin
              crc_out[i]    <= !crc_reg[31-i];
          end
       end
       else begin
              crc_out_en   <= 1'h0;
       end
end

endmodule


