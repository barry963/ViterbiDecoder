
module acs2(old_sm0, old_sm1, bm00, bm01, bm10, bm11, new_0sm, new_1sm, dec0, dec1);
//branch_M0 is the metric of cross branchs, branch_M1 is the parallel
//branchs.
    parameter  SM_Width=`SM_Width;
    parameter BM_Width=`BM_Width;
    
    input [SM_Width-1:0] old_sm0, old_sm1;
    input [BM_Width-1:0] bm00, bm01, bm10, bm11;
//    input ready;
    
    output [SM_Width-1:0] new_0sm, new_1sm;
    output dec0,dec1;
    
    reg [SM_Width-1:0] sum00, sum01, sum10, sum11;
    reg [SM_Width-1:0] result0, result1;
    reg [SM_Width-1:0] new_0sm, new_1sm;
    reg dec0, dec1;
    	
    always @(old_sm0 or  old_sm1 or bm00 or bm01 or bm10 or bm11)
	begin
	    sum00=old_sm0+bm00;
	    sum10=old_sm1+bm10;
	    sum01=old_sm0+bm01;
	    sum11=old_sm1+bm11;
	    //To prevent the overflow of the surviver metric, the rule of
	    //decision is not as simple as usually.It must be changed.
	    result0 = sum00 - sum10;
	    result1 = sum01 - sum11;
	    
	    if(result0[SM_Width-1]==1) // sum00<sum10
	    begin
		new_0sm=sum00;
		dec0=0;
	    end
	    else
	    begin
		new_0sm=sum10;
		dec0=1;
	    end
	    if(result1[SM_Width-1]==1) // sum01<sum11
	    begin
		new_1sm=sum01;
		dec1=0;
	    end
	    else
	    begin
		new_1sm=sum11;
		dec1=1;
	    end
    end
endmodule   
