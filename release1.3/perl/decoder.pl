################################################################################
# ################################################################################  
# #                                                                              #  
# # Viterbi HDL Code Generator                                                   #  
# # Copyright (C) 2004  Sheng Zhu                                                #  
# #                                                                              #  
# # This program is free software; you can redistribute it and/or                #  
# # modify it under the terms of the GNU General Public License                  #  
# # as published by the Free Software Foundation; either version 2               #  
# # of the License, or (at your option) any later version.                       #  
# #                                                                              #  
# # This program is distributed in the hope that it will be useful,              #  
# # but WITHOUT ANY WARRANTY; without even the implied warranty of               #  
# # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                #  
# # GNU General Public License for more details.                                 #  
# #                                                                              #  
# # You should have received a copy of the GNU General Public License            #  
# # along with this program; if not, write to the Free Software                  #  
# # Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.  #  
# #                                                                              #  
# # If you have any problem, please email to me: jhonson.zhu@gmail.com           #  
# #                                                                              #  
# ################################################################################
################################################################################
#  version 1.2 based on version 1.1, updated date: 2008/12/18
#              change the signal "filo_out" to "bit_out"
#              rst signal adjusted
#              add srst signal by moti. This is a soft reset signal.
#              format adjust,
#              debug information
#  version 1.1 updated date: 2006/7

sub direct_tb_decoder()
{
my ($i,$j, $reg_valid_in, @reg_symbols, $reg_pattern); 

my @text=("

`include \"glb_def.v\"

`define RAM_BYTE_WIDTH $RAM_BYTE_WIDTH
`define RAM_ADR_WIDTH $RAM_ADR_WIDTH 

module decoder
(
	mclk, 
	rst, 
	srst, 
	valid_in, 
	", join(", 
	", @SYMBOLS), ", 
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
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;     // punctured pattern      
input tb_dir;
output bit_out, valid_out, tb_dir_o;
output traceback_error, filo_error, tbdir_mod_err;

wire valid_decs;
wire[`V-1:0] ", join(", ", @DECS_TBU), ";
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
	.", join(", 
	.", party(@SYMBOLS, @SYMBOLS)), ", 
	.pattern(pattern),
	.tb_dir(tb_dir), 
	.", join(", 
	.", party(@DECS_TBU, @DECS_TBU)), ", 
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
	.", join(", \n.", party(@DECS_TBU, @DECS_TBU)), ", 
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
", ($SYNC_RAM==1)? "
sync_mem #($RAM_BYTE_WIDTH,$RAM_ADR_WIDTH) sync_mem0
(
	.clk(mclk), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.wr_en(wr_en), 
	.rd_adr(rd_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data)
);": "
async_mem #($RAM_BYTE_WIDTH,$RAM_ADR_WIDTH) async_mem0
(
	.clk(mclk), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.wr_en(wr_en), 
	.rd_adr(rd_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data)
);", "

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
    \$display(\"DEBUG output file write is enabled.\");
    line=0; 
	f_debug=\$fopen(`DEBUG_OUT_FILE);
end
always @(posedge mclk)
begin
        if(valid_decs)
        begin
            \$fwrite(f_debug,", '"%b\n",',"{", join(", ", @DECS_TBU),"});
             line=line+1;
	     if((line%$MAX_SLICE) \==0)
             begin
                 \$fwrite(f_debug,\"\\n\");
             end
//             if(line%16==15)
//             begin
//                 \$fwrite(f_debug,\"\\n\");
//             end
        end
end
`endif
endmodule
");
print @text;
}

# version 1.2 decoder not direct traceback option
sub decoder()
{
my ($i,$j, $reg_valid_in, @reg_symbols, $reg_pattern); 

my @text=("

`include \"glb_def.v\"

`define RAM_BYTE_WIDTH $RAM_BYTE_WIDTH
`define RAM_ADR_WIDTH $RAM_ADR_WIDTH 

module decoder
(
	mclk, 
	rst, 
	srst, 
	valid_in, 
	", join(", 
	", @SYMBOLS), ", 
	pattern, 
	bit_out, 
	valid_out
);
input mclk, rst, srst, valid_in;
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;           //////////////////////////////////////////////
output bit_out, valid_out;

wire valid_decs;
wire[`V-1:0] ", join(", ", @DECS_TBU), ";
wire wr_en, rd_en, en_filo_in;
wire[`V-1:0] filo_in;
wire[`RAM_BYTE_WIDTH - 1:0] wr_data, rd_data;
wire[`RAM_ADR_WIDTH - 1:0] wr_adr, rd_adr;

vit vit_i
(
	.mclk(mclk), 
	.rst(rst), 
	.valid(valid_in), 
	.", join(", 
	.", party(@SYMBOLS, @SYMBOLS)), ", 
	.pattern(pattern), 
	.", join(", 
	.", party(@DECS_TBU, @DECS_TBU)), ", 
	.valid_decs(valid_decs)
);

traceback traback_i
(
	.clk(mclk), 
	.rst(rst), 
	.srst(srst), 
	.valid_in(valid_decs), 
	.", join(", \n.", party(@DECS_TBU, @DECS_TBU)), ", 
	.wr_en(wr_en), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data), 
	.rd_adr(rd_adr), 
	.en_filo_in(en_filo_in), 
	.filo_in(filo_in)
);
", ($SYNC_RAM==1)? "
sync_mem #($RAM_BYTE_WIDTH,$RAM_ADR_WIDTH) sync_mem0
(
	.clk(mclk), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.wr_en(wr_en), 
	.rd_adr(rd_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data)
);": "
async_mem #($RAM_BYTE_WIDTH,$RAM_ADR_WIDTH) async_mem0
(
	.clk(mclk), 
	.wr_data(wr_data), 
	.wr_adr(wr_adr), 
	.wr_en(wr_en), 
	.rd_adr(rd_adr), 
	.rd_en(rd_en), 
	.rd_data(rd_data)
);", "

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
    \$display(\"DEBUG output file write is enabled.\");
    line=0; 
	f_debug=\$fopen(`DEBUG_OUT_FILE);
end
always @(posedge mclk)
begin
        if(valid_decs)
        begin
            \$fwrite(f_debug,", '"%b\n",',"{", join(", ", @DECS_TBU),"});
             line=line+1;
	     if((line%$MAX_SLICE) \==0)
             begin
                 \$fwrite(f_debug,\"\\n\");
             end
//             if(line%16==15)
//             begin
//                 \$fwrite(f_debug,\"\\n\");
//             end
        end
end
`endif
endmodule
");
print @text;
}
1
