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

`define PE_SM_NUM 4                // 2^(`U+`V)
`define MAX_SLICE 2                // 2^(`U)

// just for test, not support state-set division.   
module smu
(
	mclk, 
	rst, 
	valid, 
	shift_cnt, 
	adr0_shift, adr1_shift, wr_sm0, wr_sm1, rd_sm0, rd_sm1);

input mclk, rst, valid;
input[`V-1:0] shift_cnt;      ///////// 
input[`U-1:0] adr0_shift, adr1_shift;             /////////////////////////////
input[`SM_Width-1:0] wr_sm0, wr_sm1;
output[`SM_Width-1:0] rd_sm0, rd_sm1;

reg[`SM_Width-1:0] regfbank0[`MAX_SLICE-1:0], regfbank1[`MAX_SLICE-1:0];
reg[`SM_Width-1:0] rd_sm0, rd_sm1;   ///////////////////////////////////////
reg[`SM_Width-1:0] wr_sm0_shift, wr_sm1_shift;
wire[`SM_Width-1:0] rd_sm0_shift, rd_sm1_shift;


integer i;

// for using banks in SMU, we should shift up the read state-metrics order by barriel shift
always @(shift_cnt or rd_sm0_shift or rd_sm1_shift)
begin
    case(shift_cnt)
	0:
		begin
			rd_sm0=rd_sm0_shift;
			rd_sm1=rd_sm1_shift;
		end
	1:
		begin
			rd_sm0=rd_sm1_shift;
			rd_sm1=rd_sm0_shift;
		end
	default:;
    endcase
end
// for using banks in SMU, we should shift down the write state-metrics order by barriel shift
always @(shift_cnt or wr_sm0 or wr_sm1)
begin
    case(shift_cnt)
	0:
		begin
			wr_sm0_shift=wr_sm0;
			wr_sm1_shift=wr_sm1;
		end
	1:
		begin
			wr_sm0_shift=wr_sm1;
			wr_sm1_shift=wr_sm0;
		end
	default:;
    endcase
end


always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin
        for(i=0;i<`MAX_SLICE;i=i+1)
			begin
				regfbank0[i]<='b0;
				regfbank1[i]<='b0;    
			end
		end
    else if(valid)
		begin
			regfbank0[adr0_shift]<=wr_sm0_shift;		//////////////////
			regfbank1[adr1_shift]<=wr_sm1_shift;		//////////////////
		end
end
assign rd_sm0_shift = regfbank0[adr0_shift];  ////////////////////////////
assign rd_sm1_shift = regfbank1[adr1_shift];  ////////////////////////////

endmodule
