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
#              some modifications by moti
#              different include method of glb_def.v
#              rst signal changed from low-sensity to high sensity
#              timescale changed from 1ns/10ps to 1ns/1ps
#  version 1.1 updated date: 2006/7
#!/usr/bin/perl

#########################################################################################
##  Initial global parameters
sub para_initial()
#########################################################################################
{
	my ($bar, $i, $j, $k);
	$bar = 0, $j=0;
	
	$Timescale="1ns/1ps";
#	$SM_Width=9;
#	$Bit_Width=3;
#	$BM_Width=5;
	$home_dir=exists($argv{'-HOMEDIR'})?$argv{'-HOMEDIR'}:".";
	$module_dir="$home_dir/rtl/verilog";
	#print $home_dir,"\n";
	#print $module_dir,"\n";
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
	
    # Rate 1/4 codes:
    #@para_polys = [91 121 101 91]    (DAB)

	$mod_name ="";
	@ports_names = ();
	foreach $i (@para_polys){
		$j++;
		$bar |= $i;
	}
	$k = 0;
	while($bar != 0){
		$k++;
		$bar >>= 1;
	}
	(print "Error: Max K=16 supported" and die) if ($k > 16 || $k<2);
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
		$SM_Width>=$k or (print "Error: `SM_Width must be larger than $k\n" and die);
	}
# 	print "HHHHHHHHHHHHEEEEEEELLLLLLLOOOOOOOOOOOO, 
# 	SM_Width is $SM_Width, 
# 	BM_Width is $BM_Width,
# 	Bit_Width is $Bit_Width
# 	";
#	@para_file_head = ("//This is a head\n");
#	@para_file_predef = ("`include \"glb_def.v\"\n");
#	("//This is a predefine\n",
#			"`ifndef GLOBAL_DEFINES\n",
#			"`timescale $Timescale\n",
#			"`define SM_Width $SM_Width\n",
#			"`define Bit_Width $Bit_Width\n",
#			"`define BM_Width $BM_Width\n",
#			"`define SYMBOLS_NUM $para_symbol_num\n",
#			"`define GLOBAL_DEFINES\n",
#			"`endif\n");
	
}

###############################################################
sub print_head($)
###############################################################
{
	my $print_brief = !(shift);
	if($print_brief!=1){
	    print "// version$VERSION\n";
		print $LICENSE,"\n\n";
		print "// B=$B, symbol_num=$para_symbol_num, W=$W, V=$V, U=$U\n";
		print "// para_polys=@para_polys\n";
		print "// Support ",($DIRECTTB)?"Direct Traceback, ":"",($SYNC_RAM)?"Synchronous Ram":"Asynchronous Ram","\n";
		print "\n";
		#print "@para_file_predef";
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
	print "`include \"glb_def.v\"\n";
	open($FILE2, "<$script_dir/$file_name") or die "Couldn't open $file_name, $!\n";
	@content = <$FILE2>;
	print @content,"\n";
	close($FILE1) or die "Couldn't close $$mod_name.v, $!\n";
	close($FILE2) or die "Couldn't close $file_name, $!\n";
	$global_butfly_instance_name{$$mod_name}=@$ports_names;
	select $PREHANDLE;
}  ##butterfly
# acs2();

#########################################################################################
##
##
sub delayT(\$ \@)
#########################################################################################
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
	print_head(1);
	print "`include \"glb_def.v\"\n";
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
	print "`include \"glb_def.v\"\n";
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
	print "`include \"glb_def.v\"\n";
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
	print "`include \"glb_def.v\"\n\n";
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
1
