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
#   version 1.2 updated date: 2008/12/18
#               add global valuables: $RST $RSTCOND $RSTEDGE
#               notice line 51: die " \$V could not be smaller than \$U\n"
#   version 1.1 updated date: 2006/7
#

sub def_initial()
{
my $i;
## $B=3, $V=1
$B=exists($argv{'-B'})?$argv{'-B'}:3;
$V=1;		##exists($OPTS{'-V'})?$OPTS{'-V'}:1;
$SYNC_RAM=exists($argv{'-SYNCRAM'})?$argv{'-SYNCRAM'}:1;
$RST = exists($argv{'-NEG_RST'})?"nrst":"rst";
$RSTEDGE=exists($argv{'-NEG_RST'})?"negedge nrst":"posedge rst";
$RSTCOND=exists($argv{'-NEG_RST'})?"!nrst":"rst";
$OUT_STAGE_RADIX=exists($argv{'-OSR'})?$argv{'-OSR'}:4;
$DUMMY_BLOCK_NUM = exists($argv{'-DBN'})?$argv{'-DBN'}:2;
$RAM_ADR_WIDTH=exists($argv{'-RAW'})?$argv{'-RAW'}:10;
$TB_LEN = ($DIRECTTB==1)?$argv{'-TB_LEN'}:64;
$TB_OUT = ($DIRECTTB==1)?$argv{'-TB_OUT'}:32;
############################# up is manually configured ###########################################
############################# down is auto generated ##############################################
# $BIG=1;			# BIG is width of MAX_BIG_SLICE;
$U=$B*$V, $W=$para_conv_m-$U-$V;
## for some reason, such as S.A.W.B(same address write back) and using banks in SMU, $U should not be smaller than $V;
## this is not a bug, there is only one case for $u<$v, that is $b=0;
## at this case there are some design problems I don't consider them clearly.
(print " Error: \$V could not be smaller than \$U\n" and die) if($U<$V); 
## let b*v is the minizal common multiple of (u+v) and v, then b is the max big slice
$MAX_BIG_SLICE=$B+1;	# simply it is (u+v);
## defines for trace back
# $OUT_STAGE_RADIX=4;
# $TRACE_BACK_LEN = 32;
# $RAM_ADR_WIDTH=10;
OUTTER1:for($BIG=0;;$BIG++){
	last OUTTER1 if((2**$BIG)>=$MAX_BIG_SLICE);
}
OUTTBRDX:for($TBLEN_RDX=0;;$TBLEN_RDX++){
	last OUTTBRDX if((2**$TBLEN_RDX)>=$TB_LEN);
}
$MAX_SLICE=2**$U;
$NUM_DEC_TBU=2**($W+$V);
$OUT_STAGE=2**$OUT_STAGE_RADIX;
$OUT_NUM_RADIX = $U+$OUT_STAGE_RADIX;
$OUT_NUM = 2**$OUT_NUM_RADIX;
$RAM_BYTE_WIDTH = $NUM_DEC_TBU*$V;
$RAM_BYTES_NUM=2**$RAM_ADR_WIDTH;
$TRACE_BACK_LEN=$DUMMY_BLOCK_NUM*$OUT_STAGE;
# for direct tracback
$DBN = ($DIRECTTB==1)?($TB_LEN/$TB_OUT):$DUMMY_BLOCK_NUM;
print "\$DBN is $DBN\n";
(print "\nError: Not support ----> DBN is more than 2^(B+V), which mean the speed of Tracebacking is slower than that of caculating DEC, so memory will be overflowed\n" and die ) if($DBN>2**$U); 
## 
OUTTER2:for($DUMMY_CNT_WIDTH=0;;$DUMMY_CNT_WIDTH++){
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
	print_head(1);
	&$function();
	close($FILE) or die "Couldn't close $module, $!\n";
	select $PREHANDLE;
}

sub genFile($\&)
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
1
