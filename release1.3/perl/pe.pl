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
#  version 1.2 update date: 2008/12/18
#              rst signal changed to high-sensitivity
#              change instance name and format stlye
#  version 1.1 update date: 2006/7

sub pe()
{
my ($i, $j);

print "`include \"glb_def.v\"\n";
# print "
# module pe0(mclk, rst, valid, slice, big_slice, ", join(", ", @SYMBOLS, "pattern, in_"), join(", in_", @PE_SMS), ", out_", join(", out_", @PE_SMS), ", ",  join(", ", @PE_DECS), ");      		/////////////////////
print "
module pe
(
	mclk, 
	rst, 
	valid, 
	slice, 
	shift_cnt, 
	", join(", \n\t", @adrs_shift, @SYMBOLS, "pattern", @in_sms, @out_sms, @PE_DECS), "
);
parameter PE_ID=0;
input mclk;
input rst, valid;
input[`U-1:0] slice;
input[`V-1:0] shift_cnt;      ///////// 
input[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;           //////////////////////////////////////////////
input[`SM_Width-1:0] ", join(", ", @in_sms), ";    //////////////////////////////////////////////
output[`SM_Width-1:0] ", join(", ", @out_sms), ";   ////////////////////////////////////////////////
output[`V-1:0] ", join(", ", @PE_DECS), ";              //////////////////////////////////////////////
reg[`V-1:0] ", join(", ", @PE_DECS), ";                 //////////////////////////////////////////////

", $W>=1?"wire[`W-1:0] pe_id = PE_ID;":"","
wire[`V-1:0] ",join(", ", @wire_decs), ";
wire[`SM_Width-1:0] ", join(", ", @wr_sms), ";
butfly",$PATH_NUM," butfly",$PATH_NUM,"_0(.", join(", .", party(@old_sms, @in_sms)), ", .state_cluster({slice", $W>=1?",pe_id":"","}), .", join(", .",party(@SYMBOLS, @SYMBOLS)), ", .pattern(pattern), .", join(", .", party(@new_sms, @wr_sms), party(@PE_DECS, @wire_decs)),");
smu smu_i
(
	.mclk(mclk), 
	.rst(rst), 
	.valid(valid), 
	.shift_cnt(shift_cnt), 
	.", join(", .", party(@adrs_shift, @adrs_shift), party(@wr_sms, @wr_sms), party(@rd_sms, @out_sms)), "
);

always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin",prefix("
	",@PE_DECS,"<=0;        ///////////////////////////////////"), "
    end
    else if(valid)
    begin
	", parties(@PE_DECS,"<=", @wire_decs,";\n\t"), "
    end
end
endmodule
";
}
1
