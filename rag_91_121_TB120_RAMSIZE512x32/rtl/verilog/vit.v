// version1.3
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




// B=1, symbol_num=2, W=4, V=1, U=1
// para_polys=91 121
// Support Direct Traceback, Synchronous Ram

`include "glb_def.v"

module vit
(
    mclk, 
    rst,
    tb_dir, 
    valid, 
    symbol0, 
    symbol1, 
    pattern, 
    dec0, 
    dec1, 
    dec2, 
    dec3, 
    dec4, 
    dec5, 
    dec6, 
    dec7, 
    dec8, 
    dec9, 
    dec10, 
    dec11, 
    dec12, 
    dec13, 
    dec14, 
    dec15, 
    dec16, 
    dec17, 
    dec18, 
    dec19, 
    dec20, 
    dec21, 
    dec22, 
    dec23, 
    dec24, 
    dec25, 
    dec26, 
    dec27, 
    dec28, 
    dec29, 
    dec30, 
    dec31, 
    valid_decs,
    tb_dir_vit
);
input mclk, rst, valid;
input tb_dir;
input[`Bit_Width-1:0] symbol0, symbol1;
input[`SYMBOLS_NUM-1:0] pattern;
output[`V-1:0] dec0, dec1, dec2, dec3, dec4, dec5, dec6, dec7, dec8, dec9, dec10, dec11, dec12, dec13, dec14, dec15, dec16, dec17, dec18, dec19, dec20, dec21, dec22, dec23, dec24, dec25, dec26, dec27, dec28, dec29, dec30, dec31;
output valid_decs;
output tb_dir_vit;

wire[`V-1:0] pe0_dec0, pe0_dec1;
wire[`V-1:0] pe1_dec0, pe1_dec1;
wire[`V-1:0] pe2_dec0, pe2_dec1;
wire[`V-1:0] pe3_dec0, pe3_dec1;
wire[`V-1:0] pe4_dec0, pe4_dec1;
wire[`V-1:0] pe5_dec0, pe5_dec1;
wire[`V-1:0] pe6_dec0, pe6_dec1;
wire[`V-1:0] pe7_dec0, pe7_dec1;
wire[`V-1:0] pe8_dec0, pe8_dec1;
wire[`V-1:0] pe9_dec0, pe9_dec1;
wire[`V-1:0] pe10_dec0, pe10_dec1;
wire[`V-1:0] pe11_dec0, pe11_dec1;
wire[`V-1:0] pe12_dec0, pe12_dec1;
wire[`V-1:0] pe13_dec0, pe13_dec1;
wire[`V-1:0] pe14_dec0, pe14_dec1;
wire[`V-1:0] pe15_dec0, pe15_dec1;

