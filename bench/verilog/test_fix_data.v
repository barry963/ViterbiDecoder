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



`include "glb_def.v"

`define DEC_NUM 32           // equal to 2^(w+v)
`define RAM_BYTE_WIDTH 32    // DEC_WIDTH*DEC_NUM
`define RAM_ADR_WIDTH  10  // the size of ram is 1024bits, letting it be pow of two makes address generation work well.
`define OUT_STAGE_RADIX  5    // the number of stages of one traceback output. It should be pow of two. The stage is the stage of encode lattice of radix r.
`define OUT_NUM_RADIX  6 // radix of output number of DECS of one traceback action. It is equal U+OUT_STAGE_RADIX
`define OUT_STAGE   32    // 2^OUT_STAGE_RADIX

`define SLICE_NUM  2    //2^u
`define CODE_LEN  32768    // the length of the code source.
`define CLK_TIME  1  // the cycle time of clock mclk

module test_fix_data;
reg unpunctured_code[`CODE_LEN-1:0];
reg mclk;
reg rst;
reg valid_in;
reg[`Bit_Width-1:0] symbol0, symbol1;
reg[`SYMBOLS_NUM-1:0] pattern;
integer i, j;

initial $readmemb("../../testvector/91_121_101_91/code_8192_32768.dat", unpunctured_code);
initial 
begin
   	mclk=1;
   	rst=1;
   	pattern=`SYMBOLS_NUM'b11;
    valid_in=0;
   	# 50 rst=1;
   	# 5000 rst=0;
end

initial forever # `CLK_TIME mclk=~mclk;

always @(posedge mclk or posedge rst)
begin
    if(rst)
		begin
			i=0;
			j=0;
			valid_in<=0;
		symbol0<=0;
		symbol1<=0;
		pattern<=`SYMBOLS_NUM'b11;
		end
    else
		begin
		if(j==0) 
			begin
				valid_in<=1;
				if(unpunctured_code[i+0]==1'b1)
					symbol0<=`Bit_Width'b111;
				else
					symbol0<=`Bit_Width'b000;
				
				if(unpunctured_code[i+1]==1'b1)
					symbol1<=`Bit_Width'b111;
				else
					symbol1<=`Bit_Width'b000;
			
			end
		j=j+1;
        if(j==`SLICE_NUM)
			begin
				i=i+`SYMBOLS_NUM;
				j=0;
			end
        if(i==`CODE_LEN)
            $finish;
		end
end

wire decoder_out, decoder_en;
            
decoder decoder_i
(
    .mclk(mclk), 
    .rst(rst), 
    .valid_in(valid_in), 
    .symbol0(symbol0), 
    .symbol1(symbol1), 
    .pattern(pattern), 
    .bit_out(decoder_out), 
    .valid_out(decoder_en)
);
////////////////////////////////// test module //////////////////////////////////////////////////////////

integer f_decoder_out, line;
reg source_data[`CODE_LEN-1:0];
integer data_count;
initial
begin
line=0; 
data_count=0;
f_decoder_out=$fopen("f_decoder_out");
end
initial $readmemb("../../testvector/91_121_101_91/data_8192_32768.dat", source_data);
always @(posedge mclk or posedge rst)
begin
    if(!rst)     // it is not reset
    begin
        if(decoder_en)
        begin
            if(decoder_out!==source_data[data_count]) begin
                $display("missmatch at line %d\n", data_count);
                $fwrite(f_decoder_out, "missmatch! %b, %b\n", decoder_out, source_data[data_count]);
            end else begin 
                if(data_count!=0 && data_count%256==0) $display(" compare data is correct at %d\n", data_count);
                $fwrite(f_decoder_out,"%b", {decoder_out});
                $fwrite(f_decoder_out,"\n");
            end
            data_count=data_count+1;
            
            /*
            $fwrite(f_decoder_out,"%b", {decoder_out});
            if(line%4==3)
            begin
                $fwrite(f_decoder_out,"\n");
            end
            if(line%16==15)
            begin
                $fwrite(f_decoder_out,"\n");
            end
            line=line+1;
            */
        end
    end
end
endmodule
