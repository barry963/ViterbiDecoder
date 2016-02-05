module delayT(mclk, rst, in, out);
    parameter Data_Width=12;
    parameter Delay_Count=1;
    
    input mclk, rst;
    input [Data_Width-1:0] in;
    output [Data_Width-1:0] out;
    
    reg [Data_Width-1:0] regs[Delay_Count-1:0];
    integer temp;
    
    assign out=regs[Delay_Count-1];
    
    always @(posedge mclk or posedge rst)
    begin
    	if(rst)
		begin
			for(temp=0;temp<Delay_Count;temp=temp+1)
				begin
						regs[temp]<=0;
				end
		end
	else 
		begin
			regs[0]<=in;
				for(temp=1;temp<Delay_Count;temp=temp+1)
					begin
							regs[temp]<=regs[temp-1];
					end
		end
    end
endmodule
