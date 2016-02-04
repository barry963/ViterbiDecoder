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

sub centrofilo()
{

print "
`include \"glb_def.v\"

// FILO buffer depth
`define FILO_LEN  ",2**($TBLEN_RDX+1),"
// radix of FILO_LEN
`define FILOLEN_RDX ",$TBLEN_RDX+1,"
// how much times of flush we can accept before send data 
`define FILO_DEPTH 2
// the radix
`define FILODEP_RDX 1
// This is a simple filo, NOT assume each flush operation flushs same number of data(
// Can flush not equal large data)
// and the number of data is not too large, for example, 32bits, 128bits, 256bits;
module centrofilo
(
	clk, rst, 
	srst,
	tb_dir_i,
	filo_fls, filo_clr,
	en_filo_in, filo_in, 
	filo_out, 
	valid_out,
	tb_dir_filo,
	filo_error
);
input clk, rst;
input srst;
input tb_dir_i;
input filo_fls;
input filo_clr;
input en_filo_in;
input [`V-1:0] filo_in;

output filo_out;
output valid_out;
output tb_dir_filo;
output filo_error;

reg filo_out;
reg valid_out;
reg filo_error;
reg tb_dir_filo;

reg[`V-1:0] regfile[`FILO_LEN-1:0];
reg[`FILOLEN_RDX-1:0] rd_ptr, wr_ptr, wrptr_head;
reg[`FILOLEN_RDX-1:0] rd_cnt, wr_cnt; // TB_LEN-1,62,..., 0.
reg filo_sendout;
reg[`V-1:0] bit_index;
wire [`V-1:0] regbyte;

reg tbdir_i_lock;
reg [`FILOLEN_RDX-1:0] rdc[`FILO_DEPTH-1:0];
reg [`FILOLEN_RDX-1:0] rdp[`FILO_DEPTH-1:0];
reg [`FILOLEN_RDX-1:0] rdtb[`FILO_DEPTH-1:0];

reg [`FILODEP_RDX-1:0] c,rp,wp;
reg [`FILODEP_RDX-1:0] c_lock;

wire pop_cond;
integer i;
//
// |<------rd_ptr-|--wr_ptr------>|
// +------------------------------+
// |              |               |
// |              |               |
// |              |               |
// +------------------------------+
// rd_cnt 63,62,61,...,0
// wr_cnt 0, 1, 2, ...,63
//

