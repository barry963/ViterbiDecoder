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
#  version 1.2 updated date: 2008/12/18
#              change rst signal
#              glb_def.v
#              module name
#  version 1.1 updated date: 2006/7
sub smu()
{
my ($i,$j,$k);
my (@regfbanks);
for($i=0;$i<$PATH_NUM;$i++){
	push @regfbanks, "regfbank$i";
}


my @wr_sms_shift=prefix("",@wr_sms,"_shift");
my @rd_sms_shift=prefix("",@rd_sms,"_shift");

my @regfadrs=parties(@regfbanks, "[", @adrs_shift, "]");
my @tmp1=parties(@regfadrs, "<=", @wr_sms_shift, ";		//////////////////");
my @ramassign=parties(@rd_sms_shift, " = ", @regfadrs,";");

print "`include \"glb_def.v\"
";
print "
`define PE_SM_NUM $PE_SM_NUM                // 2^(`U+`V)
`define MAX_SLICE $MAX_SLICE                // 2^(`U)

// just for test, not support state-set division.   
module smu
(
	mclk, 
	rst, 
	valid, 
	shift_cnt, 
	", join(", ", @adrs_shift,@wr_sms,@rd_sms), 
");

input mclk, rst, valid;
input[`V-1:0] shift_cnt;      ///////// 
input[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////
input[`SM_Width-1:0] ", join(", ", @wr_sms), ";
output[`SM_Width-1:0] ", join(", ", @rd_sms), ";

reg[`SM_Width-1:0] ", join(", ", prefix("", @regfbanks, "[`MAX_SLICE-1:0]")), ";
reg[`SM_Width-1:0] ", join(", ", @rd_sms), ";   ///////////////////////////////////////
reg[`SM_Width-1:0] ", join(", ", @wr_sms_shift), ";
wire[`SM_Width-1:0] ", join(", ", @rd_sms_shift), ";


integer i;

// for using banks in SMU, we should shift up the read state-metrics order by barriel shift
always @(shift_cnt or ", join(" or ", @rd_sms_shift),")
begin
    case(shift_cnt)";for($i=0;$i<$PATH_NUM;$i++){print "
	$i:
	begin";for($j=0;$j<$PATH_NUM;$j++){print "
	    ",$rd_sms[$j],
	    "=",$rd_sms_shift[($j+$PATH_NUM+$i)%$PATH_NUM],";"} print "
	end";} print "
	default:;
    endcase
end
// for using banks in SMU, we should shift down the write state-metrics order by barriel shift
always @(shift_cnt or ", join(" or ", @wr_sms),")
begin
    case(shift_cnt)";for($i=0;$i<$PATH_NUM;$i++){print "
	$i:
	begin";for($j=0;$j<$PATH_NUM;$j++){print "
	    ",$wr_sms_shift[$j],
	    "=",$wr_sms[($j+$PATH_NUM-$i)%$PATH_NUM],";"} print "
	end";} print "
	default:;
    endcase
end

";
print "
always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin
        for(i=0;i<`MAX_SLICE;i=i+1)
        begin",prefix("
            ",@regfbanks,"[i]<='b0;"),"    
        end
    end
    else if(valid)
    begin",prefix("
    	", @tmp1, ""), "
    end
end", prefix("
assign ", @ramassign, "  ////////////////////////////"),"

endmodule
";
}

1
