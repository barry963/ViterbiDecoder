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

`define RAM_BYTE_WIDTH 32
`define RAM_ADR_WIDTH 10 

module vit_dec
(
	mclk, 
	rst, 
	srst, 
	valid_in, 
	symbol0, 
	symbol1, 
	pattern, 
	bit_out, 
	valid_out
);
input mclk, rst, srst, valid_in;
input[`Bit_Width-1:0] symbol0, symbol1;
input[`SYMBOLS_NUM-1:0] pattern;           //////////////////////////////////////////////
output bit_out, valid_out;

wire valid_decs;
wire[`V-1:0] dec0, dec1, dec2, dec3, dec4, dec5, dec6, dec7, dec8, dec9, dec10, dec11, dec12, dec13, dec14, dec15, dec16, dec17, dec18, dec19, dec20, dec21, dec22, dec23, dec24, dec25, dec26, dec27, dec28, dec29, dec30, dec31;
//wire[`SM_Width-1:0] sm0, sm1, sm2, sm3, sm4, sm5, sm6, sm7, sm8, sm9, sm10, sm11, sm12, sm13, sm14, sm15, sm16, sm17, sm18, sm19, sm20, sm21, sm22, sm23, sm24, sm25, sm26, sm27, sm28, sm29, sm30, sm31;
wire [`SM_Width*32-1:0] sm_list;
wire wr_en, rd_en, en_filo_in;
wire[`V-1:0] filo_in;
wire[`RAM_BYTE_WIDTH - 1:0] wr_data, rd_data;
wire[`RAM_ADR_WIDTH - 1:0] wr_adr, rd_adr;
wire en_sm_in;
vit vit_i
(
	.mclk(mclk), 
	.rst(rst), 
	.valid(valid_in), 
	.symbol0(symbol0), 
	.symbol1(symbol1), 
	.pattern(pattern), 
	.dec0(dec0), 
	.dec1(dec1), 
	.dec2(dec2), 
	.dec3(dec3), 
	.dec4(dec4), 
	.dec5(dec5), 
	.dec6(dec6), 
	.dec7(dec7), 
	.dec8(dec8), 
	.dec9(dec9), 
	.dec10(dec10), 
	.dec11(dec11), 
	.dec12(dec12), 
	.dec13(dec13), 
	.dec14(dec14), 
	.dec15(dec15), 
	.dec16(dec16), 
	.dec17(dec17), 
	.dec18(dec18), 
	.dec19(dec19), 
	.dec20(dec20), 
	.dec21(dec21), 
	.dec22(dec22), 
	.dec23(dec23), 
	.dec24(dec24), 
	.dec25(dec25), 
	.dec26(dec26), 
	.dec27(dec27), 
	.dec28(dec28), 
	.dec29(dec29), 
	.dec30(dec30), 
	.dec31(dec31), 
	.sm_list(sm_list),
	// .sm0(sm0), 
	// .sm1(sm1), 
	// .sm2(sm2), 
	// .sm3(sm3), 
	// .sm4(sm4), 
	// .sm5(sm5), 
	// .sm6(sm6), 
	// .sm7(sm7), 
	// .sm8(sm8), 
	// .sm9(sm9), 
	// .sm10(sm10), 
	// .sm11(sm11), 
	// .sm12(sm12), 
	// .sm13(sm13), 
	// .sm14(sm14), 
	// .sm15(sm15), 
	// .sm16(sm16), 
	// .sm17(sm17), 
	// .sm18(sm18), 
	// .sm19(sm19), 
	// .sm20(sm20), 
	// .sm21(sm21), 
	// .sm22(sm22), 
	// .sm23(sm23), 
	// .sm24(sm24), 
	// .sm25(sm25), 
	// .sm26(sm26), 
	// .sm27(sm27), 
	// .sm28(sm28), 
	// .sm29(sm29), 
	// .sm30(sm30), 
	// .sm31(sm31), 	
	.valid_decs(valid_decs)
);

traceback traback_i
(
	.clk(mclk), 
	.rst(rst), 
	.srst(srst), 
	.valid_in(valid_decs), 
	.dec0(dec0), 
	.dec1(dec1), 
	.dec2(dec2), 
	.dec3(dec3), 
	.dec4(dec4), 
	.dec5(dec5), 
	.dec6(dec6), 
	.dec7(dec7), 
	.dec8(dec8), 
	.dec9(dec9), 
	.dec10(dec10), 
	.dec11(dec11), 
	.dec12(dec12), 
	.dec13(dec13), 
	.dec14(dec14), 
	.dec15(dec15), 
	.dec16(dec16), 
	.dec17(dec17), 
	.dec18(dec18), 
	.dec19(dec19), 
	.dec20(dec20), 
	.dec21(dec21), 
	.dec22(dec22), 
	.dec23(dec23), 
	.dec24(dec24), 
	.dec25(dec25), 
	.dec26(dec26), 
	.dec27(dec27), 
	.dec28(dec28), 
	.dec29(dec29), 
	.dec30(dec30), 
	.dec31(dec31), 
	.sm_list(sm_list),
	// .sm0(sm0), 
	// .sm1(sm1), 
	// .sm2(sm2), 
	// .sm3(sm3), 
	// .sm4(sm4), 
	// .sm5(sm5), 
	// .sm6(sm6), 
	// .sm7(sm7), 
	// .sm8(sm8), 
	// .sm9(sm9), 
	// .sm10(sm10), 
	// .sm11(sm11), 
	// .sm12(sm12), 
	// .sm13(sm13), 
	// .sm14(sm14), 
	// .sm15(sm15), 
	// .sm16(sm16), 
	// .sm17(sm17), 
	// .sm18(sm18), 
	// .sm19(sm19), 
	// .sm20(sm20), 
	// .sm21(sm21), 
	// .sm22(sm22), 
	// .sm23(sm23), 
	// .sm24(sm24), 
	// .sm25(sm25), 
	// .sm26(sm26), 
	// .sm27(sm27), 
	// .sm28(sm28), 
	// .sm29(sm29), 
	// .sm30(sm30), 
	// .sm31(sm31), 	
	.wr_en(wr_en), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data), 
	.rd_adr(rd_adr), 
	.en_filo_in(en_filo_in), 
	.filo_in(filo_in)
);

sync_mem #(32,10) sync_mem0
(
	.clk(mclk), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.wr_en(wr_en), 
	.rd_adr(rd_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data)
);

filo filo_i
(
	.clk(mclk), 
	.rst(rst), 
	.en_filo_in(en_filo_in), 
	.filo_in(filo_in), 
	.en_filo_out(1'b1), 
	.filo_out(bit_out), 
	.valid_out(valid_out)
);

`ifdef DEBUG
////////////// for debug ////////////////////////////////////
integer f_debug, line;
initial
begin
    $display("DEBUG output file write is enabled.");
    line=0; 
	f_debug=$fopen(`DEBUG_OUT_FILE);
end
always @(posedge mclk)
begin
        if(valid_decs)
        begin
            $fwrite(f_debug,"%b\n",{dec0, dec1, dec2, dec3, dec4, dec5, dec6, dec7, dec8, dec9, dec10, dec11, dec12, dec13, dec14, dec15, dec16, dec17, dec18, dec19, dec20, dec21, dec22, dec23, dec24, dec25, dec26, dec27, dec28, dec29, dec30, dec31});
             line=line+1;
	     if((line%2) ==0)
             begin
                 $fwrite(f_debug,"\n");
             end
//             if(line%16==15)
//             begin
//                 $fwrite(f_debug,"\n");
//             end
        end
end
`endif
endmodule
