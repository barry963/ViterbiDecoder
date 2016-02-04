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
#              this file is a collection of all script files. I would like to assemble
#              them into one document. so easy to compile. There are some problems in
#              this version.
#  version 1.1 update date: 2006/7
#/usr/bin/perl
#use strict;
all();

sub all {
print "helllllo\n";
if($#ARGV>=1){
#	print @ARGV, "\n";
	%argv=@ARGV;
#	print $argv{'-POLYS'}, "\n";
}
else {die "no arguments input\nusage: command -POLYS \"91 121 101 91\" -B 3 -V 1 -RAW 10 -OSR 4 -TBL 32\n";}

para_initial();
butfly2(\$mod_name, \@ports_names);
delayT($mod_name, @ports_names);
def_initial();
print "B=",$B,", $para_symbol_num, $W, $V, $U  @para_polys\n";
genfile("glb_def.v", \&glb_def);
genfile("ctrl.v", \&ctrl);
genfile("filo.v", \&filo);
genfile("pe.v", \&pe);
genfile("smu.v", \&smu);
genfile("traceback.v", \&traceback);
genfile("virtual_mem.v", \&virtual_mem);
genfile("vit.v", \&vit);
genfile("decoder.v", \&decoder);
genfile("encoder.v", \&encoder);
genfile("../../bench/verilog/testbench.v", \&testbench);
genfile("../../c/encode.cpp", \&encode);
genfile("../../c/vit.cpp", \&vit2cpp);
print "1";		## tell outside it is ok

}
#########################################################################################
##  Initial global parameters
sub para_initial()
#########################################################################################
{
	print "hello world \n";
	my ($bar, $i, $j, $k);
	$bar = 0, $j=0;
	
	$Timescale="1ns/10ps";
#	$SM_Width=9;
#	$Bit_Width=3;
#	$BM_Width=5;
	$home_dir=exists($argv{'-HOMEDIR'})?$argv{'-HOMEDIR'}:".";
	$module_dir="$home_dir/rtl/verilog";
	
# 	$para_symbol_num = 4;
# 	$para_conv_m = 6;
# 	$para_conv_k = $para_conv_m+1;
	@para_polys = exists($argv{'-POLYS'})?split(' ', $argv{'-POLYS'}):split(' ',"91 121 101 91");
#( 0133, 0171, 0145, 0133);	## This is important. k=7;
	# Rate 1/2 codes
	#@para_polys = (0x7,0x5);		# k=3
	#@para_polys = (0xf,0xb);		# k=4
	#@para_polys = (0x17, 0x19);		# k=5
	#@para_polys = (0x13, 0x1b);		# k=5, used in GSM?
	#@para_polys = (0x2f, 0x35);		# k=6
	#@para_polys = (0x6d,0x4f);		# k=7; very popular with NASA and industry
	#@para_polys = (0x9f, 0xe5);		# k=8
	#@para_polys = (0x1af, 0x11d);	# k=9; used in IS-95 CDMA
	#@para_polys = (0x45dd, 0x69e3);	# k = 15
	
	
	# Rate 1/3 codes
	#@para_polys = (0x7, 0x7, 0x5);	#k = 3
	#@para_polys = (0xf, 0xb, 0xd);	#k = 4
	#@para_polys = (0x1f, 0x1b, 0x15);	#k = 5
	#@para_polys = (0x2f, 0x35, 0x39);	#k = 6
	#@para_polys = (0x4f, 0x57, 0x6d);	#k = 7; also popular with NASA and industry
	#@para_polys = (0xef, 0x9b, 0xa9);	#k = 8
	#@para_polys = (0x1ed, 0x19b, 0x127); #k = 9; used in IS-95 CDMA
	
	$mod_name ="";
	@ports_names = ();
	%global_butfly_instance_name = ();
	foreach $i (@para_polys){
		$j++;
		$bar |= $i;
	}
	$k = 0;
	while($bar != 0){
		$k++;
		$bar >>= 1;
	}
	die "Max K=16 supported" if ($k > 16 || $k<2);
	$para_conv_k  = $k;
	$para_conv_m = $k - 1;
	$para_state_num=2**$para_conv_m;
	$para_symbol_num = $j;
	$Bit_Width=3;
	$BM_MAX=(2**$Bit_Width-1)*$para_symbol_num;
	$j=$BM_MAX;
FOR_BMW:for($i=0;$i<100;$i++){
		last FOR_BMW if($j==0);
		$j>>=1;
	}	
	$BM_Width=$i;		#5
	$k=log($para_conv_k*$BM_MAX+1)/log(2) + 1;
	$SM_Width=int($k);
	if($SM_Width<$k){
		$SM_Width++;
		$SM_Width>=$k or die " `SM_Width must be larger than $k\n";
	}
# 	print "HHHHHHHHHHHHEEEEEEELLLLLLLOOOOOOOOOOOO, 
# 	SM_Width is $SM_Width, 
# 	BM_Width is $BM_Width,
# 	Bit_Width is $Bit_Width
# 	";
	@para_file_head = ("//This is a head\n");
	@para_file_predef = ("//This is a predefine\n",
			"`ifndef GLOBAL_DEFINES\n",
			"`timescale $Timescale\n",
			"`define SM_Width $SM_Width\n",
			"`define Bit_Width $Bit_Width\n",
			"`define BM_Width $BM_Width\n",
			"`define SYMBOLS_NUM $para_symbol_num\n",
			"`define GLOBAL_DEFINES\n",
			"`endif\n");
	print @para_file_predef;
}

sub def_initial()
{
my $i;
## $B=3, $V=1
$B=exists($argv{'-B'})?$argv{'-B'}:3;
$V=1;		##exists($OPTS{'-V'})?$OPTS{'-V'}:1;
$OUT_STAGE_RADIX=exists($argv{'-OSR'})?$argv{'-OSR'}:4;
$TRACE_BACK_LEN = exists($argv{'-TBL'})?$argv{'-TBL'}:32;
$RAM_ADR_WIDTH=exists($argv{'-RAW'})?$argv{'-RAW'}:10;
############################# up is manually configured ###########################################
############################# down is auto generated ##############################################
# $BIG=1;			# BIG is width of MAX_BIG_SLICE;
$U=$B*$V, $W=$para_conv_m-$U-$V;
## for some reason, such as S.A.W.B(same address write back) and using banks in SMU, $U should not be smaller than $V;
## this is not a bug, there is only one case for $u<$v, that is $b=0;
## at this case there are some design problems I don't consider them clearly.
die " \$V could not be smaller than \$U\n" if($U<$V); 
## let b*v is the minizal common multiple of (u+v) and v, then b is the max big slice
$MAX_BIG_SLICE=$B+1;	# simply it is (u+v);
## defines for trace back
# $OUT_STAGE_RADIX=4;
# $TRACE_BACK_LEN = 32;
# $RAM_ADR_WIDTH=10;
OUTTER1:for($BIG=0;$BIG<10;$BIG++){
	last OUTTER1 if((2**$BIG)>=$MAX_BIG_SLICE);
}
$MAX_SLICE=2**$U;
$NUM_DEC_TBU=2**($W+$V);
$OUT_STAGE=2**$OUT_STAGE_RADIX;
$OUT_NUM_RADIX = $U+$OUT_STAGE_RADIX;
$OUT_NUM = 2**$OUT_NUM_RADIX;
$RAM_BYTE_WIDTH = $NUM_DEC_TBU*$V;
$RAM_BYTES_NUM=2**$RAM_ADR_WIDTH;
$DUMMY_BLOCK_NUM=int($TRACE_BACK_LEN/$OUT_STAGE);
## 
OUTTER2:for($DUMMY_CNT_WIDTH=0;$DUMMY_CNT_WIDTH<100;$DUMMY_CNT_WIDTH++){
	last OUTTER2 if((2**$DUMMY_CNT_WIDTH)>$DUMMY_BLOCK_NUM);
}

for($i=0;$i<$NUM_DEC_TBU;$i++){
	push @DECS_TBU, "dec$i";
	push @NUMS_DEC_TBU, "$i";
}
@RD_DECS_TBU=prefix("rd_", \@DECS_TBU,"");

## defines for PE
$PATH_NUM=2**$V;
@SYMBOLS=();
@PE_Z=();
@PE_SMS=();
@PE_DECS=();
$PE_SM_NUM=2**($U+$V);
$PES_NUM=2**$W;
for($i=0;$i<2**$W;$i++){
	push @PES, "pe$i";
	push @PE_W, "$i";
}

for($i=0;$i<$para_symbol_num;$i++){
	push @SYMBOLS,"symbol$i";
}
for($i=0;$i<$PATH_NUM;$i++){
	push @PE_Z, "$i";
	push @PE_SMS, "sm$i";
	push @PE_DECS, "dec$i";
}
@in_sms=prefix("in_", \@PE_SMS);
@out_sms=prefix("out_", \@PE_SMS);
@wire_decs=prefix("wire_", \@PE_DECS);
@wr_sms=prefix("wr_", \@PE_SMS);
@rd_sms=prefix("rd_", \@PE_SMS);
@old_sms=prefix("old_", \@PE_SMS);
@new_sms=prefix("new_", \@PE_SMS);
@adrs=prefix("adr", \@PE_Z);
@wire_adrs=prefix("wire_", \@adrs);
@reg_symbols=prefix("reg_", \@SYMBOLS);
@adrs_shift=prefix("",\@adrs,"_shift");
}

