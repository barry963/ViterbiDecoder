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
#   version 1.2  update date: 2008/12/18
#   version 1.1  update date: 2006/7
#             
sub vit()
{
my ($i, $j, $pe, $yz_in, $y_out, $z_out);
my (@tmp1, @tmp2, @tmp3);
my $w_mask=2**$W-1;

print "`include \"glb_def.v\"\n";

print "
module vit
(
    mclk, 
    rst,", ($DIRECTTB==1)?"
    tb_dir,": "" , " 
    valid, 
    ", join(", 
    ", @SYMBOLS), ", 
    pattern, 
    ", join(", 
    ", @DECS_TBU), ", 
    valid_decs", ($DIRECTTB==1)?",
    tb_dir_vit": "", "
);
input mclk, rst, valid;", ($DIRECTTB==1)?"
input tb_dir;":"","
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;
output[`V-1:0] ", join(", ", @DECS_TBU), ";
output valid_decs;", ($DIRECTTB==1)?"
output tb_dir_vit;":"","

";foreach $pe (@PES){print 
"wire[`V-1:0] ", join(", ", prefix("$pe\_", @PE_DECS,"")), ";\n";} print "
wire valid_slice;
wire[`U-1:0] slice;					// u canot be less than one
wire[`Bit_Width-1:0] ", join(", ", @reg_symbols), ";
wire[`SYMBOLS_NUM-1:0] reg_pattern;           
wire[`V-1:0] shift_cnt;       
wire[`U-1:0] ",join(", ", @adrs_shift), ";            

";foreach $pe (@PES){print 
"wire[`SM_Width-1:0] ", join(", ", prefix("$pe\_",@in_sms,"")), ", ", join(", ", prefix("$pe\_", @out_sms,"")), ";  
";} $i=0; foreach $pe (@PES){ foreach $j (@PE_DECS){ print 
"assign ",$DECS_TBU[$i],"=$pe\_$j\;	 \n"; $i++; }}
	for($i=0;$i<$PES_NUM;$i++){
	for($j=0;$j<$PATH_NUM;$j++){
		$yz_in=($i<<$V)|$j;
		$y_out=$yz_in&$w_mask;
		$z_out=$yz_in>>$W;
		print 
"assign pe$i\_in_sm$j\=pe$y_out\_out_sm$z_out\;             \n";
	}
	}
	for($i=0;$i<$PES_NUM;$i++){
	@tmp1=prefix("pe$i\_", @in_sms,"");
	@tmp2=prefix("pe$i\_", @out_sms,"");
	@tmp3=prefix("pe$i\_", @PE_DECS,"");
	
	print 
"\npe #($i) pe_$i(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .",join(", .", party(@adrs_shift, @adrs_shift), party(@SYMBOLS,@reg_symbols)), ", .pattern(reg_pattern), .", 
	join(", .", party(@in_sms, @tmp1)), ", .",
	join(", .", party(@out_sms, @tmp2)), ", .",
	join(", .", party(@PE_DECS, @tmp3)), ");";
	}
	print "		
ctrl ctrl_i
(
    .mclk(mclk), 
    .rst(rst), 
    .valid(valid),", ($DIRECTTB==1)?"
    .tb_dir(tb_dir),":""," 
    .", join(", 
    .", party(@SYMBOLS, @SYMBOLS)), ", 
    .pattern(pattern), 
    .valid_slice(valid_slice), 
    .slice(slice), 
    .shift_cnt(shift_cnt), 
    .", join(", 
    .", party(@adrs_shift, @adrs_shift), party(@reg_symbols, @reg_symbols)), ", 
    .reg_pattern(reg_pattern), ", ($DIRECTTB==1)?"
    .tb_dir_vit(tb_dir_vit),":""," 
    .valid_decs(valid_decs)
);
endmodule
";
}

1
