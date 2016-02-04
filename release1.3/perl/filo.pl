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
#              negedge rst to posedge rst
#  version 1.1 updated date: 2006/7
#/usr/bin/perl
sub filo()
{
my ($i, $j);

print "`include \"glb_def.v\"\n";
print "
// the number of stages of one traceback output. It should be pow of two. The stage 
// is the stage of encode lattice of radix r.
`define OUT_STAGE_RADIX $OUT_STAGE_RADIX 
// 2^OUT_STAGE_RADIX 
`define OUT_STAGE       $OUT_STAGE

module filo
(
	clk, rst, 
	en_filo_in, filo_in, 
	en_filo_out, filo_out, 
	valid_out
);
input clk, rst, en_filo_in, en_filo_out;
input[`V-1:0] filo_in;
output filo_out;
output valid_out;

reg valid_out;
reg filo_out;
reg[`V-1:0] regfile[`OUT_STAGE-1:0];
reg[`OUT_STAGE_RADIX-1:0] index;
reg[`V-1:0] index_bit;		///////////////////////////////////////////////////////
reg push_or_pop;
wire[`V-1:0] regbyte;
wire[`OUT_STAGE_RADIX-1:0]  inc_index;
wire[`OUT_STAGE_RADIX-1:0]  dec_index;
integer i;

assign inc_index=index+1;
assign dec_index=index-1;
assign regbyte=regfile[index];
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        for(i=0;i<`OUT_STAGE;i=i+1)
        begin
            regfile[i]<=0;
        end
        filo_out<=0;
        index<=0;
        index_bit<=`V'b1;							///////////////////////////////////////////////
        valid_out<=0;
        push_or_pop<=0;         //push
    end
    else
    begin
    	valid_out<=push_or_pop;
        // push data into the register file 
        if (push_or_pop == 0)
        begin
            if(en_filo_in)
            begin
                regfile[index]<=filo_in;
                if(inc_index==`OUT_STAGE_RADIX'b",0 x$OUT_STAGE_RADIX,")		//////////////////////////////////////////////
                begin
                    index<=`OUT_STAGE_RADIX'b",1 x$OUT_STAGE_RADIX,";		//////////////////////////////////////////////
                    push_or_pop<=1;
                end
                else
                begin
                    index<=inc_index;
                    push_or_pop<=0;
                end
            end
        end
        else 		//pop data from the register file 
        if (push_or_pop == 1)
        begin 
            if(en_filo_out)
            begin
                case(index_bit)
		///////////////////////////////////////////////
";
		for($i=0,$j=1;$i<$V;$i++){
			print "\t\t`V'd$j: filo_out<=regbyte[$i];\n";
			$j<<=1;
		}
		print "	
                //    `V'b001:file_out<=regbyte[0];
                //  `V'd010: file_out<=regbyte[1];
                //  `V'd100: file_out<=regbyte[2];
                    default:filo_out<=0;
                endcase
		";if($V>=2){ print 
		"index_bit<={index_bit[`V-2:0],index_bit[`V-1]};    // `V>=2\n";} else {print
		"index_bit<=`V'b1;";} print "	
                if(index_bit==`V'b1",0 x($V-1),")			/////////////////////////////////////////////////////
                begin
                    if(dec_index==`OUT_STAGE_RADIX'b",1x$OUT_STAGE_RADIX,")
                    begin
                        index<=0;
                        push_or_pop<=0;
                    end
                    else
                    begin
                        index<=dec_index;
                        push_or_pop<=1;
                    end
                end
                else
                begin
                    index<=index;
                    push_or_pop<=push_or_pop;
                end
            end
        end
    end    
end
endmodule
";
}
1
