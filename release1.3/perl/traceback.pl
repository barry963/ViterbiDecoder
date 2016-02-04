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
#              format adjustment
#              insert srst signal
#              negedge rst to posedge rst
#  version 1.1 updated date: 2006/7
# 
sub traceback()
{
my ($i, $j);
my @tmp=parties(@NUMS_DEC_TBU, ": dec=", @RD_DECS_TBU, "; ");
my $rd_bit_width=$W+$V;

print "`include \"glb_def.v\"\n";
print "
// radix of output number of DECS of one traceback action. 
// It is equal U+OUT_STAGE_RADIX
`define OUT_NUM_RADIX   $OUT_NUM_RADIX 
// output number of DECS in one traceback action. 
// It is equal 2^(U+OUT_STAGE_RADIX) and larger than TRACE_LEN.
`define OUT_NUM         $OUT_NUM 
// trace back length. `LEN MUST smaller than `OUT_NUM 
`define LEN 			$TRACE_BACK_LEN 
// output decs one trace back action, 2^OUT_STAGE_RADIX, equal TRACE_LEN/n, 1<n<=2^u
`define OUT 			$OUT_STAGE 
// the size of ram is 1024bits, letting it be pow of two makes address 
// generation work well.
`define RAM_ADR_WIDTH 	$RAM_ADR_WIDTH 
// equal to 2^(w+v) 
`define DEC_NUM 		$NUM_DEC_TBU 
// DEC_NUM*`V 
`define RAM_BYTE_WIDTH  $RAM_BYTE_WIDTH 
// n=`LEN/`OUT 
`define DUMMY_BLOCK_NUM $DUMMY_BLOCK_NUM 
// the width of count of dummy block
`define DUMMY_CNT_WIDTH $DUMMY_CNT_WIDTH 

// one byte includes 2^(w+v) decs, each dec is a v-bits vector
module traceback
(
    clk, 
    rst, 
    srst,
    valid_in,
    ", join(", 
    ", @DECS_TBU), ", 
    wr_en, 
    wr_data, 
    wr_adr, 
    rd_en, 
    rd_data, 
    rd_adr, 
    en_filo_in, 
    filo_in
); 
input clk, rst, srst, valid_in;
input[`V-1:0] ", join(", ", @DECS_TBU),";                   
input[`RAM_BYTE_WIDTH-1:0] rd_data;
output[`RAM_ADR_WIDTH-1:0] rd_adr;
output rd_en, wr_en;
output[`RAM_BYTE_WIDTH-1:0] wr_data;
output[`RAM_ADR_WIDTH-1:0] wr_adr;
output en_filo_in;
output[`V-1:0] filo_in;


reg[`RAM_BYTE_WIDTH-1:0] wr_data;
reg[`RAM_ADR_WIDTH-1:0] wr_adr;
reg en_filo_in;
reg[`V-1:0] filo_in;			// v cannot be less than 1
reg wr_en;
reg[`RAM_ADR_WIDTH-`U-1:0] rd_adr_col;
reg[`DUMMY_CNT_WIDTH-1:0] dummy_cnt;
reg Is_not_first_3blocks, During_traback, During_send_data;
reg[`W+`V+`U-1:0] state;

