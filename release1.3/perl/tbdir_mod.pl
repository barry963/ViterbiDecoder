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
#
#  version 1.3 updated date: 2009/2

sub tbdir_mod()
{
my ($i,$j, $reg_valid_in, @reg_symbols, $reg_pattern); 

my @text=("

`include \"glb_def.v\"

module tbdir_mod
(
    clk,
    rst,
    srst,
    tb_dir,
    tb_dir_filo,
    tbdir_mod_err
);

input clk;
input rst, srst;
input tb_dir;
input tb_dir_filo;
output tbdir_mod_err;

reg [`U-1:0] ccnt;

reg  tbdir_mod_err;
reg [2:0] tbdir_cnt;
always @(posedge clk or posedge rst)begin: _tbdir_mod_err
    if(rst)
        tbdir_mod_err<=0;
    else if(srst)
        tbdir_mod_err<=0;
    else begin
        if(tbdir_cnt>=3)
            tbdir_mod_err<=1;
    end
end

always @(posedge clk or posedge rst)begin: _tbdir_cnt
    if(rst)
        tbdir_cnt<=0;
    else if(srst)
        tbdir_cnt<=0;
    else begin
        if(tb_dir_filo)
            tbdir_cnt<=0;
        else if(tb_dir&&ccnt==0)
            tbdir_cnt<=tbdir_cnt+1;
    end
end
always @ (posedge clk or posedge rst) begin
    if(rst)
        ccnt<=0;
    else if(srst)
        ccnt<=0;
    else begin
        if(ccnt==0)ccnt<=tb_dir;
        else if(ccnt==`SLICE_NUM-1)
            ccnt<=0;
        else ccnt<=ccnt+1;
    end
end
endmodule    
            
");
print @text;
}
1