sub decoder0()
{
my ($i,$j, $reg_valid_in, @reg_symbols, $reg_pattern); 

my @text=("

`include \"$module_dir/glb_def.v\"

`define RAM_BYTE_WIDTH $RAM_BYTE_WIDTH
`define RAM_ADR_WIDTH $RAM_ADR_WIDTH 

module decoder0(mclk, rst, valid_in, ", join(", ", @SYMBOLS), ", pattern, filo_out, valid_out);
input mclk, rst, valid_in;
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;           //////////////////////////////////////////////
output filo_out, valid_out;

wire valid_decs;
wire[`V-1:0] ", join(", ", @DECS_TBU), ";
wire wr_en, rd_en, en_filo_in;
wire[`V-1:0] filo_in;
wire[`RAM_BYTE_WIDTH - 1:0] wr_data, rd_data;
wire[`RAM_ADR_WIDTH - 1:0] wr_adr, rd_adr;



vit2 vit2_0(.mclk(mclk), .rst(rst), .valid(valid_in), .", join(", .", party(\@SYMBOLS, \@SYMBOLS)), ", .pattern(pattern), .", join(", .", party(\@DECS_TBU, \@DECS_TBU)), ", .valid_decs(valid_decs));
trabacknew2 traback0(.clk(mclk), .rst(rst), .valid_in(valid_decs), .", join(", .", party(\@DECS_TBU, \@DECS_TBU)), ", .wr_en(wr_en), .wr_data(wr_data), .wr_adr(wr_adr), .rd_en(rd_en), .rd_data(rd_data), .rd_adr(rd_adr), .en_filo_in(en_filo_in), .filo_in(filo_in));
virtual_mem #($RAM_BYTE_WIDTH,$RAM_ADR_WIDTH) virtual_mem0(.clk(mclk), .rst(rst), .wr_data(wr_data), .wr_adr(wr_adr), .wr_en(wr_en), .rd_adr(rd_adr), .rd_en(rd_en), .rd_data(rd_data));
filo filo0(.clk(mclk), .rst(rst), .en_filo_in(en_filo_in), .filo_in(filo_in), .en_filo_out(1'b1), .filo_out(filo_out), .valid_out(valid_out));
`ifdef DEBUG
////////////// for debug ////////////////////////////////////
integer f_debug, line;
initial
begin
line=0; 
f_debug=\$fopen(\"data/f_debug\");
end
always @(posedge mclk or posedge rst)
begin
    if(!rst) // if not reset
      if(valid_decs)
        begin
            \$fwrite(f_debug,", '"%b\n",',"{", join(", ", @DECS_TBU),"});
             line=line+1;
	     if(line%$MAX_SLICE\==0)
             begin
                 \$fwrite(f_debug,\"\\n\");
             end
//             if(line%16==15)
//             begin
//                 \$fwrite(f_debug,\"\\n\");
//             end
        end
end
`endif
endmodule
");
print @text;
}


##############################################################################
##
##
sub butfly2(\$\@)
##############################################################################
{
	my ($mod_name, $ports_names) = @_;
	my ($i,$print_head);
	my ($PREHANDLE, $FILE1);
	$print_head = 1;
	$$mod_name = "butfly2";
	return if exists $global_butfly_instance_name{$$mod_name}; 
	@$ports_names = ();
	open($FILE1,">$module_dir/$$mod_name.v") or die "Couldn't open $$mod_name.v, $!\n";;
	$PREHANDLE = select;
	select $FILE1;
	print_head($print_head);
# 	print "`ifndef ACS2
# 	`include \"$module_dir/acs2.v\"
# 	`define ACS2
# `endif
# ";
# 	print "`ifndef BRAMETER2
# 	`include \"$module_dir/brameter2.v\"
# 	`define BRAMETER2
# `endif
# ";
	print "module $$mod_name(";
	push  @$ports_names , "old_sm0", "old_sm1","state_cluster";
	for($i=0;$i<$para_symbol_num;$i++){
		push @$ports_names, "symbol$i";
	}
	push @$ports_names, "pattern";
	push @$ports_names, "new_sm0","new_sm1";
	push @$ports_names, "dec0","dec1";
	print join(', ', @$ports_names), ");\n";
	print "    parameter SM_Width=`SM_Width;
   	parameter BM_Width=`BM_Width; 
	parameter Bit_Width=`Bit_Width;
    ";
     	print "
	input[SM_Width-1:0] old_sm0, old_sm1;
	input[$para_conv_m-2:0] state_cluster;
	input[Bit_Width-1:0]";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print  " symbol$i,";
	}
	print " symbol$i;\n";
	print "input[`SYMBOLS_NUM-1:0] pattern;
output[SM_Width-1:0] new_sm0, new_sm1;
output dec0, dec1;

wire[BM_Width-1:0] wire_bm00, wire_bm01, wire_bm10, wire_bm11;

acs2 unit_acs2(  .old_sm0(old_sm0), .old_sm1(old_sm1), .bm00(wire_bm00), .bm01(wire_bm01), .bm10(wire_bm10), .bm11(wire_bm11), .new_0sm(new_sm0), .new_1sm(new_sm1), .dec0(dec0), .dec1(dec1));

brameter2 unit_brameter2( .state_cluster(state_cluster),  ";
	for($i=0;$i<$para_symbol_num;$i++){
		print  ".symbol$i(symbol$i), ";
	}
	print ".pattern(pattern), .bm00(wire_bm00), .bm01(wire_bm01), .bm10(wire_bm10), .bm11(wire_bm11));
endmodule
";
	my ($sub_mod_name, @sub_ports_names);
	$sub_mod_name = "adf";
	@sub_ports_names = ("asd");
	acs2($sub_mod_name, @sub_ports_names, 1, 0);
	brameter2($sub_mod_name, @sub_ports_names, 1,0);
	
	close($FILE1) or die "Couldn't close $$mod_name.v, $!\n";
	$global_butfly_instance_name{$$mod_name}=@$ports_names;
	select $PREHANDLE;
}

sub ctrl()
{
my $i;
my @piece_slices;
foreach $i (1..$B){
	push(@piece_slices ,"next_slice[".($i*$V-1).":".($i*$V-$V)."]");
}
my @next_adrs_shift=prefix("next_",\@adrs_shift,"");

print "`include \"$module_dir/glb_def.v\"\n";

## print the slice defines #####################
print "// the total number of all slices is 2^u\n";
for($i=0;$i<$MAX_SLICE;$i++){
	print "`define SLICE_$i `U'd$i\n";
}
print "// let max_big_slice equal to b, then b*v is the minizal common multiple of (u+v) and v\n";
for($i=0;$i<$MAX_BIG_SLICE;$i++){
	print "`define BIG_SLICE_$i `BIG'd$i\n";
}
print "//LAST_BIG_SLICE_AND_SLICE is (MAX_BIG_SLICE-1)*2^u - 1, which is {BIG_SLICE_LAST,SLICE_ZERO}\n";
print "`define LAST_BIG_SLICE  `BIG'd",($MAX_BIG_SLICE-1)," //(MAX_BIG_SLICE-1), LAST_BIG_SLICE is the last big slice we want, equal to (b-1)
`define LAST_SLICE `U'd", ($MAX_SLICE-1), " // The last slice

module ctrl(mclk, rst, valid, ", join(", ", @SYMBOLS), ", pattern, 
valid_slice, slice, shift_cnt, ", join(", ", @adrs_shift, @reg_symbols), ", reg_pattern, valid_decs);

input mclk, rst, valid;
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;           //////////////////////////////////////////////

output[`U-1:0] slice;
output[`V-1:0] shift_cnt;      ///////// 
output[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////
output[`Bit_Width-1:0] ", join(", ", @reg_symbols), ";
output[`SYMBOLS_NUM-1:0] reg_pattern;           //////////////////////////////////////////////
output valid_slice, valid_decs;

reg valid_slice;
reg[`U-1:0] slice;
reg[`V-1:0] shift_cnt;      
reg[`BIG-1:0] big_slice;
reg[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////

wire[`U-1:0] next_slice;
wire[`V-1:0] next_shift_cnt; 
reg[`BIG-1:0] next_big_slice;
wire[`BIG-1:0] tmp_next_big_slice;
wire[`U+`V-1:0] ", join(", ", parties(\@wire_adrs, "={next_slice,`V'd",\@PE_Z, "}")), ";
reg[`U-1:0] ",join(", ", @adrs), ";             /////////////////////////////
reg[`U-1:0] ",join(", ", @next_adrs_shift), ";             /////////////////////////////

delayT #(`Bit_Width*`SYMBOLS_NUM+`SYMBOLS_NUM+1,1) delayT_symbols(.mclk(mclk), .rst(rst), .in({", join(", ", @SYMBOLS), ", pattern, valid_slice}), .out({", join(", ", @reg_symbols), ", reg_pattern, valid_decs}));
 
always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin
        {big_slice,slice} <= {`LAST_BIG_SLICE,`LAST_SLICE};    /////////////////////
	valid_slice<=0;
	shift_cnt<=0;", prefix("
	",\@adrs_shift,"<=0;"),"
    end
    else if(slice==`LAST_SLICE)
    begin
	if(valid)
	begin
		slice<=next_slice;
		big_slice<=next_big_slice;
		valid_slice<=1;
		shift_cnt<=next_shift_cnt;
		",parties(\@adrs_shift,"<=",\@next_adrs_shift,";
		"),"
	end
	else
	begin
		valid_slice<=0;
	end
    end
    else
    begin
    	slice<=next_slice;
	big_slice<=next_big_slice;
	shift_cnt<=next_shift_cnt;
	",parties(\@adrs_shift,"<=",\@next_adrs_shift,";
	"),"
    end
end
assign {tmp_next_big_slice,next_slice}={big_slice,slice}+1;

always @(tmp_next_big_slice or big_slice or slice)
begin
    if({big_slice,slice}=={`LAST_BIG_SLICE,`LAST_SLICE})           /////////////////////
    begin
        next_big_slice=`BIG_SLICE_0;
    end
    else
    begin
        next_big_slice=tmp_next_big_slice;
    end
end

// `U must larger than or equal to `V, and `U must be multiple of `V. Only under this
// condition, the following address generator is right.
// bank = state[v-1:0]+state[2v-1:v]+..+state[u-1:u-v], u must be the multiple of v.
assign next_shift_cnt=", join($V>1?"+":"^", @piece_slices), ";

// get the first U bits (get x) of wire_adrs(after shift)
always @(next_big_slice or ", join(" or ", @wire_adrs),")
begin
    case(next_big_slice)";for($i=0;$i<$MAX_BIG_SLICE;$i++){print "
	$i:
	begin ";for($j=0;$j<$PATH_NUM;$j++){print "
	    ",$adrs[$j],
	    "={";for($k=$U+$V-1;$k>$V;$k--){print 
	    $wire_adrs[$j],"[", ($k+($MAX_BIG_SLICE-$i)*$V)%($U+$V), "], ";} print
	    $wire_adrs[$j],"[", ($k+($MAX_BIG_SLICE-$i)*$V)%($U+$V), "]};"} print "
	end";} print "
	default:;
    endcase
end

// for using banks in SMU, we should shift down the read addresses order by barriel shift
always @(next_shift_cnt or ", join(" or ", @adrs),")
begin
    case(next_shift_cnt)";for($i=0;$i<$PATH_NUM;$i++){print "
	$i:
	begin";for($j=0;$j<$PATH_NUM;$j++){print "
	    ",$next_adrs_shift[$j],
	    "=",$adrs[($j+$PATH_NUM-$i)%$PATH_NUM],";"} print "
	end";} print "
	default:;
    endcase
end

endmodule
";
}


sub encode8()
{
my ($i);
my $patn_len=6;
my @PATTERN= ("1", "1", "1", "1", "1", "1");

print "
#include<iostream>
#include<math.h>
#define CONV_M $para_conv_m
#define SYMBOL_BITS $para_symbol_num
using namespace std;

const int  patn_len=$patn_len;

int main()
{
  int pattern[patn_len]={", join(", ", @PATTERN),"};
  int patn_cnt=0;
  int mem;
  unsigned char m[CONV_M+1];
  unsigned char in;  //input 0 or 1
  unsigned char out=0;
  int flag=0;
  mem=0;  
  while(!cin.eof()&&cin>>in){
    if(!(in=='0' || in=='1')) continue;
    in-='0';
    int v_shift=0x01;
// for some things, the m[i] is newer than m[j], if i>j; because when I write the gen_poly function, I think bit is from high bits move to low bits and new bit commes into m from high bits. 
    m[CONV_M]=in;
    for(int i=0;i<CONV_M;i++,v_shift<<=1)
      {
        m[CONV_M-1-i]=(mem&v_shift)==0? 0 : 1;   
      }";
    @polys=gen_polys("m", "^");
    for($i=0;$i<$para_symbol_num;$i++){ print "
    if(pattern[patn_cnt+$i])
        cout<<(unsigned char)(",$polys[$i],"+'0')<<' ';  // send x$i";
    } print "
    patn_cnt+=$para_symbol_num;	
    patn_cnt%=patn_len;
     
    mem<<=1;   // input bits set to the low bits
    mem|=in;
  }
  return 0;
}
";
}
#/usr/bin/perl
sub filo()
{
my ($i, $j);

print "`include \"$module_dir/glb_def.v\"\n";
print "
`define OUT_STAGE_RADIX $OUT_STAGE_RADIX     // the number of stages of one traceback output. It should be pow of two. The stage is the stage of encode lattice of radix r.
`define OUT_STAGE       $OUT_STAGE       // 2^OUT_STAGE_RADIX

module filo(clk, rst, en_filo_in, filo_in, en_filo_out, filo_out, valid_out);
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
        if(push_or_pop==0)          //push
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
        else                        //pop
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

sub glb_def()
{
print "
`timescale $Timescale
`define SM_Width $SM_Width 
`define Bit_Width $Bit_Width 
`define BM_Width $BM_Width 
`define SYMBOLS_NUM $para_symbol_num

`define U $U
`define V $V
`define W $W



`define BIG $BIG           // the width of big slice
";
}



###############################################################
sub print_head($)
###############################################################
{
	my $print_brief = !(shift);
	if($print_brief!=1){
		print "@para_file_head\n";
		print "@para_file_predef";
	print "///////////////////////////////////////////////////////////////////\n\n";
	}
}

################################################################
## Generate acs2 module code 
## Module name:
## butterfly(input old_sm0, old_sm1, 
##	bm00, bm01, bm10, bm11,
##	output new_0sm, new_1sm,
##	dec0, dec1
##	);
## 
## sm0 = [xxx...xx0], sm1 = [xxx...xx1], 0sm = [0xxx...xx], 1sm = [1xxx...xx];
##              bm00
## [xxx...xx0] \--/ [0xxx...xx]
##              \/bm10
##              /\bm01
## [xxx...xx1] /--\ [1xxx...xx]
##              bm11
sub acs2(\$ \@ $ $)
###############################################################
{
	my ( $mod_name, $ports_names,$print_head,$flag_regout) = @_;
	my $file_name ; 
	if($flag_regout==1){
		$$mod_name = "acs2regout";
		$file_name = "acs2regout.mod";
	} 
	else{
		$$mod_name = "acs2";
		$file_name = "acs2.mod";
	}

	 @$ports_names = ( "old_sm0", "old_sm1", "bm00", "bm01", "bm10", "bm11", "new_0sm", "new_1sm", "dec0", "dec1");
	my ($PREHANDLE, $FILE1, $FILE2);
	return if exists $global_butfly_instance_name{$$mod_name};
	@$ports_names = (); 
	open($FILE1,">$module_dir/$$mod_name.v") or die "Couldn't open $$mod_name.v, $!\n";
	$PREHANDLE = select;
	select $FILE1;
	print_head($print_head);
	open($FILE2, "<$script_dir/$file_name") or die "Couldn't open $file_name, $!\n";
	@content = <$FILE2>;
	print @content,"\n";
	close($FILE1) or die "Couldn't close $$mod_name.v, $!\n";
	close($FILE2) or die "Couldn't close $file_name, $!\n";
	$global_butfly_instance_name{$$mod_name}=@$ports_names;
	select $PREHANDLE;
}  ##butterfly
# acs2();

########################################################################################
#
#
sub delayT(\$ \@)
########################################################################################
{
	my ($mod_name, $ports_names) = @_;
	 @$ports_names = ("mclk", "rst", "in", "out");
	$$mod_name = "delayT";
	my ($PREHANDLE, $FILE1);
	return if exists $global_butfly_instance_name{$$mod_name}; 
	@$ports_names = ();
	open($FILE1,">$module_dir/$$mod_name.v") or die "Couldn't open $$mod_name.v, $!\n";
	$PREHANDLE = select;
	select $FILE1;
	print <<"EOF";
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
EOF
	close $FILE1;
	$global_butfly_instance_name{$$mod_name}=@$ports_names;
	select $PREHANDLE;
}

#########################################################################################
##  Generate instance of module dicated by $module_name
##  Usege: instance($mod_name,$ins_name, @mod_ports,@ins_ports)
##  $1 is name of instance, @2 is the wire names of interface.
sub instance($$\@\@)         
#########################################################################################
{
	my ($mod_name, $ins_name, $mod_ports, $ins_ports) = @_;
# 	my @module_ports = ("mclk", "old_sm0", "old_sm1", "bm00", "bm01", "bm10", "bm11", # 			 "new_0sm", "new_1sm", "dec0", "dec1");
 	my $port_num = @$mod_ports;
	my $i = 0;
	print "$port_num @$mod_ports" if defined($debug);
	print "$mod_name unit_$ins_name(";
	for($i=0;;){
		print ".",$$mod_ports[$i],"(",$$ins_ports[$i],")";
		$i++;
		if($i<$port_num){
			print ", ";
		}
		else{
			print ");";
			last;
		}
	}
	
}

# $ins_name = "acs201";
# @ins_ports = ("mclk", "old_sm0", "old_sm1", "bm00", "bm01", "bm10", "bm11", 
# 			 "new_0sm", "new_1sm", "dec0", "dec1");
# ins_acs2($ins_name, @ins_ports);


#########################################################################################
##  Generate the poly-norm
sub gen_polys($$)
#########################################################################################
{
	my ($term, $func) = @_;
	my (@polys, @polys_tmp, $i);
	$i=0;
	foreach $poly (@para_polys){
		@polys_tmp = ();
		for($i=$para_conv_k-1;$i>=0;$i--){
			if($poly&(1<<$i)){
				push @polys_tmp, "$term\[$i]";
			}
		}
		push @polys, join($func, @polys_tmp);
	}
	return @polys;
}

#########################################################################################
##  Generate the common part of poly-norm
sub gen_common_polys($$)
#########################################################################################
{
	my ($term, $func) = @_;
	my (@polys, @polys_tmp, $i, $tmp);
	$i=0;
	foreach $poly (@para_polys){
		@polys_tmp = ();
		for($i=$para_conv_k-1;$i>=0;$i--){
			if(($poly&(1<<$i))&&!($i==0||$i==$para_conv_m)){
				push @polys_tmp, "$term\[$i]";
			}
		}
		$tmp=@polys_tmp;
		push @polys, ($tmp==0)?0:join($func, @polys_tmp);
	}
	return @polys;
}

#########################################################################################
##  Generate the symbol flags, which is used to flip the branch-mertic.
sub gen_symbol_flags()
#########################################################################################
{
	my (@symbol_flags, $poly, $i);
	foreach $poly (@para_polys){
		if(($poly&1)&&($poly&(1<<$para_conv_m))){
			push @symbol_flags, "1001";  #has a[6] and a[0], so bm00, bm01, bm10, bm11
		}
		elsif(!($poly&1)&&($poly&(1<<$para_conv_m))){
			push @symbol_flags, "1010";  #has a[6]
		}
		elsif(($poly&1)&&!($poly&(1<<$para_conv_m))){
			push @symbol_flags, "1100";  #has a[0]  
		}
		else{
			push @symbol_flags, "1111";  #has not a[6] or a[0]
		}
	}
	return @symbol_flags;
}

#########################################################################################
##  Print $i from 0 to $_[1] with prefix $_[0] and subfix $[2];
sub mprint($$$)
#########################################################################################
{
	my ($prefix, $times, $subfix) = @_;
	my $i;
	for($i=0;$i<$times;$i++){
		print $prefix, $i, $subfix;
	}
}

#####################################################################
## Generate brameter module code which bring out the branch metric
## Usage: brameter($print_head, $flag_reg_output)
## 		$print_head: print head text or not?
##		$flag_reg_output: Is the output flip-flop or wire?
## Module name:
## brameter( input symbol, pattern, state_cluster, 
##		output bm00, bm01, bm10, bm11);
## 
sub brameter2(\$\@$$)
####################################################################
{
	my ($mod_name, $ports_names, $print_head, $flag_reg_output) = @_;
	my $i;
	my ($PREHANDLE, $FILE1);
	$$mod_name = "brameter2";
	return if exists $global_butfly_instance_name{$$mod_name};
	@$ports_names = (); 
	open($FILE1,">$module_dir/$$mod_name.v") or die "Couldn't open $$mod_name.v, $!\n";;
	$PREHANDLE = select;
	select $FILE1;
	print_head($print_head);
	print "module $$mod_name(";
	push @$ports_names,"mclk" if(flag_reg_output==1);
	push @$ports_names,"state_cluster";
	for($i=0;$i<$para_symbol_num;$i++){
		push @$ports_names,"symbol$i";
	}
	push @$ports_names,"pattern","bm00", "bm01", "bm10", "bm11";
	print join(', ', @$ports_names), ");\n";
	print "parameter Bit_Width=`Bit_Width;
parameter BM_Width=`BM_Width;\n";
	print "input mclk;\n" if(flag_reg_output==1);
	print "input[",$para_conv_m-2,":0] state_cluster;\n";
	print "input[Bit_Width-1:0] ";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print "symbol$i, ";
	}
	print "symbol$i;\n";
	print "input[`SYMBOLS_NUM-1:0] pattern;
output[BM_Width-1:0] bm00, bm01, bm10, bm11;
reg[BM_Width-1:0] bm00, bm01, bm10, bm11;\n\n";
	my @bm_names = ("bm00","bm01","bm10","bm11");
	foreach $bm_name (@bm_names){
		print "reg[Bit_Width-1:0] ";
		for($i=0;$i<$para_symbol_num-1;$i++){
			print $bm_name,"_$i, ";
		}
		print $bm_name,"_$i;\n";
	}
	print "\n";
	
	foreach $bm_name (@bm_names){
		print "reg[Bit_Width-1:0] ";
		for($i=0;$i<$para_symbol_num-1;$i++){
			print "pn_",$bm_name,"_$i, ";
		}
		print "pn_",$bm_name,"_$i;\n";
	}
	print "\nwire[",$para_symbol_num-1,":0] common_part;\n";
	print "wire[", $para_conv_k-1, ":0] a;
assign a={1'b0,state_cluster,1'b0};\n";

	my @polys = gen_common_polys("a", "^");
	print "$para_symbol_num\n" if defined($debug);
	for($i=0;$i<$para_symbol_num;$i++){
		print "assign common_part[$i] = ",$polys[$i],";\n";
		print "one\n" if defined($debug);
	}
	
	print "\nalways @(common_part or pattern";
	mprint(" or symbol",$para_symbol_num,"");
	print ")\nbegin\n";
	my @symbol_flags = gen_symbol_flags();
	my $sub,;
	my @subs=(" ", "~");
	for($i=0;$i<$para_symbol_num;$i++){
		print "\tif(common_part[$i])\n", "\tbegin\n";
		$sub = substr($symbol_flags[$i],0,1);
		print "\t\tbm00_$i=",$subs[$sub],"symbol$i;\n";
		$sub = substr($symbol_flags[$i],1,1);
		print "\t\tbm01_$i=",$subs[$sub],"symbol$i;\n";
		$sub = substr($symbol_flags[$i],2,1);
		print "\t\tbm10_$i=",$subs[$sub],"symbol$i;\n";
		$sub = substr($symbol_flags[$i],3,1);
		print "\t\tbm11_$i=",$subs[$sub],"symbol$i;\n";
		
		print "\tend\n\telse\n\tbegin\n";
		$sub = substr($symbol_flags[$i],0,1);
		print "\t\tbm00_$i=",$subs[!$sub],"symbol$i;\n";
		$sub = substr($symbol_flags[$i],1,1);
		print "\t\tbm01_$i=",$subs[!$sub],"symbol$i;\n";
		$sub = substr($symbol_flags[$i],2,1);
		print "\t\tbm10_$i=",$subs[!$sub],"symbol$i;\n";
		$sub = substr($symbol_flags[$i],3,1);
		print "\t\tbm11_$i=",$subs[!$sub],"symbol$i;\n";
		print "\tend\n\n";
	}
	for($i=0;$i<$para_symbol_num;$i++){
		print "\tif(pattern[$i]==1)\n\tbegin\n";
		print "\t\tpn_bm00_$i=bm00_$i;\n";
		print "\t\tpn_bm01_$i=bm01_$i;\n";
		print "\t\tpn_bm10_$i=bm10_$i;\n";
		print "\t\tpn_bm11_$i=bm11_$i;\n";
		print "\tend\n\telse\n\tbegin\n";
		print "\t\tpn_bm00_$i=0;\n";
		print "\t\tpn_bm01_$i=0;\n";
		print "\t\tpn_bm10_$i=0;\n";
		print "\t\tpn_bm11_$i=0;\n";
		print "\tend\n\n";
	}
	print "end\n";
	if(flag_reg_output==1){
		print "always \@(posedge mclk)\n" ;
		$equal = "<=";
	}
	else{
		print "always \@(";
		mprint("pn_bm00_", $para_symbol_num," or ");
		mprint("pn_bm01_", $para_symbol_num," or ");
		mprint("pn_bm10_", $para_symbol_num," or ");
		mprint("pn_bm11_", $para_symbol_num-1," or ");
		print "pn_bm11_",$para_symbol_num-1,")\n"; 
		$equal = "=";
	}
	print "begin\n";
		print "\tbm00$equal";
		mprint("pn_bm00_",$para_symbol_num-1,"+");
		print "pn_bm00_",$para_symbol_num-1,";\n";
		print "\tbm01$equal";
		mprint("pn_bm01_",$para_symbol_num-1,"+");
		print "pn_bm01_",$para_symbol_num-1,";\n";
		print "\tbm10$equal";
		mprint("pn_bm10_",$para_symbol_num-1,"+");
		print "pn_bm10_",$para_symbol_num-1,";\n";
		print "\tbm11$equal";
		mprint("pn_bm11_",$para_symbol_num-1,"+");
		print "pn_bm11_",$para_symbol_num-1,";\n";
	print "end	
endmodule
";
	close($FILE1) or die "Couldn't close $$mod_name.v, $!\n";
	$global_butfly_instance_name{$$mod_name}=@$ports_names;
	select $PREHANDLE;
}


sub butfly4p(\$\@)
{
	my ($mod_name, $ports_names) = @_;
	my ($i,$print_head);
	my ($PREHANDLE, $FILE1);
	my $radix_root = 2;
	my $sc_width = $para_conv_m-$radix_root;
	$print_head = 1;
	$$mod_name = "butfly4p";
	return if exists $global_butfly_instance_name{$$mod_name};
	@$ports_names = ();
	open($FILE1,">$module_dir/$$mod_name.v") or die "Couldn't open $$mod_name.v, $!\n";;
	$PREHANDLE = select;
	select $FILE1;
	print_head($print_head);
	print '`ifndef BUTFLY2
	`include "',$module_dir,'/butfly2.v"
	`define BUTFLY2
`endif
';
	print '`ifndef DELAYT
	`include "',$module_dir,'/delayT.v"
	`define DELAYT
`endif
';
	print "module $$mod_name(";
	push  @$ports_names , "mclk", "old_sm0", "old_sm1","old_sm2", "old_sm3","state_cluster";
	for($i=0;$i<$para_symbol_num;$i++){
		push @$ports_names, "symbol0$i", "symbol1$i";
	}
	push @$ports_names, "pattern0", "pattern1";
	push @$ports_names, "new_0sm","new_1sm", "new_2sm","new_3sm";
	push @$ports_names, "delayT_dec00","delayT_dec01","delayT_dec02", "delayT_dec03", "dec10","dec11","dec12", "dec13";
	print join(', ', @$ports_names), ");\n";
	print "parameter SM_Width=`SM_Width;
   	parameter BM_Width=`BM_Width; 
	parameter Bit_Width=`Bit_Width;
    ";
     	print "input mclk;
	input[SM_Width-1:0] old_sm0, old_sm1, old_sm2, old_sm3;
	input[$sc_width-1:0] state_cluster;
	input[Bit_Width-1:0]";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print  " symbol0$i, symbol1$i,";
	}
	print " symbol0$i, symbol1$i;\n";
	print "input[`SYMBOLS_NUM-1:0] pattern0, pattern1;
output[SM_Width-1:0] new_0sm, new_1sm, new_2sm, new_3sm;
output delayT_dec00, delayT_dec01, delayT_dec02, delayT_dec03, dec10, dec11, dec12, dec13;\n";
########################### wire signals ##################################################
	print "wire[SM_Width-1:0] wire_0sm0, wire_1sm0, wire_0sm1, wire_1sm1;\n";
	print "wire[Bit_Width-1:0] ";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print  "delayT_symbol1$i, ";
	}
	print "delayT_symbol1$i;\n";
	print "wire[$sc_width-1:0] delayT_state_cluster;\n";
	print "wire ";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print  "dec0$i,";
	}
	print "dec0$i;\n";
	print "\n";
########################### delayT units ######################################################	
	print "delayT #(",2**$radix_root,", 1) unit_delayT_0( .mclk(mclk), .in({";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print  "dec0$i,";
	}
	print "dec0$i}), .out({";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print  "delayT_dec0$i,";
	}
	print "delayT_dec0$i}));\n";
