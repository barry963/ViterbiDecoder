///////////////////////////////////////////////////////////////////
         //////                                    //////
///////////////////////////////////////////////////////////////////
///                                                             ///
/// This file is generated by Viterbi HDL Code Generator(VHCG)  ///
/// which is written by Mike Johnson at OpenCores.org  and      ///
/// distributed under GPL license.                              ///
///                                                             ///
/// If you have any advice,                                     ///
/// please email to jhonson.zhu@gmail.com                       ///
///                                                             ///
///////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////




`include "glb_def.v"

`define CONV_K		7

module encoder
(
	clock, 
	reset, 
	srst, 
	bit_in, 
	valid_in, 
	symbol0, 
	symbol1, 
	valid_out
);

input clock, reset, srst, bit_in, valid_in;
output symbol0, symbol1;
output valid_out;

reg symbol0, symbol1;
reg valid_out;
reg [`CONV_K-2:0] shift_reg;
wire [`CONV_K-1:0] cval;

always @ (posedge reset or posedge clock)
begin 
	if (reset)
		shift_reg <= {(`CONV_K-1){1'b0}};
	else if (srst) 
		shift_reg <= {(`CONV_K-1){1'b0}};
	else if (valid_in) 
		shift_reg <= {bit_in, shift_reg[`CONV_K-2:1]};
end 

assign cval = {bit_in, shift_reg};

always @ (posedge reset or posedge clock)
begin 
	if (reset)
	begin 
		symbol0 <= 1'b0;
		symbol1 <= 1'b0;
		valid_out <= 1'b0;
	end 
	else if (srst)
	begin 
		symbol0 <= 1'b0;
		symbol1 <= 1'b0;
		valid_out <= 1'b0;
	end 
	else if (valid_in) 
	begin 
		symbol0 <= cval[6]^cval[4]^cval[3]^cval[1]^cval[0];  // output symbol0
		symbol1 <= cval[6]^cval[5]^cval[4]^cval[3]^cval[0];  // output symbol1
		valid_out <= 1'b1;
	end 
	else 
		valid_out <= 1'b0;
end 
    
endmodule
