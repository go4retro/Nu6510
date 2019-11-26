`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:25:29 06/17/2018 
// Design Name: 
// Module Name:    Fake6510 
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
module Nu6510(input _reset,
              input clock,
              input r_w_6502,
              output r_w_6510,
              input [15:0]address_6502,
              output [15:0]address_6510,
              inout [7:0]data_6502,
              inout [7:0]data_6510,
              input aec,
              //input _rdy,
              inout [5:0]pio
             );
wire ce_pio;
wire ce_0000;
wire ce_0001;
reg [7:0]data_pio;
reg [7:0]ddr_pio;
wire [7:0]pio_out;
reg [7:0]data_6502_out;
reg [7:0]data_6510_out;

assign ce_pio =            (address_6502[15:1] == 0);
assign ce_0000 =           ce_pio & !address_6502[0];
assign ce_0001 =           ce_pio & address_6502[0];

assign address_6510 =      (aec & clock ? address_6502 : 16'bz);
assign r_w_6510 =          (aec & clock ? r_w_6502 : 'bz);
assign data_6502 =         data_6502_out;
assign data_6510 =         data_6510_out;
assign pio =               pio_out[5:0];

assign pio_out[7] =        (ddr_pio[7] ? data_pio[7] : 'bz);
assign pio_out[6] =        (ddr_pio[6] ? data_pio[6] : 'bz);
assign pio_out[5] =        (ddr_pio[5] ? data_pio[5] : 'bz);
assign pio_out[4] =        (ddr_pio[4] ? data_pio[4] : 'bz);
assign pio_out[3] =        (ddr_pio[3] ? data_pio[3] : 'bz);
assign pio_out[2] =        (ddr_pio[2] ? data_pio[2] : 'bz);
assign pio_out[1] =        (ddr_pio[1] ? data_pio[1] : 'bz);
assign pio_out[0] =        (ddr_pio[0] ? data_pio[0] : 'bz);

always @(*)
begin
   if(aec & !ce_pio & clock & !r_w_6502) // write cycle
   begin
      data_6510_out = data_6502;
      data_6502_out = 8'bz;
   end
   else if (aec & ce_pio & clock & !r_w_6502) // emulate no data on PIO write
   begin
      data_6510_out = 8'bz;
      data_6502_out = 8'bz;
   end
   else if (aec & ce_0000 & clock & r_w_6502) // read PIO
   begin
      data_6510_out = 8'bz;
      data_6502_out = pio_out;
   end
   else if (aec & ce_0001 & clock & r_w_6502) // read ddr
   begin
      data_6510_out = 8'bz;
      data_6502_out = ddr_pio;
   end
   else
   begin
      data_6510_out = 8'bz;
      data_6502_out = data_6510;
   end
end

always @(negedge clock, negedge _reset)
begin
   if(!_reset)
   begin
      ddr_pio <= 0;
      data_pio <= 0;
   end
   else if(!r_w_6502 & ce_0000)
   begin
      ddr_pio <= data_6502;
   end
   else if(!r_w_6502 & ce_0001)
   begin
      data_pio <= data_6502;
   end
end

endmodule