##############################################################	
	print "delayT #(Bit_Width*$para_symbol_num,1) unit_delayT_1( .mclk(mclk), .in({";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print  "symbol1$i,";
	}
	print "symbol1$i}), .out({";
	my $delayT="delayT_";
	for($i=0;$i<$para_symbol_num-1;$i++){
		print  $delayT,"symbol1$i,";
	}
	print $delayT,"symbol1$i}));\n";
##############################################################
	print "delayT #(",$sc_width,",1) unit_delayT_2( .mclk(mclk), .in(state_cluster), .out(delayT_state_cluster));\n";
	print "\n";
############################# butfly one #######################################################
	print "butfly2 unit_butfly2_0( .mclk(mclk), .old_sm0(old_sm0), .old_sm1(old_sm1),  .state_cluster({state_cluster,1'b0}), ";
	for($i=0;$i<$para_symbol_num;$i++){
		print  ".symbol$i(symbol0$i), ";
	}
	print ".pattern(pattern0), .new_0sm(wire_0sm0), .new_1sm(wire_1sm0), .dec0(dec00), .dec1(dec01));\n";
############################ butfly two #######################################################	
	print "butfly2 unit_butfly2_1( .mclk(mclk), .old_sm0(old_sm2), .old_sm1(old_sm3),  .state_cluster({state_cluster,1'b1}), ";
	for($i=0;$i<$para_symbol_num;$i++){
		print  ".symbol$i(symbol0$i), ";
	}
	print ".pattern(pattern0), .new_0sm(wire_0sm1), .new_1sm(wire_1sm1), .dec0(dec02), .dec1(dec03));\n";

