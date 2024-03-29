// version1.3
///////////////////////////////////////////////////////////////////
         //////                                    //////
///////////////////////////////////////////////////////////////////
///                                                             ///
/// This file is generated by Viterbi HDL Code Generator(VHCG)  ///
/// which is written by Mike Johnson at OpenCores.org  and      ///
/// distributed under GPL license.                              ///
///                                                             ///
/// If you have any advice,                                     ///
/// please email to jhonson.zhu@gmail.com                       ///
///                                                             ///
///////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////




// B=1, symbol_num=2, W=4, V=1, U=1
// para_polys=91 121
// Support Direct Traceback, Synchronous Ram



`include "glb_def.v"

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
            