wire[`RAM_ADR_WIDTH-`U-1:0] dec_rd_adr_col;
wire[`V-1:0] ", join(", ", @RD_DECS_TBU), ";            
wire[`W+`V+`U-1:0] next_state;
reg[`V-1:0] dec;
"; print "wire[`U-1:0] rd_adr_byte;		// u cannot be less than 1" if($U>0); print "
wire[`W+`V-1:0] rd_bit;"; if($SYNC_RAM==1){ print "
//!
reg rd_en_dl;
reg wr_rd_simu;
reg[`RAM_BYTE_WIDTH-1:0] wr_data_dl;

wire[`RAM_ADR_WIDTH-`U-1:0] wire_rd_adr_col;
wire[`U-1:0] next_rd_adr_byte;		
assign rd_adr={wire_rd_adr_col"; print ", next_rd_adr_byte" if($U>0); print "};"; print "
assign rd_en=(dummy_cnt==`DUMMY_BLOCK_NUM&&wr_adr[`OUT_NUM_RADIX-1:0]==(`OUT_NUM-1))? 1: (wr_adr[`OUT_NUM_RADIX-1:0]==(`LEN-1))? 0: During_traback;"; print "
assign next_rd_adr_byte=next_state[`W+`U-1:`W];" if($U>0); print "
assign wire_rd_adr_col = (valid_in&&wr_adr[`OUT_NUM_RADIX-1:0]==(`OUT_NUM-1)&&dummy_cnt==`DUMMY_BLOCK_NUM)? wr_adr[`RAM_ADR_WIDTH-1:`U]: rd_adr_col;";} else {print "

assign rd_adr={rd_adr_col"; print ", rd_adr_byte" if($U>0); print "};
assign rd_en=During_traback;";} print "

assign {",join(", ", @RD_DECS_TBU),"} = ", ($SYNC_RAM==1)? "wr_rd_simu?wr_data_dl:rd_en_dl?":"rd_en?", "rd_data:0;       ///////////////////////////////////////////////////
assign dec_rd_adr_col=rd_adr_col-1;
assign {"; print "rd_adr_byte, " if($U>0); print "rd_bit}=state;
// need to be noticed
// assign next_state=(valid_in&&wr_adr[`OUT_NUM_RADIX-1:0]==(`OUT_NUM-1)&&dummy_cnt==`DUMMY_BLOCK_NUM)?0:
assign next_state = 
{",($W+$U)>=1?"state[`W+`U+`V-1:`V], ":"", "dec};

always @(rd_bit or ", join(" or ", @RD_DECS_TBU), ")
begin
    case(rd_bit)", 
    	prefix("\n\t$rd_bit_width\'d", @tmp,""),"
    endcase
end

// if y denote the `OUT_NUM_RADIX-1 to 0 bits of write address, x denote the column 
// address(`RAM_ADR_WIDTH-1 to u) of write address, z denote the column address of read 
// address, then z = x-y-1
// if y>=0 && y<=(len-out-1) trace back
// if y>=(len-out) && y<=(len-1) send out
// if y>=len && y<=(`OUT_NUM-1)  wait for next trace back
// 
// x=wr_adr[`RAM_ADR_WIDTH-1:`U]
// y=wr_adr[`OUT_NUM_RADIX-1:0]
// z=rd_adr_col=rd_adr[`RAM_ADR_WIDTH-1:`U]

// there are four registers, one is wr_adr, the second is th wr_data, the third is 
// reg_rd_adr(and rd_en), the fourth is reg_valid_in. All the other outputs including 
// wr_en are combination out en_filo_in, en_filo_out and filo_in are registers too, 
// but they are not the major part.
// valid_in --->> wr_adr, wr_data, wr_en --->> rd_adr, rd_en
// rd_adr++rd_data --->> filo_in ", ($SYNC_RAM==1)? "
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin   
		rd_en_dl<=0;
		wr_data_dl<=0;
		wr_rd_simu<=0;
	end 
	else if (srst)
	begin   
		rd_en_dl<=0;
		wr_data_dl<=0;
		wr_rd_simu<=0;
	end
	else
	begin
		rd_en_dl<=rd_en;
		if(wr_en&&rd_en&&wr_adr==rd_adr)
		begin
			wr_rd_simu<=1;
			wr_data_dl<=wr_data;
		end
		else
		begin
			wr_rd_simu<=0;
		end
	end
