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
#  version 1.3 updated date: 2009/2

sub dirtraback()
{   
my @case=parties(@NUMS_DEC_TBU, ": dec=", @RD_DECS_TBU, "; ");
my $rd_bit_width=$W+$V;

print "
`include \"glb_def.v\"

// max_len, how much we think buffer is overflowed...;
`define MAX_LEN       ",2*$TB_LEN,"
// the radix of TB_LEN;
`define TBLEN_RDX      ",$TBLEN_RDX,"
// trace back length is TB_LEN*V
`define TB_LEN 			",$TB_LEN," 
// TB_LEN-1
`define TBLEN_1         ",$TB_LEN-1,"
// TB_LEN-TB_OUT
`define TBLEN_TBOUT     ",$TB_LEN-$TB_OUT,"
// output decs one trace back action, 2^OUT_STAGE_RADIX, equal TRACE_LEN/n, 1<n<=2^u
`define TB_OUT 			",$TB_OUT," 
// TB_OUT-1
`define TBOUT_1         ",$TB_OUT-1,"

// the size of ram is 1024x32bits, letting it be pow of two makes address 
// generation work well.
`define RAM_ADR_WIDTH 	$RAM_ADR_WIDTH 
// equal to 2^(w+v) 
`define DEC_NUM 		$NUM_DEC_TBU 
// DEC_NUM*`V 
`define RAM_BYTE_WIDTH  $RAM_BYTE_WIDTH  

// one byte includes 2^(w+v) decs, each dec is a v-bits vector
module dirtraback
(
    clk, 
    rst, 
    srst,
    valid_in,
    tb_dir_i,
    ", join(", 
    ", @DECS_TBU), ", 
    wr_en, 
    wr_data, 
    wr_adr, 
    rd_en, 
    rd_data, 
    rd_adr, 
    tb_dir_o,
    filo_clr,
    filo_fls,
    en_filo_in, 
    filo_in,
    
    traceback_error
); 
input clk, rst, srst, valid_in;
input tb_dir_i;
input[`V-1:0] ", join(", ", @DECS_TBU),";
input[`RAM_BYTE_WIDTH-1:0] rd_data;
output[`RAM_ADR_WIDTH-1:0] rd_adr;
output rd_en, wr_en;
output[`RAM_BYTE_WIDTH-1:0] wr_data;
output[`RAM_ADR_WIDTH-1:0] wr_adr;
output tb_dir_o;
output filo_clr;
output filo_fls;
output en_filo_in;
output[`V-1:0] filo_in;
output traceback_error;

reg traceback_error;
//reg [`RAM_BYTE_WIDTH-1:0] wr_data;
reg [`RAM_ADR_WIDTH-1:0] wr_adr;
//reg wr_en;
reg tb_dir_tb, tb_dir_o;
reg filo_fls;
reg en_filo_in;
reg [`V-1:0] filo_in;
reg traceback;
reg [`TBLEN_RDX-1:0] wrt_cnt, tb_cnt;
wire[`W+`V-1:0] rd_bit;
wire tb_trick;
reg tb_dir_lock;
reg [`TBLEN_RDX-1:0] wrtcnt_lock;
wire [`TBLEN_RDX-1:0] wire_wrtcnt;
wire [`RAM_ADR_WIDTH-`U-1:0] wire_wradrcol;
reg [`RAM_ADR_WIDTH-`U-1:0] wradrcol_lock, wradr_col_1;", ($SYNC_RAM==1)?"
wire[`W+`V+`U-1:0] cur_state, trans_state;":"
wire[`W+`V+`U-1:0] next_state, trans_state;
reg[`W+`V+`U-1:0] last_state;", "