############################ butfly three ####################################################
	print "butfly2 unit_butfly2_2( .mclk(mclk), .old_sm0(wire_0sm0), .old_sm1(wire_0sm1),  .state_cluster({1'b0,delayT_state_cluster}), ";
	for($i=0;$i<$para_symbol_num;$i++){
		print  ".symbol$i($delayT\symbol1$i), ";
	}
	print ".pattern(pattern1), .new_0sm(new_0sm), .new_1sm(new_2sm), .dec0(dec10), .dec1(dec12));\n";
############################ butfly four ####################################################
	print "butfly2 unit_butfly2_3( .mclk(mclk), .old_sm0(wire_1sm0), .old_sm1(wire_1sm1),  .state_cluster({1'b1,delayT_state_cluster}), ";
	for($i=0;$i<$para_symbol_num;$i++){
		print  ".symbol$i($delayT\symbol1$i), ";
	}
	print ".pattern(pattern1), .new_0sm(new_1sm), .new_1sm(new_3sm), .dec0(dec11), .dec1(dec13));\n";
############################ end ###########################################################
	print "endmodule\n";
	
	my ($sub_mod_name, @sub_ports_names);
	delayT($sub_mod_name, @sub_ports_names);
	butfly2($sub_mod_name, @sub_ports_names);
	
	close($FILE1) or die "Couldn't close $$mod_name.v, $!\n";
	$global_butfly_instance_name{$$mod_name}=@$ports_names;
	select $PREHANDLE;
}