wire valid_slice;
wire[`U-1:0] slice;					// u canot be less than one
wire[`Bit_Width-1:0] reg_symbol0, reg_symbol1;
wire[`SYMBOLS_NUM-1:0] reg_pattern;           
wire[`V-1:0] shift_cnt;       
wire[`U-1:0] adr0_shift, adr1_shift;            

wire[`SM_Width-1:0] pe0_in_sm0, pe0_in_sm1, pe0_out_sm0, pe0_out_sm1;  
wire[`SM_Width-1:0] pe1_in_sm0, pe1_in_sm1, pe1_out_sm0, pe1_out_sm1;  
wire[`SM_Width-1:0] pe2_in_sm0, pe2_in_sm1, pe2_out_sm0, pe2_out_sm1;  
wire[`SM_Width-1:0] pe3_in_sm0, pe3_in_sm1, pe3_out_sm0, pe3_out_sm1;  
wire[`SM_Width-1:0] pe4_in_sm0, pe4_in_sm1, pe4_out_sm0, pe4_out_sm1;  
wire[`SM_Width-1:0] pe5_in_sm0, pe5_in_sm1, pe5_out_sm0, pe5_out_sm1;  
wire[`SM_Width-1:0] pe6_in_sm0, pe6_in_sm1, pe6_out_sm0, pe6_out_sm1;  
wire[`SM_Width-1:0] pe7_in_sm0, pe7_in_sm1, pe7_out_sm0, pe7_out_sm1;  
wire[`SM_Width-1:0] pe8_in_sm0, pe8_in_sm1, pe8_out_sm0, pe8_out_sm1;  
wire[`SM_Width-1:0] pe9_in_sm0, pe9_in_sm1, pe9_out_sm0, pe9_out_sm1;  
wire[`SM_Width-1:0] pe10_in_sm0, pe10_in_sm1, pe10_out_sm0, pe10_out_sm1;  
wire[`SM_Width-1:0] pe11_in_sm0, pe11_in_sm1, pe11_out_sm0, pe11_out_sm1;  
wire[`SM_Width-1:0] pe12_in_sm0, pe12_in_sm1, pe12_out_sm0, pe12_out_sm1;  
wire[`SM_Width-1:0] pe13_in_sm0, pe13_in_sm1, pe13_out_sm0, pe13_out_sm1;  
wire[`SM_Width-1:0] pe14_in_sm0, pe14_in_sm1, pe14_out_sm0, pe14_out_sm1;  
wire[`SM_Width-1:0] pe15_in_sm0, pe15_in_sm1, pe15_out_sm0, pe15_out_sm1;  
assign dec0=pe0_dec0;	 
assign dec1=pe0_dec1;	 
assign dec2=pe1_dec0;	 
assign dec3=pe1_dec1;	 
assign dec4=pe2_dec0;	 
assign dec5=pe2_dec1;	 
assign dec6=pe3_dec0;	 
assign dec7=pe3_dec1;	 
assign dec8=pe4_dec0;	 
assign dec9=pe4_dec1;	 
assign dec10=pe5_dec0;	 
assign dec11=pe5_dec1;	 
assign dec12=pe6_dec0;	 
assign dec13=pe6_dec1;	 
assign dec14=pe7_dec0;	 
assign dec15=pe7_dec1;	 
assign dec16=pe8_dec0;	 
assign dec17=pe8_dec1;	 
assign dec18=pe9_dec0;	 
assign dec19=pe9_dec1;	 
assign dec20=pe10_dec0;	 
assign dec21=pe10_dec1;	 
assign dec22=pe11_dec0;	 
assign dec23=pe11_dec1;	 
assign dec24=pe12_dec0;	 
assign dec25=pe12_dec1;	 
assign dec26=pe13_dec0;	 
assign dec27=pe13_dec1;	 
assign dec28=pe14_dec0;	 
assign dec29=pe14_dec1;	 
assign dec30=pe15_dec0;	 
assign dec31=pe15_dec1;	 
assign pe0_in_sm0=pe0_out_sm0;             
assign pe0_in_sm1=pe1_out_sm0;             
assign pe1_in_sm0=pe2_out_sm0;             
assign pe1_in_sm1=pe3_out_sm0;             
assign pe2_in_sm0=pe4_out_sm0;             
assign pe2_in_sm1=pe5_out_sm0;             
assign pe3_in_sm0=pe6_out_sm0;             
assign pe3_in_sm1=pe7_out_sm0;             
assign pe4_in_sm0=pe8_out_sm0;             
assign pe4_in_sm1=pe9_out_sm0;             
assign pe5_in_sm0=pe10_out_sm0;             
assign pe5_in_sm1=pe11_out_sm0;             
assign pe6_in_sm0=pe12_out_sm0;             
assign pe6_in_sm1=pe13_out_sm0;             
assign pe7_in_sm0=pe14_out_sm0;             
assign pe7_in_sm1=pe15_out_sm0;             
assign pe8_in_sm0=pe0_out_sm1;             
assign pe8_in_sm1=pe1_out_sm1;             
assign pe9_in_sm0=pe2_out_sm1;             
assign pe9_in_sm1=pe3_out_sm1;             
assign pe10_in_sm0=pe4_out_sm1;             
assign pe10_in_sm1=pe5_out_sm1;             
assign pe11_in_sm0=pe6_out_sm1;             
assign pe11_in_sm1=pe7_out_sm1;             
assign pe12_in_sm0=pe8_out_sm1;             
assign pe12_in_sm1=pe9_out_sm1;             
assign pe13_in_sm0=pe10_out_sm1;             
assign pe13_in_sm1=pe11_out_sm1;             
assign pe14_in_sm0=pe12_out_sm1;             
assign pe14_in_sm1=pe13_out_sm1;             
assign pe15_in_sm0=pe14_out_sm1;             
assign pe15_in_sm1=pe15_out_sm1;             

pe #(0) pe_0(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe0_in_sm0), .in_sm1(pe0_in_sm1), .out_sm0(pe0_out_sm0), .out_sm1(pe0_out_sm1), .dec0(pe0_dec0), .dec1(pe0_dec1));
pe #(1) pe_1(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe1_in_sm0), .in_sm1(pe1_in_sm1), .out_sm0(pe1_out_sm0), .out_sm1(pe1_out_sm1), .dec0(pe1_dec0), .dec1(pe1_dec1));
pe #(2) pe_2(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe2_in_sm0), .in_sm1(pe2_in_sm1), .out_sm0(pe2_out_sm0), .out_sm1(pe2_out_sm1), .dec0(pe2_dec0), .dec1(pe2_dec1));
pe #(3) pe_3(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe3_in_sm0), .in_sm1(pe3_in_sm1), .out_sm0(pe3_out_sm0), .out_sm1(pe3_out_sm1), .dec0(pe3_dec0), .dec1(pe3_dec1));
pe #(4) pe_4(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe4_in_sm0), .in_sm1(pe4_in_sm1), .out_sm0(pe4_out_sm0), .out_sm1(pe4_out_sm1), .dec0(pe4_dec0), .dec1(pe4_dec1));
pe #(5) pe_5(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe5_in_sm0), .in_sm1(pe5_in_sm1), .out_sm0(pe5_out_sm0), .out_sm1(pe5_out_sm1), .dec0(pe5_dec0), .dec1(pe5_dec1));
pe #(6) pe_6(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe6_in_sm0), .in_sm1(pe6_in_sm1), .out_sm0(pe6_out_sm0), .out_sm1(pe6_out_sm1), .dec0(pe6_dec0), .dec1(pe6_dec1));
pe #(7) pe_7(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe7_in_sm0), .in_sm1(pe7_in_sm1), .out_sm0(pe7_out_sm0), .out_sm1(pe7_out_sm1), .dec0(pe7_dec0), .dec1(pe7_dec1));
pe #(8) pe_8(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe8_in_sm0), .in_sm1(pe8_in_sm1), .out_sm0(pe8_out_sm0), .out_sm1(pe8_out_sm1), .dec0(pe8_dec0), .dec1(pe8_dec1));
pe #(9) pe_9(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe9_in_sm0), .in_sm1(pe9_in_sm1), .out_sm0(pe9_out_sm0), .out_sm1(pe9_out_sm1), .dec0(pe9_dec0), .dec1(pe9_dec1));
pe #(10) pe_10(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe10_in_sm0), .in_sm1(pe10_in_sm1), .out_sm0(pe10_out_sm0), .out_sm1(pe10_out_sm1), .dec0(pe10_dec0), .dec1(pe10_dec1));
pe #(11) pe_11(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe11_in_sm0), .in_sm1(pe11_in_sm1), .out_sm0(pe11_out_sm0), .out_sm1(pe11_out_sm1), .dec0(pe11_dec0), .dec1(pe11_dec1));
pe #(12) pe_12(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe12_in_sm0), .in_sm1(pe12_in_sm1), .out_sm0(pe12_out_sm0), .out_sm1(pe12_out_sm1), .dec0(pe12_dec0), .dec1(pe12_dec1));
pe #(13) pe_13(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe13_in_sm0), .in_sm1(pe13_in_sm1), .out_sm0(pe13_out_sm0), .out_sm1(pe13_out_sm1), .dec0(pe13_dec0), .dec1(pe13_dec1));
pe #(14) pe_14(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe14_in_sm0), .in_sm1(pe14_in_sm1), .out_sm0(pe14_out_sm0), .out_sm1(pe14_out_sm1), .dec0(pe14_dec0), .dec1(pe14_dec1));
pe #(15) pe_15(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .adr0_shift(adr0_shift), .adr1_shift(adr1_shift), .symbol0(reg_symbol0), .symbol1(reg_symbol1), .pattern(reg_pattern), .in_sm0(pe15_in_sm0), .in_sm1(pe15_in_sm1), .out_sm0(pe15_out_sm0), .out_sm1(pe15_out_sm1), .dec0(pe15_dec0), .dec1(pe15_dec1));		
ctrl ctrl_i
(
    .mclk(mclk), 
    .rst(rst), 
    .valid(valid),
    .tb_dir(tb_dir), 
    .symbol0(symbol0), 
    .symbol1(symbol1), 
    .pattern(pattern), 
    .valid_slice(valid_slice), 
    .slice(slice), 
    .shift_cnt(shift_cnt), 
    .adr0_shift(adr0_shift), 
    .adr1_shift(adr1_shift), 
    .reg_symbol0(reg_symbol0), 
    .reg_symbol1(reg_symbol1), 
    .reg_pattern(reg_pattern), 
    .tb_dir_vit(tb_dir_vit), 
    .valid_decs(valid_decs)
);
endmodule
