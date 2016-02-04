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
// the total number of all slices is 2^u
`define SLICE_0 `U'd0
`define SLICE_1 `U'd1
// let max_big_slice equal to b, then b*v is the minizal common multiple of (u+v) and v
`define BIG_SLICE_0 `BIG'd0
`define BIG_SLICE_1 `BIG'd1
//LAST_BIG_SLICE_AND_SLICE is (MAX_BIG_SLICE-1)*2^u - 1, which is {BIG_SLICE_LAST,SLICE_ZERO}
`define LAST_BIG_SLICE  `BIG'd1 //(MAX_BIG_SLICE-1), LAST_BIG_SLICE is the last big slice we want, equal to (b-1)
`define LAST_SLICE `U'd1 // The last slice

module ctrl
(
    mclk, 
    rst, 
    valid, 
    symbol0,
    symbol1, 
    pattern, 
    valid_slice, 
    slice, 
    shift_cnt, 
    adr0_shift,
    adr1_shift,
    reg_symbol0,
    reg_symbol1, 
    reg_pattern, 
    valid_decs
);

input mclk, rst, valid;
input[`Bit_Width-1:0] symbol0, symbol1;
input[`SYMBOLS_NUM-1:0] pattern;           //////////////////////////////////////////////

output[`U-1:0] slice;
output[`V-1:0] shift_cnt;      ///////// 
output[`U-1:0] adr0_shift, adr1_shift;             /////////////////////////////
output[`Bit_Width-1:0] reg_symbol0, reg_symbol1;
output[`SYMBOLS_NUM-1:0] reg_pattern;           //////////////////////////////////////////////
output valid_slice, valid_decs;

reg valid_slice;
reg[`U-1:0] slice;
reg[`V-1:0] shift_cnt;      
reg[`BIG-1:0] big_slice;
reg[`U-1:0] adr0_shift, adr1_shift;             /////////////////////////////

wire[`U-1:0] next_slice;
wire[`V-1:0] next_shift_cnt; 
reg[`BIG-1:0] next_big_slice;
wire[`BIG-1:0] tmp_next_big_slice;
wire[`U+`V-1:0] wire_adr0={next_slice,`V'd0}, wire_adr1={next_slice,`V'd1};
reg[`U-1:0] adr0, adr1;             /////////////////////////////
reg[`U-1:0] next_adr0_shift, next_adr1_shift;             /////////////////////////////

delayT #(`Bit_Width*`SYMBOLS_NUM+`SYMBOLS_NUM+1,1) delayT_symbols(.mclk(mclk), .rst(rst), .in({symbol0, symbol1, pattern, valid_slice}), .out({reg_symbol0, reg_symbol1, reg_pattern, valid_decs}));
 
always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin
        {big_slice,slice} <= {`LAST_BIG_SLICE,`LAST_SLICE};    /////////////////////
	valid_slice<=0;
	shift_cnt<=0;
	adr0_shift<=0;
	adr1_shift<=0;
    end
    else if(slice==`LAST_SLICE)
    begin
	if(valid)
	begin
		slice<=next_slice;
		big_slice<=next_big_slice;
		valid_slice<=1;
		shift_cnt<=next_shift_cnt;
		adr0_shift<=next_adr0_shift;
		adr1_shift<=next_adr1_shift;
		
	end
	else
	begin
		valid_slice<=0;
	end
    end
    else
    begin
    	slice<=next_slice;
	big_slice<=next_big_slice;
	shift_cnt<=next_shift_cnt;
	adr0_shift<=next_adr0_shift;
	adr1_shift<=next_adr1_shift;
	
    end
end
assign {tmp_next_big_slice,next_slice}={big_slice,slice}+1;

always @(tmp_next_big_slice or big_slice or slice)
begin
    if({big_slice,slice}=={`LAST_BIG_SLICE,`LAST_SLICE})           /////////////////////
    begin
        next_big_slice=`BIG_SLICE_0;
    end
    else
    begin
        next_big_slice=tmp_next_big_slice;
    end
end

// `U must larger than or equal to `V, and `U must be multiple of `V. Only under this
// condition, the following address generator is right.
// bank = state[v-1:0]+state[2v-1:v]+..+state[u-1:u-v], u must be the multiple of v.
assign next_shift_cnt=next_slice[0:0];

// get the first U bits (get x) of wire_adrs(after shift)
always @(next_big_slice or wire_adr0 or wire_adr1)
begin
    case(next_big_slice)
	0:
	begin 
	    adr0={wire_adr0[1]};
	    adr1={wire_adr1[1]};
	end
	default:
	begin 
	    adr0={wire_adr0[0]};
	    adr1={wire_adr1[0]};
	end
	endcase
end

// for using banks in SMU, we should shift down the read addresses order by barriel shift
always @(next_shift_cnt or adr0 or adr1)
begin
    case(next_shift_cnt)
	0:
	begin
	    next_adr0_shift=adr0;
	    next_adr1_shift=adr1;
	end
	default:
	begin
	    next_adr0_shift=adr1;
	    next_adr1_shift=adr0;
	end
	endcase
end

endmodule