sub pe0()
{
my ($i, $j);

print "`include \"$module_dir/glb_def.v\"\n";
# print "
# module pe0(mclk, rst, valid, slice, big_slice, ", join(", ", @SYMBOLS, "pattern, in_"), join(", in_", @PE_SMS), ", out_", join(", out_", @PE_SMS), ", ",  join(", ", @PE_DECS), ");      		/////////////////////
print "
module pe0(mclk, rst, valid, slice, shift_cnt, ", join(", ", @adrs_shift, @SYMBOLS, "pattern", @in_sms, @out_sms, @PE_DECS), ");      		/////////////////////
parameter PE_ID=0;
input mclk;
input rst, valid;
input[`U-1:0] slice;
input[`V-1:0] shift_cnt;      ///////// 
input[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;           //////////////////////////////////////////////
input[`SM_Width-1:0] ", join(", ", @in_sms), ";    //////////////////////////////////////////////
output[`SM_Width-1:0] ", join(", ", @out_sms), ";   ////////////////////////////////////////////////
output[`V-1:0] ", join(", ", @PE_DECS), ";              //////////////////////////////////////////////
reg[`V-1:0] ", join(", ", @PE_DECS), ";                 //////////////////////////////////////////////

", $W>=1?"wire[`W-1:0] pe_id = PE_ID;":"","
wire[`V-1:0] ",join(", ", @wire_decs), ";
wire[`SM_Width-1:0] ", join(", ", @wr_sms), ";
butfly",$PATH_NUM," butfly",$PATH_NUM,"_0(.", join(", .", party(\@old_sms, \@in_sms)), ", .state_cluster({slice", $W>=1?",pe_id":"","}), .", join(", .",party(\@SYMBOLS, \@SYMBOLS)), ", .pattern(pattern), .", join(", .", party(\@new_sms, \@wr_sms), party(\@PE_DECS, \@wire_decs)),");
smu0 smu0_0(.mclk(mclk), .rst(rst), .valid(valid), .shift_cnt(shift_cnt), .", join(", .", party(\@adrs_shift, \@adrs_shift), party(\@wr_sms, \@wr_sms), party(\@rd_sms, \@out_sms)), ");
always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin",prefix("
	",\@PE_DECS,"<=0;        ///////////////////////////////////"), "
    end
    else if(valid)
    begin
	", parties(\@PE_DECS,"<=", \@wire_decs,";\n\t"), "
    end
end
endmodule
";
}
sub smu0()
{
my ($i,$j,$k);
my (@regfbanks);
for($i=0;$i<$PATH_NUM;$i++){
	push @regfbanks, "regfbank$i";
}


my @wr_sms_shift=prefix("",\@wr_sms,"_shift");
my @rd_sms_shift=prefix("",\@rd_sms,"_shift");

my @regfadrs=parties(\@regfbanks, "[", \@adrs_shift, "]");
my @tmp1=parties(\@regfadrs, "<=", \@wr_sms_shift, ";		//////////////////");
my @ramassign=parties(\@rd_sms_shift, " = ", \@regfadrs,";");

print "`include \"$module_dir/glb_def.v\"
";
print "
`define PE_SM_NUM $PE_SM_NUM                // 2^(`U+`V)
`define MAX_SLICE $MAX_SLICE                // 2^(`U)

// just for test, not support state-set division.   
module smu0(mclk, rst, valid, shift_cnt, ", join(", ", @adrs_shift,@wr_sms,@rd_sms), ");   /////////////////////////////////////////////
input mclk, rst, valid;
input[`V-1:0] shift_cnt;      ///////// 
input[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////
input[`SM_Width-1:0] ", join(", ", @wr_sms), ";
output[`SM_Width-1:0] ", join(", ", @rd_sms), ";

reg[`SM_Width-1:0] ", join(", ", prefix("", \@regfbanks, "[`MAX_SLICE-1:0]")), ";
reg[`SM_Width-1:0] ", join(", ", @rd_sms), ";   ///////////////////////////////////////
reg[`SM_Width-1:0] ", join(", ", @wr_sms_shift), ";
wire[`SM_Width-1:0] ", join(", ", @rd_sms_shift), ";


integer i;

// for using banks in SMU, we should shift up the read state-metrics order by barriel shift
always @(shift_cnt or ", join(" or ", @rd_sms_shift),")
begin
    case(shift_cnt)";for($i=0;$i<$PATH_NUM;$i++){print "
	$i:
	begin";for($j=0;$j<$PATH_NUM;$j++){print "
	    ",$rd_sms[$j],
	    "=",$rd_sms_shift[($j+$PATH_NUM+$i)%$PATH_NUM],";"} print "
	end";} print "
	default:;
    endcase
end
// for using banks in SMU, we should shift down the write state-metrics order by barriel shift
always @(shift_cnt or ", join(" or ", @wr_sms),")
begin
    case(shift_cnt)";for($i=0;$i<$PATH_NUM;$i++){print "
	$i:
	begin";for($j=0;$j<$PATH_NUM;$j++){print "
	    ",$wr_sms_shift[$j],
	    "=",$wr_sms[($j+$PATH_NUM-$i)%$PATH_NUM],";"} print "
	end";} print "
	default:;
    endcase
end

";
print "
always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin
        for(i=0;i<`MAX_SLICE;i=i+1)
        begin",prefix("
            ",\@regfbanks,"[i]<='b0;"),"    
        end
    end
    else if(valid)
    begin",prefix("
    	", \@tmp1, ""), "
    end
end", prefix("
assign ", \@ramassign, "  ////////////////////////////"),"

endmodule
";
}

sub testbench0()
{
my ($i, $j);

$CODE_LEN=10071;
$CODE_FILE="data/code";
$CLK_TIME=1;

print "`include \"$module_dir/glb_def.v\"\n";

print "
`define DEC_NUM $NUM_DEC_TBU           // equal to 2^(w+v)
`define RAM_BYTE_WIDTH $RAM_BYTE_WIDTH    // DEC_WIDTH*DEC_NUM
`define RAM_ADR_WIDTH  $RAM_ADR_WIDTH  // the size of ram is 1024bits, letting it be pow of two makes address generation work well.
`define OUT_STAGE_RADIX  $OUT_STAGE_RADIX    // the number of stages of one traceback output. It should be pow of two. The stage is the stage of encode lattice of radix r.
`define OUT_NUM_RADIX  $OUT_NUM_RADIX // radix of output number of DECS of one traceback action. It is equal U+OUT_STAGE_RADIX
`define OUT_STAGE   $OUT_STAGE    // 2^OUT_STAGE_RADIX

`define SLICE_NUM  $MAX_SLICE    //2^u
`define CODE_LEN  $CODE_LEN    // the length of the code source.
`define CODE_FILE  $CODE_FILE  // the file name of code source.
`define CLK_TIME  $CLK_TIME  // the cycle time of clock mclk

module testbench0;
reg code[`CODE_LEN-1:0];
reg mclk;
reg rst;
reg valid_in;
reg[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
reg[`SYMBOLS_NUM-1:0] pattern;
integer i, j;

initial \$readmemb(\"$CODE_FILE\", code);
initial 
begin
   	mclk=1;
   	rst=0;
   	pattern=`SYMBOLS_NUM'b", 1x$para_symbol_num,";
//  valid_in=0;
   	# 50 rst=0;
   	# 5000.5 rst=1;
end

initial forever # `CLK_TIME mclk=~mclk;

always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin
        i=0;
        j=0;
        valid_in<=0;",
	prefix("\n\t", \@SYMBOLS, "<=0;"),"
        pattern<=`SYMBOLS_NUM'b",1x$para_symbol_num, ";
    end
    else
    begin
        valid_in<=1;";
        for($i=0;$i<$para_symbol_num;$i++){ print 
	"\n\tif(code[i+$i]==1'b1)
		",$SYMBOLS[$i],"<=`Bit_Width'b", 1x$Bit_Width,";
	else
		",$SYMBOLS[$i],"<=`Bit_Width'b", 0 x$Bit_Width,";
	";
	} print "
	j=j+1;
        if(j==`SLICE_NUM)
        begin
            i=i+`SYMBOLS_NUM;
            j=0;
        end
        if(i==95*4*`SYMBOLS_NUM)
            \$finish;
    end
end

wire filo_out, valid_out;
            
decoder0 decoder0_0(.mclk(mclk), .rst(rst), .valid_in(valid_in), .", join(", .", party(\@SYMBOLS, \@SYMBOLS)), ", .pattern(pattern), .filo_out(filo_out), .valid_out(valid_out));
////////////////////////////////// test module //////////////////////////////////////////////////////////

integer f_filo_out, line;
initial
begin
line=0; 
f_filo_out=\$fopen(\"data/f_filo_out\");
end
always @(posedge mclk or posedge rst)
begin
    if(!rst) // if not reset
        if(valid_out)
        begin
            \$fwrite(f_filo_out,",'"%b"',", {filo_out});
            if(line%4==3)
            begin
                \$fwrite(f_filo_out,",'"\n"',");
            end
            if(line%16==15)
            begin
                \$fwrite(f_filo_out,",'"\n"',");
            end
            line=line+1;
        end
end
endmodule
";
}
sub trabacknew2()
{
my ($i, $j);
my @tmp=parties(\@NUMS_DEC_TBU, ": dec=", \@RD_DECS_TBU, ";            ///////////////////////////////////////////////////////////");
my $rd_bit_width=$W+$V;

print "`include \"$module_dir/glb_def.v\"\n";
print "
`define OUT_NUM_RADIX   $OUT_NUM_RADIX     // radix of output number of DECS of one traceback action. It is equal U+OUT_STAGE_RADIX
`define OUT_NUM         $OUT_NUM  // output number of DECS in one traceback action. It is equal 2^(U+OUT_STAGE_RADIX) and larger than TRACE_LEN.
`define LEN 		$TRACE_BACK_LEN     // trace back length. `LEN MUST smaller than `OUT_NUM
`define OUT 		$OUT_STAGE      // output decs one trace back action, 2^OUT_STAGE_RADIX, equal TRACE_LEN/n, 1<n<=2^u
`define RAM_ADR_WIDTH 	$RAM_ADR_WIDTH  // the size of ram is 1024bits, letting it be pow of two makes address generation work well.
`define DEC_NUM 	$NUM_DEC_TBU         // equal to 2^(w+v)
`define RAM_BYTE_WIDTH  $RAM_BYTE_WIDTH   // DEC_NUM*`V
`define DUMMY_BLOCK_NUM $DUMMY_BLOCK_NUM   // n=`LEN/`OUT 
`define DUMMY_CNT_WIDTH $DUMMY_CNT_WIDTH  // the width of count of dummy block

// one byte includes 2^(w+v) decs, each dec is a v-bits vector
module trabacknew2(clk, rst, valid_in, ", join(", ", @DECS_TBU), ", wr_en, wr_data, wr_adr, rd_en, rd_data, rd_adr, en_filo_in, filo_in); 
input clk, rst, valid_in;
input[`V-1:0] ", join(", ", @DECS_TBU),";                   /////////////////////////////////////////////
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
reg[`V-1:0] filo_in;			////////////////////////////// v cannot be less than 1
reg wr_en;
reg[`RAM_ADR_WIDTH-`U-1:0] rd_adr_col;
reg[`DUMMY_CNT_WIDTH-1:0] dummy_cnt;
reg Is_not_first_3blocks, During_traback, During_send_data;
reg[`W+`V+`U-1:0] state;

wire[`RAM_ADR_WIDTH-`U-1:0] dec_rd_adr_col;
wire[`DUMMY_CNT_WIDTH-1:0] inc_dummy_cnt;
wire[`RAM_ADR_WIDTH-1:0] inc_wr_adr;
wire[`V-1:0] ", join(", ", @RD_DECS_TBU), ";            ////////////////////////////////////////////
wire[`W+`V+`U-1:0] next_state;
reg[`V-1:0] dec;
"; print "wire[`U-1:0] rd_adr_byte;		///////////////////////////// u cannot be less than 1" if($U>0); print "
wire[`W+`V-1:0] rd_bit;

assign {",join(", ", @RD_DECS_TBU),"} = rd_data;       ///////////////////////////////////////////////////
assign rd_adr={rd_adr_col"; print ", rd_adr_byte" if($U>0); print "};
assign rd_en=During_traback;
assign inc_wr_adr=wr_adr+1;
assign dec_rd_adr_col=rd_adr_col-1;
assign inc_dummy_cnt=dummy_cnt+1;
assign {"; print "rd_adr_byte, " if($U>0); print "rd_bit}=state;
assign next_state={",($W+$U)>=1?"state[`W+`U+`V-1:`V], ":"", "dec};

always @(rd_bit or ", join(" or ", @RD_DECS_TBU), ")
begin
    case(rd_bit)", 
    	prefix("\n\t$rd_bit_width\'d", \@tmp,""),"
    endcase
end
// if y denote the `OUT_NUM_RADIX-1 to 0 bits of write address, x denote the column address(`RAM_ADR_WIDTH-1 to u) of write address, z denote the column address of read address, then z = x-y-1
// if y>=0 && y<=(len-out-1) trace back
// if y>=(len-out) && y<=(len-1) send out
// if y>=len && y<=(`OUT_NUM-1)  wait for next trace back
// x=wr_adr[`RAM_ADR_WIDTH-1:`U], y=wr_adr[`OUT_NUM_RADIX-1:0], z=rd_adr_col=rd_adr[`RAM_ADR_WIDTH-1:`U]

// there are four registers, one is wr_adr, the second is th wr_data, the third is reg_rd_adr(and rd_en), the fourth is reg_valid_in. All the other outputs including wr_en are combination out
// en_filo_in, en_filo_out and filo_in are registers too, but they are not the major part.
// valid_in --->> wr_adr, wr_data, wr_en --->> rd_adr, rd_en
// rd_adr++rd_data --->> filo_in 
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
    else if(valid_in)
    begin
        // if input is valid, we will always write decs into ram.
        wr_en<=1;
        wr_data<={", join(", ", @DECS_TBU), "};
        wr_adr<=inc_wr_adr; 
        // if during trace back
        if(During_traback&&Is_not_first_3blocks)   
        begin
            // Trace back. Do three things: write decs to ram , read read decs from ram for generate next read address and send data to filo
            filo_in<=rd_bit[`V-1:0];
            rd_adr_col<=dec_rd_adr_col;
	    state<={",($W+$U)>=1?"next_state[`W+`U-1:0], ":"", "next_state[`W+`U+`V-1:`W+`U]};
///////////////////////////////{rd_adr_byte, rd_bit}<={rd_adr_byte[`U-`V-1:0], rd_bit[`W+`V-1:`V], dec, rd_adr_byte[`U-1:`U-`V]};    ////////////////////    
            //{rd_adr_byte, rd_bit}<={rd_bit[`W+`V-1:`V], dec, rd_adr_byte[`U-1:`U-`V]};    ////////////////////
        end
        
        // decide whether send data to filo
        // if have trace back enough bits, we can send out dec
        if(wr_adr[`OUT_NUM_RADIX-1:0]==`LEN-`OUT&& Is_not_first_3blocks)
        begin
            // Trace back and send out dec to filo
            en_filo_in<=1;
            During_send_data<=1;
        end
        // else if have send out all data, stop send data
        else if(wr_adr[`OUT_NUM_RADIX-1:0]==`LEN-1&&Is_not_first_3blocks)
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
                rd_adr_col<=wr_adr[`RAM_ADR_WIDTH-1:`U];
                state<=0;    //{(`U-`V)'b0, `W'b0, `V'b0, `V'b0};    ////////////////////
            end
            else
                dummy_cnt<=inc_dummy_cnt;
        end
        // else if we have trace back to the end
        else 
        if(wr_adr[`OUT_NUM_RADIX-1:0]==`LEN-1)
            During_traback<=0;
    end
    else    // invalid input decs                   
    begin
        // Hold the right values
        wr_en<=0;
        en_filo_in<=0;
    end
end

///////////////////////////////{next_rd_adr_byte,next_rd_adr_bit}={rd_adr_byte[`U-`V-1:0],rd_adr_bit[`W+`V-1:`V],dec, rd_adr_byte[`U-1:`U-`V]};    ////////////////////
///////////////////////////////{wire_rd_adr_byte, wire_rd_bit}={rd_adr_byte[`U-`V-1:0], rd_bit[`W+`V-1:`V], dec, rd_adr_byte[`U-1:`U-`V]};    ////////////////////    

endmodule
";
}


sub virtual_mem()
{
my ($i, $j);

print "`include \"$module_dir/glb_def.v\"\n";
print "
`define RAM_BYTE_WIDTH $RAM_BYTE_WIDTH
`define RAM_ADR_WIDTH $RAM_ADR_WIDTH 
`define NOMEMORY

module virtual_mem(clk, rst, wr_data, wr_adr, wr_en, rd_adr, rd_en, rd_data);
    // Hits:
    // the output data of the vitual_mem must be unregistered
    //
    parameter DATA_WIDTH=`RAM_BYTE_WIDTH;
    parameter ADDRESS_WIDTH=`RAM_ADR_WIDTH;
    
    input clk;
    input rst;
    input [DATA_WIDTH - 1:0] wr_data;
    input [ADDRESS_WIDTH - 1:0] wr_adr;
    input [ADDRESS_WIDTH - 1:0] rd_adr;
    input wr_en;
    input rd_en;
    output [DATA_WIDTH - 1:0] rd_data;
    
`ifdef NOMEMORY
    reg[DATA_WIDTH-1:0] mem[0:0];
    assign rd_data=rst?(rd_en?mem[0]:'bx):0;
    always @(posedge clk )
    begin
	if(wr_en&&wr_adr==0&&rd_adr==0)
	begin
	    mem[0]<=wr_data;
	end
	else
	    mem[0]<=1;
    end
`else
    reg [DATA_WIDTH - 1:0] mem[",$RAM_BYTES_NUM-1,":0];
    integer temp;
    initial 
    begin
        for(temp=0;temp<$RAM_BYTES_NUM;temp=temp+1)
        begin
            mem[temp]=0;
        end
    end

    assign rd_data=rst?(rd_en?mem[rd_adr]:'bx):0;
    always @(posedge clk)
    begin
	    if(wr_en)
	    begin
	        mem[wr_adr]<=wr_data;
	    end
    end
`endif
endmodule
";
}
sub vit2()
{
my ($i, $j, $pe, $yz_in, $y_out, $z_out);
my (@tmp1, @tmp2, @tmp3);
my $w_mask=2**$W-1;

print "`include \"$module_dir/glb_def.v\"\n";

print "
module vit2(mclk, rst, valid, ", join(", ", @SYMBOLS), ", pattern, ", join(", ", @DECS_TBU), ", valid_decs);
input mclk, rst, valid;
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;
output[`V-1:0] ", join(", ", @DECS_TBU), ";
output valid_decs;

";foreach $pe (@PES){print 
"wire[`V-1:0] ", join(", ", prefix("$pe\_", \@PE_DECS,"")), ";\n";} print "
wire valid_slice;
wire[`U-1:0] slice;					//////////////////// u canot be less than one
wire[`Bit_Width-1:0] ", join(", ", @reg_symbols), ";
wire[`SYMBOLS_NUM-1:0] reg_pattern;           //////////////////////////////////////////////
wire[`V-1:0] shift_cnt;      ///////// 
wire[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////

";foreach $pe (@PES){print 
"wire[`SM_Width-1:0] ", join(", ", prefix("$pe\_",\@in_sms,"")), ", ", join(", ", prefix("$pe\_", \@out_sms,"")), ";  //////////////////////////////
";} $i=0; foreach $pe (@PES){ foreach $j (@PE_DECS){ print 
"assign ",$DECS_TBU[$i],"=$pe\_$j\;	 /////////////////////////////////////////////////\n"; $i++; }}
	for($i=0;$i<$PES_NUM;$i++){
	for($j=0;$j<$PATH_NUM;$j++){
		$yz_in=($i<<$V)|$j;
		$y_out=$yz_in&$w_mask;
		$z_out=$yz_in>>$W;
		print 
"assign pe$i\_in_sm$j\=pe$y_out\_out_sm$z_out\;             /////////////////////////////////////////////////\n";
	}
	}
	for($i=0;$i<$PES_NUM;$i++){
	@tmp1=prefix("pe$i\_", \@in_sms,"");
	@tmp2=prefix("pe$i\_", \@out_sms,"");
	@tmp3=prefix("pe$i\_", \@PE_DECS,"");
	
	print 
"\npe0 #($i) pe0_$i(.mclk(mclk), .rst(rst), .slice(slice), .valid(valid_slice), .shift_cnt(shift_cnt), .",join(", .", party(\@adrs_shift, \@adrs_shift), party(\@SYMBOLS,\@reg_symbols)), ", .pattern(reg_pattern), .", 
	join(", .", party(\@in_sms, \@tmp1)), ", .",
	join(", .", party(\@out_sms, \@tmp2)), ", .",
	join(", .", party(\@PE_DECS, \@tmp3)), ");";
	}
	print "		
ctrl ctrl_0(.mclk(mclk), .rst(rst), .valid(valid), .", join(", .", party(\@SYMBOLS, \@SYMBOLS)), ", .pattern(pattern), 
.valid_slice(valid_slice), .slice(slice), .shift_cnt(shift_cnt), .", join(", .", party(\@adrs_shift, \@adrs_shift), party(\@reg_symbols, \@reg_symbols)), ", .reg_pattern(reg_pattern), .valid_decs(valid_decs));
endmodule
";
}