end ": "", "
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        dummy_cnt<=0;
        wr_data<=0;
        wr_adr<=`OUT_NUM-1;
        wr_en<=0;
        rd_adr_col<=0;
        state<=0;
	//rd_adr_byte<=0;
        //rd_bit<=0;
        en_filo_in<=0;
        filo_in<=0;
        Is_not_first_3blocks<=0;
        During_traback<=0;
        During_send_data<=0;
    end
    else if (srst)
    begin
        dummy_cnt <= 0;
        wr_data <= 0;
        wr_adr <= `OUT_NUM-1;
        wr_en <= 0;
        rd_adr_col <= 0;
        state <= 0;
        en_filo_in <= 0;
        filo_in <= 0;
        Is_not_first_3blocks <= 0;
        During_traback <= 0;
        During_send_data <= 0;
    end
    else if(valid_in)
    begin
        // if input is valid, we will always write decs into ram.
        wr_en<=1;
        wr_data<={", join(", ", @DECS_TBU), "};
        wr_adr<=wr_adr+1; 
        // if during trace back
        if(During_traback&&Is_not_first_3blocks)   
        begin
            // Trace back. Do three things: write decs to ram , read read decs from 
            // ram for generate next read address and send data to filo
            filo_in<=rd_bit[`V-1:0];
            rd_adr_col<=dec_rd_adr_col;
	        state<={",($W+$U)>=1?"next_state[`W+`U-1:0], ":"", "next_state[`W+`U+`V-1:`W+`U]};
            // scratch
            // {rd_adr_byte, rd_bit}<={rd_adr_byte[`U-`V-1:0], rd_bit[`W+`V-1:`V], dec, rd_adr_byte[`U-1:`U-`V]};       
            // {rd_adr_byte, rd_bit}<={rd_bit[`W+`V-1:`V], dec, rd_adr_byte[`U-1:`U-`V]};    
            // 
        end
        
        // decide whether send data to filo
        // if have trace back enough bits, we can send out dec
        if((wr_adr[`OUT_NUM_RADIX-1:0]==`LEN-`OUT) && Is_not_first_3blocks)
        begin
            // Trace back and send out dec to filo
            en_filo_in<=1;
            During_send_data<=1;
        end
        // else if have send out all data, stop send data
        else if((wr_adr[`OUT_NUM_RADIX-1:0]==`LEN-1) && Is_not_first_3blocks)
        begin
            // For the abnormal condition `LEN==`OUT_NUM
            en_filo_in<=1;
            During_send_data<=0;
        end 
        else
            en_filo_in<=During_send_data;
        
        // decide whether begin a trace or stop a trace
        if(wr_adr[`OUT_NUM_RADIX-1:0]==`OUT_NUM-1)
        begin
            // Initialize a trace action
            if(dummy_cnt==`DUMMY_BLOCK_NUM)   // It is already not the dummy block, so dont add it
            begin
                Is_not_first_3blocks<=1;
                During_traback<=1;
                rd_adr_col<="; print (($SYNC_RAM==1)?"wr_adr[`RAM_ADR_WIDTH-1:`U]-1":"wr_adr[`RAM_ADR_WIDTH-1:`U]"); print ";
                state<=0;    //{(`U-`V)'b0, `W'b0, `V'b0, `V'b0};    ////////////////////
            end
            else
                dummy_cnt<=dummy_cnt+1;
        end
        // else if we have trace back to the end
        else 
        if(wr_adr[`OUT_NUM_RADIX-1:0]==`LEN-1)
            During_traback<=0;
    end
    else    // input decs are not valid                  
    begin
        // Hold the right values
        wr_en<=0;
        en_filo_in<=0;
    end
end

// some scratch
// {next_rd_adr_byte,next_rd_adr_bit}={rd_adr_byte[`U-`V-1:0],rd_adr_bit[`W+`V-1:`V],dec, rd_adr_byte[`U-1:`U-`V]};  
// {wire_rd_adr_byte, wire_rd_bit}={rd_adr_byte[`U-`V-1:0], rd_bit[`W+`V-1:`V], dec, rd_adr_byte[`U-1:`U-`V]};       
//
endmodule
";
}
1