assign wire_wrtcnt = valid_in?wrt_cnt:(wrt_cnt-1);
assign tb_trick = (valid_in&&wrt_cnt==`TBLEN_1&&wr_adr[`U-1:0]=={`U{1'b1}})?1:0;

always @(posedge clk or posedge rst)begin
    if(rst) begin
        wrtcnt_lock<=0;
        wradrcol_lock<=0;
        tb_dir_lock<=0;
    end else if(srst)begin
        wrtcnt_lock<=0;
        wradrcol_lock<=0;
        tb_dir_lock<=0;
    end else begin
        if(tb_dir_i&&traceback&&tb_cnt!=0)begin
            wrtcnt_lock<=wire_wrtcnt;
            wradrcol_lock <=wire_wradrcol;
            tb_dir_lock<=1;
        end else if(traceback&&tb_cnt==0)begin
            tb_dir_lock<=0;
        end
    end
end
            

//                                     
// |<---------trace_back |wrt_dec----->|
// +---------------------+-------------+
// |                     |             |
// |                     |             |
// |                     |             |
// |                     |             |
// +---------------------+-------------+
// |<--------------tb_cnt|
// |<------tb_len------->|
// |------------------wrt_cnt--------->|
//
//at any time if tb_dir_i is avaiable, if during traceback(not direct traceback), clear filo and
// begin a direct traceback 
//
always @(posedge clk or posedge rst) begin: _trace_cnt
    if(rst) begin
        tb_cnt<=0;
    end else begin
        if(srst)begin
            tb_cnt<=0;
        end else begin
            if(!traceback)begin
                if(tb_dir_i||tb_trick) tb_cnt<=wire_wrtcnt;
            end else if(traceback)begin
                if(tb_cnt!=0) tb_cnt<=tb_cnt-1;
                else if(tb_dir_i) tb_cnt<=wire_wrtcnt;
                else if(tb_dir_lock) tb_cnt<=wrtcnt_lock;
                else if(tb_trick) tb_cnt<=wire_wrtcnt;
            end
        end
    end
end
always @(posedge clk or posedge rst) begin: _write_cnt
    if(rst) begin
        wrt_cnt<=0;
    end else begin
        if(srst) begin
            wrt_cnt<=0;
        end else begin
            if(tb_dir_i)  wrt_cnt<=0;
            else if(tb_trick) wrt_cnt<=`TBLEN_TBOUT;
            else if(valid_in&&wr_adr[`U-1:0]=={`U{1'b1}})
                wrt_cnt<=wrt_cnt+1;
        end
    end
end
always @(posedge clk or posedge rst) begin: _traceback
    if(rst)
        traceback<=0;
    else begin
        if(srst)
            traceback<=0;
        else begin
            if(!traceback)
                traceback<=(tb_dir_i|tb_trick);
            else if(traceback&&tb_cnt==0)
                traceback<=(tb_dir_lock|tb_dir_i|tb_trick);
        end
    end
end
always @(posedge clk or posedge rst) begin: _tb_dir_tb
    if(rst)
        tb_dir_tb<=0;
    else begin
        if(srst)
            tb_dir_tb<=0;
        else begin
            if(traceback&&tb_cnt==0) tb_dir_tb<=(tb_dir_lock|tb_dir_i);
            else if(!traceback) 
                tb_dir_tb<=tb_dir_i;
        end
    end
end
always @(posedge clk or posedge rst)begin: _tb_dir_o
    if(rst)
        tb_dir_o<=0;
    else begin
        if(srst)
            tb_dir_o<=0;
        else begin
            if(tb_dir_o)
                tb_dir_o<=0;
            else if(tb_dir_tb&&tb_cnt==0)
                tb_dir_o<=1;
       end
    end
end     
always @(posedge clk or posedge rst)begin: _filo_fls
    if(rst)
        filo_fls<=0;
    else begin
        if(srst)
            filo_fls<=0;
        else begin
            if(traceback&&tb_cnt==0) filo_fls<=1;
            else filo_fls<=0;
        end
    end
end
//
//some cases when tb_dir_i is avaliable
// not begin a traceback             during a traceback,but not send data     during a traceback,have send data    
//                                   to filo.                                 to filo,but not at the end of traceback.                                
//|-write here-->|                  |------------write here -------->|       |------------write here -------->|             
//+------------------------+        +--------------------------------+       +--------------------------------+       
//|              |         |        |          |               |     |       |          |               |     |       
//|    decs      |  blank  |        |          |<---Tb here--->| decs|       | <Tb here>|               | decs|       
//|              |         |        |          |               |     |       |          |               |     |       
//|              |         |        |          |               |     |       |          |               |     |       
//+------------------------+        +--------------------------------+       +--------------------------------+       
//|<----------tb_len------>|        |<-tb_out->|                             |<-tb_out->|                               
//                                  |<----------tb_len-------->|             |<----------tb_len------>|               
//
// at the end of traceback.
//|------------write here -------->|       
//+--------------------------------+       
//|          |               |     |       
//|          |               | decs|       
//|          |               |     |       
//|          |               |     |       
//+--------------------------------+
//^
//TB_here       
//|<-tb_out->|                             
//|<----------tb_len------>|               
//
// Never clear filo, every time when tb_dir_i high at traceback process, wait this traceback end.
assign filo_clr=0;

always @(posedge clk or posedge rst)begin
    if(rst)
        en_filo_in<=0;
    else begin
        if(srst)
            en_filo_in<=0;
        else begin
            if(tb_dir_tb||traceback&&tb_cnt<`TB_OUT) 
                en_filo_in<=1;
            else 
                en_filo_in<=0;
        end
    end
end
// data path, filo_in
// 
always @(posedge clk or posedge rst)begin
    if(rst)
        filo_in<=0;
    else begin
        if(tb_dir_tb||traceback&&tb_cnt<`TB_OUT)
            filo_in <= ",($SYNC_RAM==1)?"trans_state[`V-1:0]":"last_state[`V-1:0]",";
    end
end

always @(posedge clk or posedge rst) begin: _traceback_error
    if(rst)
        traceback_error<=0;
    else if(srst)
        traceback_error<=0;
    else begin
        if(tb_trick&&traceback&&tb_cnt!=0)  // traceback is slower than write decs
            traceback_error<=1;
    end
end

//////////////////////////////////////////
wire[`V-1:0] ", join(", ", @RD_DECS_TBU), ";            
", ($SYNC_RAM==1)?"
reg[`RAM_ADR_WIDTH-`U-1:0] rd_adr_col;
reg[`W+`V+`U-1:0] fore_state;
reg trace_head;
reg[`W+`V+`U-1:0] head_state;
reg[`V-1:0] dec;
wire[`U-1:0] rd_adr_byte;		// u cannot be less than 1

//!
reg rd_en_dl;
reg wr_rd_simu;
reg[`RAM_BYTE_WIDTH-1:0] wr_data_dl;

wire[`U-1:0] cur_rd_adr_byte;		
wire begin_trace;

assign begin_trace = (!traceback&&(tb_dir_i||tb_trick)||
          traceback&&tb_cnt==0&&(tb_dir_i||tb_dir_lock||tb_trick))?1:0;
always @(posedge clk or posedge rst)begin: _state
    if(rst)begin
        head_state<=0;
        trace_head<=0;
    end
    else begin
        if(srst)begin
            head_state<=0;
            trace_head<=0;
        end
        else begin
            trace_head<=0;
            head_state<=0;
            if(begin_trace)begin
                trace_head<=1;
                head_state<= 0 ;   // direct traceback from Zero state
            end
        end     
    end
end    
always @(posedge clk or posedge rst) begin
    if(rst)
        fore_state<=0;
    else if(srst)
        fore_state<=0;
    else begin
        if(traceback&&tb_cnt!=0)
            fore_state<= trans_state;
    end 
end 
       
//
// ram address generate
// a little complicated
//
// begintrace_|-|_______________________________________________
// traceback ___|-----------------------------------------|_____
// rd_en     ___|----------------|___|----------------|_________
// rdadr     ___|s0|s1|s2|...|s62|___|s0|s1|s2|...|s62|_________    TB_LEN=64
// dec       ___|xx|s0|s1|...|s61|s62|xx|s0|s1|...|s61|s62|_____ 
// sendbits  ___|s0|s1|s2|...|s62|s63|s0|s1|s2|...|s62|s63|_____
//
// The first state is Zero, tracebacking from zero.
// current state = {last_state,dec}
// address = trans(current state)
//
      
assign rd_en = (traceback&&tb_cnt!=0)?1:0;
assign rd_adr={rd_adr_col, cur_rd_adr_byte};
assign cur_rd_adr_byte = cur_state[`W+`U-1:`W];
assign {rd_adr_byte, rd_bit} = fore_state;
assign cur_state=(trace_head)?head_state:{fore_state[`W+`U+`V-1:`V], dec};
assign trans_state = {cur_state[`W+`U-1:0], cur_state[`W+`U+`V-1:`W+`U]};
":"
reg[`RAM_ADR_WIDTH-`U-1:0] rd_adr_col;
reg[`W+`V+`U-1:0] state;
reg[`V-1:0] dec;
wire[`U-1:0] rd_adr_byte;		// u cannot be less than 1

//!
reg[`RAM_BYTE_WIDTH-1:0] wr_data_dl;

wire begin_trace;

assign begin_trace = (!traceback&&(tb_dir_i||tb_trick)||
          traceback&&tb_cnt==0&&(tb_dir_i||tb_dir_lock||tb_trick))?1:0;
//
// begintrace_|-|_______________________________________________
// traceback ___|-----------------------------------------|_____
// rd_en     ___|----------------|___|----------------|_________
// rdadr     ___|s0|s1|s2|...|s62|___|s0|s1|s2|...|s62|_________    TB_LEN=64
// dec       ___|s0|s1|s2|...|s62|xx |s0|s1|s2|...|s62|xx |_____ 
// sendbits  ___|s0|s1|s2|...|s62|s63|s0|s1|s2|...|s62|s63|_____
//
// The first state is Zero, tracebacking from zero.
// next_state = {state,dec}
// state      = trans(next_state)
// address = state
//
      
assign rd_en = (traceback&&tb_cnt!=0)?1:0;
assign rd_adr={rd_adr_col, rd_adr_byte};
assign {rd_adr_byte, rd_bit} = state;
assign next_state={state[`W+`U+`V-1:`V], dec};
assign trans_state = {next_state[`W+`U-1:0], next_state[`W+`U+`V-1:`W+`U]};
always @(posedge clk or posedge rst)
    if(rst) last_state<=0;
    else last_state <= (begin_trace)?0:trans_state;
    
always @(posedge clk or posedge rst)begin: _state
    if(rst) state<=0;
    else if(srst) state<=0;
    else begin
        if(begin_trace) state<=0;    // traceback from Zero state
        else if(traceback) state<=trans_state;
    end
end
","

assign {",join(", ", @RD_DECS_TBU),"} = ", ($SYNC_RAM==1)?"wr_rd_simu?wr_data_dl:rd_en_dl?":"rd_en?", "rd_data:0; 
assign wr_en = valid_in;
assign wr_data = {", join(", ", @DECS_TBU), "};
assign wire_wradrcol = valid_in?wr_adr[`RAM_ADR_WIDTH-1:`U]:wradr_col_1;

always @(posedge clk or posedge rst)begin: _rd_adr_col
    if(rst)
        rd_adr_col<=0;
    else begin
        if(!traceback)begin
            if(tb_dir_i||tb_trick) rd_adr_col<=wire_wradrcol;
        end else if(traceback)begin
            if(tb_cnt!=0) rd_adr_col<=rd_adr_col-1;
            else if(tb_dir_i) rd_adr_col<=wire_wradrcol;
            else if(tb_dir_lock) rd_adr_col<=wradrcol_lock;
            else if(tb_trick) rd_adr_col<=wire_wradrcol;
        end
    end
end

always @(posedge clk or rst) begin: _write_addr 
    if(rst) begin
        wradr_col_1<=0;
        wr_adr<=0;
    end else begin
        if(valid_in&&wr_adr[`U-1:0]=={`U{1'b1}}) wradr_col_1<=wr_adr[`RAM_ADR_WIDTH-1:`U];
        if(valid_in) wr_adr<=wr_adr+1;
    end
end

always @(rd_bit or ", join(" or ", @RD_DECS_TBU), ")
begin
    case(rd_bit)", 
    	prefix("\n\t$rd_bit_width\'d", @case,""),"
    endcase
end

// there are four registers, one is wr_adr, the second is th wr_data, the third is 
// reg_rd_adr(and rd_en), the fourth is reg_valid_in. All the other outputs including 
// wr_en are combination out en_filo_in, en_filo_out and filo_in are registers too, 
// but they are not the major part.
// valid_in --->> wr_adr, wr_data, wr_en --->> rd_adr, rd_en
// rd_adr++rd_data --->> filo_in 
", ($SYNC_RAM==1)?"
//
// read and write simulatimely
//
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
end 
":"","     
endmodule
";
}
1
                       