// this traceback module send en_filo_in and filo_fls simulatimely.            
assign pop_cond = ((!filo_sendout||rd_cnt==0&&bit_index=={`V{1'b1}})&&c!=0)?1'b1:1'b0;      
always @(posedge clk or posedge rst)begin: _rd_ptr
    if(rst)begin
        rd_ptr<=0;
        rd_cnt<=0;
        rp<=0;
    end
    else if(srst)begin
        rd_cnt<=0;
        rd_ptr<=0;
        rp<=0;
    end
    else begin
        if(!filo_sendout||rd_cnt==0&&bit_index=={`V{1'b1}})begin
            if(c!=0) begin
                rd_cnt<=rdc[rp];
                rd_ptr<=rdp[rp];
                rp<=rp+1;
            end
        end
        else if(filo_sendout&&bit_index=={`V{1'b1}})begin
            rd_cnt<=rd_cnt-1;
            rd_ptr<=rd_ptr-1;
        end
    end
end

always @(posedge clk or posedge rst)begin: _wr_ptr
    if(rst)
        wr_ptr<=0;
    else if(srst)
        wr_ptr<=0;
    else begin
        if(filo_clr)
            wr_ptr<=wrptr_head;
        else if(en_filo_in)
            wr_ptr<=wr_ptr+1;
    end
end
always @(posedge clk or posedge rst)begin: _wrptr_head
    if(rst)
        wrptr_head<=0;
    else if(srst)
        wrptr_head<=0;
    else begin
        if(filo_fls)
            wrptr_head<=wr_ptr+1;
    end
end
always @(posedge clk or posedge rst)begin   
    if(rst)begin
        for(i=0;i<`FILO_DEPTH;i=i+1)
            rdc[i]<=0;
        wp<=0;
    end
    else begin
        if(srst) wp<=0;
        else begin
            if(filo_fls)begin
                rdc[wp]<=wr_cnt;
                rdp[wp]<=wr_ptr;
                wp<=wp+1;
            end
        end
    end
end
always @(posedge clk or posedge rst)begin
    if(rst)
        c<=0;
    else if(srst)
        c<=0;
    else if(filo_fls&&pop_cond)
        c<=c;
    else if(filo_fls)
        c<=c+1;
    else if(pop_cond)
        c<=c-1;
    else 
        c<=c;
end

always @(posedge clk or posedge rst)begin: _wr_cnt
    if(rst)
        wr_cnt<=0;
    else if(srst)
        wr_cnt<=0;
    else begin
        if(filo_clr||filo_fls)
            wr_cnt<=0;
        else if(en_filo_in)
            wr_cnt<=wr_cnt+1; 
    end 
end
              
always @(posedge clk or posedge rst)begin: _filo_sendout
    if(rst)
        filo_sendout<=0;
    else if(srst)
        filo_sendout<=0;
    else begin
        if(!filo_sendout||rd_cnt==0&&bit_index=={`V{1'b1}}) filo_sendout<=(c!=0);
    end
end
always @(posedge clk or posedge rst)begin: _bit_index
    if(rst)
        bit_index<={`V{1'b1}};
    else if(srst)
        bit_index<={`V{1'b1}};
    else begin
        if(filo_sendout) bit_index<={`V{1'b1}};
    end
end

always @(posedge clk or posedge rst)begin: _valid_out
    if(rst)
        valid_out<=0;
    else if(srst)
        valid_out<=0;
    else valid_out<=filo_sendout;
end
assign regbyte = regfile[rd_ptr];
always @(posedge clk or posedge rst)begin: _filo_out
    if(rst)
        filo_out<=0;
    else if(srst)
        filo_out<=0;
    else begin
        if(filo_sendout)
            case(bit_index) ";	for($i=0,$j=1;$i<$V;$i++){ print "
            `V'd$j: filo_out<=regbyte[$i];"; $j<<=1;}
		print "	
    		default: filo_out<=0;
    		endcase
	end
end

always @(posedge clk or posedge rst)begin: _filo_error
    if(rst)
        filo_error<=0;
    else if(srst)
        filo_error<=0;
    else begin
        if((rd_cnt+wr_cnt)>=`FILO_LEN ||
            (c==`FILO_DEPTH-1)&&filo_fls&&!pop_cond)
            filo_error<=1;
    end
end
always @(posedge clk or rst)begin: _regfile
    if(rst)
    begin
        for(i=0;i<`FILO_LEN;i=i+1)
        begin
            regfile[i]<=0;
        end
    end else begin
        if(en_filo_in)
            regfile[wr_ptr]<=filo_in;
    end
end
//
// en_filo_in  -----------|____________|---------|_____________
// filo_fls    _______|--|____________________|--|_____________
//             
// valid_out   __|----------|__|---------|___|---------|_______
// tb_dir_i    _________________|--|___________________________
// tbdir_i_lock____________________|-------------------|_______
// c_lock      |0                  |c    |c-1|c-2|...|0|0     |
// tb_dir_filo ________________________________________|--|____
//
always @(posedge clk or posedge rst)begin
    if(rst)
        c_lock<=0;
    else if(srst)
        c_lock<=0;
    else if(tb_dir_i)begin
        if(filo_fls&&pop_cond)
            c_lock<=c;
        else if(filo_fls)
            c_lock<=c+1;
        else if(pop_cond)
            c_lock<=c-1;
        else 
            c_lock<=c;
    end
    else if((!filo_sendout||rd_cnt==0&&bit_index=={`V{1'b1}})&&c_lock!=0)
        c_lock<=c_lock-1;
end

// tb_dir process
always @(posedge clk or posedge rst)begin: _tb_dir_filo
    if(rst)
        tb_dir_filo<=0;
    else if(srst)
        tb_dir_filo<=0;
    else begin
        if((!filo_sendout||rd_cnt==0&&bit_index=={`V{1'b1}})&&c_lock==0&&tbdir_i_lock)
            tb_dir_filo<=1;
        else
            tb_dir_filo<=0;
    end
end
always @(posedge clk or posedge rst)begin: _tbdir_i_lock
    if(rst)
        tbdir_i_lock<=0;
    else if(srst)
        tbdir_i_lock<=0;
    else begin
        if(tb_dir_i)
            tbdir_i_lock<=1;
        else if((!filo_sendout||rd_cnt==0&&bit_index=={`V{1'b1}})&&c_lock==0&&tbdir_i_lock)
            tbdir_i_lock<=0; 
    end
end

endmodule
";
}
1

           