sub vit2cpp()
{
my ($i,$j);
my @polys_exp=gen_polys("m", "^");
	
print "
#include <stdio.h>
#include<iostream>
#include<vector>

const int \$para_state_num=$para_state_num;	//8
const int \$para_symbol_num=$para_symbol_num;	//2
const int \$para_conv_m=$para_conv_m;		//3
const int \$para_path_num=$PATH_NUM;	//2
const int  patn_len=6;
const int \$V=$V;				//2**\$V is the path num
using namespace std;

int main()
{
	int pattern[patn_len]={1, 1, 1, 1, 1, 1};
	int cnt=0, patn_cnt=0;
	unsigned char symbol;
	vector<unsigned char> m(\$para_conv_m+1);
	vector<int> decs(\$para_state_num);
	vector<int> symbols(\$para_symbol_num);
	vector<int> bm(\$para_path_num); //////////////////////////////////////////
	vector<int> sm1(\$para_state_num),sm2(\$para_state_num);
	vector<int> *old_sm=&sm1, *new_sm=&sm2, *tmp_sm;
		
// for some things, the m[i] is newer than m[j], if i>j; because when I write the gen_poly function, I think bit is from high bits move to low bits and new bit commes into m from high bits. 
	
	while(!cin.eof()&&cin>>symbol){
		if(!(symbol=='0'||symbol=='1')) continue;
		symbol-='0';
		symbols[cnt]=symbol;
		// prepare enough symbols for decode
		cnt++;
		if(cnt==\$para_symbol_num){
			cnt=0;
			// for each state we generate a dec
			for(int index=0;index<\$para_state_num;index++){
				int state=index;
				{int tmp;
				tmp=state>>\$V;
				state<<=(\$para_conv_m-\$V);
				state|=tmp;}
				// for each path into this state;
				for(int path=0;path<\$para_path_num;path++){
					// now just support \$para_path_num=2
					int old_state;
					old_state=state<<\$V;
					old_state|=path;
					old_state&=",2**$para_conv_m-1,";
					int v_shift=0x01;
					m[0]=path;					///////////////////////////////////////////
					for(int i=\$V;i<\$para_conv_m+\$V;i++,v_shift<<=1)
					{
						m[i]=(state&v_shift)==0? 0 : 1;   
					}
					bm[path]=(*old_sm)[old_state];";
					for($i=0;$i<$para_symbol_num;$i++){print "
						if(pattern[patn_cnt+$i])
							bm[path]+=symbols[$i]^", $polys_exp[$i], ";  // compare symbol$i";
					}print "
				}
				if(bm[0]<bm[1]){					////////////////////////////////////////////////
					decs[index]=0;
					(*new_sm)[state]=bm[0];
				}
				else{
					decs[index]=1;
					(*new_sm)[state]=bm[1];
				}
			}
			// print out decs for debug
			for(int i=0;i<\$para_state_num;i++){
				if((i\%$NUM_DEC_TBU)==0){
					cout<<",'"\n"',";
				}
				cout<<decs[i];
			}
			cout<<",'"\n"',";
			tmp_sm=new_sm;
			new_sm=old_sm;
			old_sm=tmp_sm;
			patn_cnt+=\$para_symbol_num;	
			patn_cnt%=patn_len;
		}
	}
	return 0;
}
";
}


