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

`define RAM_BYTE_WIDTH 32
`define RAM_ADR_WIDTH 8 

module decoder
(
	mclk, 
	rst, 
	srst, 
	valid_in, 
	symbol0, 
	symbol1, 
	pattern, 
	tb_dir,
	
	bit_out, 
	valid_out,
	tb_dir_o,
	
	traceback_error,
	filo_error,
	tbdir_mod_err
);
input mclk, rst, srst, valid_in;
input[`Bit_Width-1:0] symbol0, symbol1;
input[`SYMBOLS_NUM-1:0] pattern;     // punctured pattern      
input tb_dir;
output bit_out, valid_out, tb_dir_o;
output traceback_error, filo_error, tbdir_mod_err;

wire valid_decs;
wire[`V-1:0] dec0, dec1, dec2, dec3, dec4, dec5, dec6, dec7, dec8, dec9, dec10, dec11, dec12, dec13, dec14, dec15, dec16, dec17, dec18, dec19, dec20, dec21, dec22, dec23, dec24, dec25, dec26, dec27, dec28, dec29, dec30, dec31;
wire wr_en, rd_en, en_filo_in;
wire[`V-1:0] filo_in;
wire[`RAM_BYTE_WIDTH - 1:0] wr_data, rd_data;
wire[`RAM_ADR_WIDTH - 1:0] wr_adr, rd_adr;

wire tb_dir_vit, tb_dir_trace;
wire filo_fls, filo_clr;

vit vit_i
(
	.mclk(mclk), 
	.rst(rst), 
	.valid(valid_in), 
	.symbol0(symbol0), 
	.symbol1(symbol1), 
	.pattern(pattern),
	.tb_dir(tb_dir), 
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
	.valid_decs(valid_decs),
	.tb_dir_vit(tb_dir_vit)
);

dirtraback traback_i
(
	.clk(mclk), 
	.rst(rst), 
	.srst(srst), 
	.tb_dir_i(tb_dir_vit),
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
	// memory control
	.wr_en(wr_en), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data), 
	.rd_adr(rd_adr), 
	// filo control
	.tb_dir_o(tb_dir_trace),
    .filo_clr(filo_clr),
    .filo_fls(filo_fls),
	.en_filo_in(en_filo_in), 
	.filo_in(filo_in),
	.traceback_error(traceback_error)
);

sync_mem #(32,8) sync_mem0
(
	.clk(mclk), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.wr_en(wr_en), 
	.rd_adr(rd_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data)
);

centrofilo filo_i
(
	.clk(mclk), 
	.rst(rst), 
	.srst(srst),
	.tb_dir_i(tb_dir_trace), 
	.filo_clr(filo_clr),
	.filo_fls(filo_fls),
	.en_filo_in(en_filo_in), 
	.filo_in(filo_in), 
	.valid_out(valid_out),
	.filo_out(bit_out), 
	.tb_dir_filo(tb_dir_o),
	.filo_error(filo_error)
);

tbdir_mod tbdir_mod_i
(
    .clk(mclk),
    .rst(rst),
    .srst(srst),
    .tb_dir(tb_dir),
    .tb_dir_filo(tb_dir_o),
    .tbdir_mod_err(tbdir_mod_err)
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
