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
#                glb_def.v
#   version 1.1  update date: 2006/7
#
sub virtual_mem()
{
my ($i, $j);

print "`include \"glb_def.v\"\n";
print "
`define RAM_BYTE_WIDTH $RAM_BYTE_WIDTH
`define RAM_ADR_WIDTH $RAM_ADR_WIDTH 
//`define NOMEMORY

module ", ($SYNC_RAM==1)? "sync":"async", "_mem(clk, wr_data, wr_adr, wr_en, rd_adr, rd_en, rd_data);
    // Hits:
    // the output data of the async_mem should be unregistered
    // sync_mem is not
    parameter DATA_WIDTH=`RAM_BYTE_WIDTH;
    parameter ADDRESS_WIDTH=`RAM_ADR_WIDTH;
    
    input clk;
    input [DATA_WIDTH - 1:0] wr_data;
    input [ADDRESS_WIDTH - 1:0] wr_adr;
    input [ADDRESS_WIDTH - 1:0] rd_adr;
    input wr_en;
    input rd_en; 
    output [DATA_WIDTH - 1:0] rd_data;", $SYNC_RAM==1?"
    
    reg [DATA_WIDTH - 1:0] rd_data;":"", "
    
`ifdef NOMEMORY
    reg[DATA_WIDTH-1:0] mem[0:0];", ($SYNC_RAM==1)? "": "
    assign rd_data=rd_en?mem[0]:'bx;", "
    always @(posedge clk )
    begin ", ($SYNC_RAM==1)? "
    if (rd_en) rd_data<=mem[0];
    else rd_data<='bx;
    ":"
    ", "
	if(wr_en&&wr_adr==0&&rd_adr==0)
	begin
	    mem[0]<=wr_data;
	end
	else
	    mem[0]<=1;
    end
`else
    reg [DATA_WIDTH - 1:0] mem[",$RAM_BYTES_NUM-1,":0];
    //integer temp;
    //initial 
    //begin
    //    for(temp=0;temp<$RAM_BYTES_NUM;temp=temp+1)
    //    begin
    //        mem[temp]=0;
    //    end
    //end
    ", ($SYNC_RAM==1)? "": "
    assign rd_data=rd_en?mem[rd_adr]:'bx;", "
    always @(posedge clk)
    begin  ", ($SYNC_RAM)? "
    	if (rd_en) rd_data<=mem[rd_adr];
    	else rd_data<='bx;":"
    	", "
	    if(wr_en)
	    begin
	        mem[wr_adr]<=wr_data;
	    end
    end
`endif
endmodule
";
}
1