sub party(\@\@)
{
my ($a,$b)=@_;
my @party;
my ($aa, $bb, $i);
$i=0;
foreach $aa (@$a){
	$bb=@$b[$i];	
	push @party, "$aa($bb)";
	$i++;
}
return @party;
}
sub parties(\@$\@$)
{
my ($a,$exp1,$b,$exp2)=@_;
my @party;
my ($aa, $bb, $i);
$i=0;
foreach $aa (@$a){
	$bb=@$b[$i];	
	push @party, "$aa$exp1$bb$exp2";
	$i++;
}
return @party;
}
sub rparties(\@$\@$)
{
my ($a,$exp1,$b,$exp2)=@_;
my @party;
my ($aa, $bb, $i);
$i=0;
foreach $aa (@$a){
	$bb=@$b[$i];	
	push @party, "$aa$exp1$bb$exp2";
	$i++;
}
return \@party;
}

sub prefix($ \@$)
{
my ($pre, $a, $sub)=@_;
my @b;
foreach my $aa (@$a){
	push @b, "$pre$aa$sub";
}
return @b;
}
sub rprefix($\@$)
{
my ($pre, $a, $sub)=@_;
my @b;
foreach my $aa (@$a){
	push @b, "$pre$aa$sub";
}
return \@b;
}

sub genfile($\&)
{
	my ($module, $function)=@_;
	my ($FILE, $PREHANDLE);
	$PREHANDLE=select;
	open($FILE,">$module_dir/$module") or die "Couldn't open $module, $!\n";
	select $FILE;
	&$function();
	close($FILE) or die "Couldn't close $module, $!\n";
	select $PREHANDLE;
}
