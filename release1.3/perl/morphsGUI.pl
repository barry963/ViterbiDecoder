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
# version 1.2 based on version 1.1, opencores, update date: 2008/12/18
#             including some adjustment by moti.
#             They are helpdialog and script_dir. Now you can run this comm-
#             and in anywhere directory.
#             from this version, log changes in head file
# version 1.1 update date: 2006/7
#
#/usr/bin/perl -w
use 5.005; 
use Tk 8.0; 
use Tk::widgets qw/Dialog/; 
use strict;
use subs qw/init/;
use vars qw/$MW $VERSION/;
use Cwd qw(abs_path);

$MW = MainWindow->new;
init();
MainLoop();

sub creOpt {
	my ($frame, $label, $value)=@_;
	my ($Opt, $box, $text);
	$box = $frame->Frame->pack;
	$text = $box->Label(-text=>$label, -height=>1, -width=>10)->pack(-side=>'left');
	$Opt = $box->Entry(-textvariable=>$value)->pack(-after=>$text, -side=>'right');
	return $Opt;
}

sub init {
	my ($optFrame, $boxFrame, $radio_SYN, $radio_DRTTB);
	my ($radioFrame);
	my ($opt_POLYS, $opt_V, $opt_B, $opt_OSR, $opt_DBN);
	my ($opt_RAMSIZE, $opt_RAW, $opt_RAMWORD);
	my ($radio_SYNC, $radio_ASYNC);
	my ($opt_TBLEN);
	my ($radio_DRT_TB, $radio_NDRT_TB);
	my ($btn_OK, $btn_CLOSE, $btn_HELP);
	
	my $infoLabel = $MW->Label(-text=>"Viterbi decoder HDL codes generator:\nbased on S.A.R.B (Same Address Write Back), PE(Process Element), TB(Trace Back).\n",-fg=>"blue")->pack;
	
	$optFrame = $MW->Frame->pack;
	$radioFrame = $MW->Frame->pack;
	$radio_SYN = $radioFrame->Frame->pack(-side=>"left");
	$radio_DRTTB = $radioFrame->Frame->pack(-side=>"right");
	$boxFrame = $MW->Frame->pack();
	my $abs_path = abs_path($0);
	my $HOMEDIR;
	my $SCRIPTDIR;
	my $licenseLabel= $MW->Label(-text=>"
All Right Reserved
	")->pack(-side=>"bottom");
	# configure 1
	# my $def_opt_POLYS='91 121 101 91';
	# my $def_opt_V = 1;
	# my $def_opt_B = 3;
	# my $def_opt_OSR = 4;
	# my $def_opt_DBN = 2;
	# my $def_opt_RAW = 10;
	# my $opt_SYNC_RAM = 1;
	# configure 2
	my $def_opt_POLYS='91 121 101 91';
	my $def_opt_V = 1;
	my $def_opt_B = 1;
	my $def_opt_OSR = 5;
	my $def_opt_DBN = 2;
	my $def_opt_RAW = 8;
	my $def_opt_RAMSIZE = 256;
	my $def_opt_RAMWORD = 32;
	my $def_opt_TBLEN = 80;
	my $def_opt_TBOUT = 40;
	my $opt_SYNC_RAM = 1;
	my $opt_DRT_TB   = 1;
	
	$opt_POLYS = creOpt($optFrame, "Polys", \$def_opt_POLYS);
	$opt_TBLEN = creOpt($optFrame, "TB_LEN", \$def_opt_TBLEN);
	#$opt_V = creOpt($optFrame, "V", \$def_opt_V);
	#$opt_B = creOpt($optFrame, "B", \$def_opt_B);
	#$opt_OSR = creOpt($optFrame, "OSR", \$def_opt_OSR);
	#$opt_DBN = creOpt($optFrame, "DBN", \$def_opt_DBN);
	$opt_RAMWORD = creOpt($optFrame, "RAMWORD", \$def_opt_RAMWORD);
	$opt_RAMSIZE = creOpt($optFrame, "RAMSIZE", \$def_opt_RAMSIZE);
	$opt_RAW = creOpt($optFrame, "RAW", \$def_opt_RAW);
	$radio_SYNC = $radio_SYN->Radiobutton(-variable=>\$opt_SYNC_RAM, -text=>'  Synchronous RAM', -value=>1)->pack();
	$radio_ASYNC = $radio_SYN->Radiobutton(-variable=>\$opt_SYNC_RAM, -text=>'ASynchronous RAM', -value=>0)->pack();
	$radio_DRT_TB = $radio_DRTTB->Radiobutton(-variable=>\$opt_DRT_TB, -text=>'Support Direct Traceback', -value=>1)->pack;
	$radio_NDRT_TB = $radio_DRTTB->Radiobutton(-variable=>\$opt_DRT_TB, -text=>'Not Support Direct Traceback', -value=>0)->pack;
	
	my $text = $optFrame->Label(-text=>"
	POLYS is the decimal notation of the convolution code generators.
	TB_LEN is the length of survivor path, or traceback length, normally from 64 to 256.
	RAMWORD is the word size of survivor path memory. It's pow of 2 and it decide the decode speed. 
	The value is more larger, the decoder is more fast. The max value of it is 2^(K-2).
	RAMSIZE is the number of words of survivor path memory, let it be pow RAW of 2 for easy.
	RAW is the address width of the survivor path memory. 2^RAW should be larger than TB_LEN.
	Note: The Decoder Supports Punctured Encode                
	")->pack;
	
#	my $text = $optFrame->Label(-text=>"
#	POLYS is the decimal notation of the convolution code generators.		
#	V means using radix 2^V butterflies, only supports V=1 for now.		
#	B means that we need 2^(B*V) cycles to decode one symbol.		
#	OSR means that the code sends out (2^OSR)*V symbols per trace back.		
#	DBN sets the traceback depth to DBN*(2^OSR)*V. For some reason, DBN is not more than 2^(B*V)).		
#	RAW is the address width of the survivor path memory.
#	Note: The Decoder Supports Punctured Encode                
#	")->pack;
	
	$btn_OK = $boxFrame->Button(-text=>'Ok', -height=>1, -width=>4, -command=>\&getOpt)->pack(-side=>"left");
	
	$btn_CLOSE = $boxFrame->Button(-text=>'Close', -height=>1, -width=>4, -command=>sub{exit;})->pack(-side=>"right");

	$btn_HELP = $boxFrame->Button(-text=>'Help', -height=>1, -width=>4, -command=>\&helpDialog)->pack(-side=>"right");
	
	if ($abs_path !~ /[\/\\]/) # $0 only has the file name
	{
		$HOMEDIR=".";
	}else {
	    $abs_path =~/(.*)[\/\\]([^\/\\]*)[\/\\]([^\/\\]*)$/;
	    $HOMEDIR=$1; $SCRIPTDIR=$2;
	    #print $1,' ',$2,' ', $3,"\n";
	}
	
	sub getOpt {
		my ($POLYS, $K, $V, $B, $U, $OSR, $DBN);
		my ($RAMSIZE, $RAW, $RAMWORD, $FACTSIZE);
		my ($TBLEN, $TBOUT);
		my ($i, $j, $k, $bar);
		my @para_polys;
		my $para_symbol_num;
		
		$POLYS = $opt_POLYS->get;
		@para_polys = split(' ', $POLYS);
		$bar = 0; $j = 0;
		foreach $i (@para_polys){
		    $j++;
		    $bar |= $i;}
	    $k = 0;
	    while($bar != 0){
    		$k++;
    		$bar >>= 1;}
	    (print "Error: Max K=16 supported" and die )if ($k > 16 || $k<2);
	    $K  = $k;
	    $para_symbol_num = $j;
		$TBLEN = $opt_TBLEN->get; if($TBLEN<=0) {$TBLEN=64;}
		$RAW   = $opt_RAW->get;
		$RAMSIZE   = $opt_RAMSIZE->get;
		$RAMWORD   = 2**($K-2);
		$def_opt_RAMWORD = 2**($K-2);
		#$RAMWORD = $V*(2**($W+$V));
		# for simple
		$V     = 1;
		$B     = 1;
		$U     = 1;
		#for($i=0;(2**$i)<$RAMWORD/$V;$i++){}
		#$U     = $K-1-$i;  if($U<=0){print "Error: $U is not smaller than 0\n" and die} # $U+$V+$W = $K-1	
		#$B     = $U/$V;
		
		$TBOUT = int($TBLEN/(2**$U))+1;
        for($i=0;(2**$i)<$TBOUT;$i++){}	
		$OSR   = $i;  $def_opt_OSR = $i;
		$DBN   = 2**$U;   $def_opt_DBN = 2**$U;
		if($opt_DRT_TB==0){
		    #we need to reset the TB_OUT and TB_LEN value, for TB_OUT = 2^OSR
		    $TBOUT = 2**$OSR;
		    $TBLEN = $DBN*$TBOUT;
		}
		$FACTSIZE     = ($TBOUT + $TBLEN)*(2**$U);
		for($i=0;(2**$i)<$FACTSIZE;$i++){}
		if($i>$RAW) {
		    my $congDialog = $MW->Dialog(-title   => 'Generation Status', 
				-text    => 
				" Wrong Parameters: RAW Should be larger than $i", 
				-buttons => ['Ok'],
				-default_button => ['Ok'], 
				-bitmap  => 'info');
			$congDialog->Show; 
			$def_opt_RAW = $i;
			$def_opt_RAMSIZE = 2**$i;
			return 1;}	
		$RAMSIZE = 2**$RAW;
		$def_opt_RAMSIZE = 2**$RAW;
		#$V = $opt_V->get;
		#$B = $opt_B->get;
		#$OSR = $opt_OSR->get;
		#$DBN = $opt_DBN->get;
		#$RAW = $opt_RAW->get;
		#$TBLEN = $DBN*(2**$OSR);
		#$TBOUT = 2**$OSR;
		
		my $dialog = $MW->Dialog(-title   => 'Confirm Generation', 
                                -text    => "Generator Parameters:\nPOLYS = '$POLYS'\nTBLEN = '$TBLEN'\nOSR = '$OSR'\nTBOUT = '$TBOUT'\n\nRAMWORD = '$RAMWORD'\nRAMSIZE = '$RAMSIZE'\nRAW = '$RAW'\n\nGenerate Code?", 
                                -buttons => ['Accept', 'Cancel'],
#				-default_button => 'Accept', 
                                -bitmap  => 'question'); 
		my $answer = $dialog->Show(-global);
		my $result;
		#print $answer;
		if($answer eq 'Accept'){
			# Command Line is Here...	
			open RESULT, "perl \"$HOMEDIR/$SCRIPTDIR/Oracle.pl\" -HOMEDIR \"$HOMEDIR\" -SCRIPTDIR \"$SCRIPTDIR\" -POLYS \"$POLYS\" -V $V -B $B -OSR $OSR -DBN $DBN -RAW $RAW -SYNCRAM $opt_SYNC_RAM -DIRECTTB $opt_DRT_TB -TB_LEN $TBLEN -TB_OUT $TBOUT|" or die;
			while (<RESULT>){
				$result = $_;
			}
			if($result==1){
				my $congDialog = $MW->Dialog(-title   => 'Generation Status', 
					-text    => "Code generation completed successfully\nSee generated files under \"rtl/verilog\" directory", 
					-buttons => ['Ok'],
#					-default_button => ['Ok'], 
					-bitmap  => 'info');  
				$congDialog->Show;
				return 0;
			}
			else {
				my $congDialog = $MW->Dialog(-title   => 'Generation Status', 
					-text    => 
					" Code generation failed
 Do you forget to creat the directory?
 Like as rtl/verilog, bench/verilog, c.
 Please check the error output", 
					-buttons => ['Ok'],
#					-default_button => ['Ok'], 
					-bitmap  => 'info');
				$congDialog->Show;
				return 1;
			}
		}
		else {
			#print "eeerroorr";
			return 1;
		}
	}
	# A good option, I will add more help here.
sub helpDialog {
		my $congDialog = $MW->Dialog(-title   => 'Just a little help', 
			-text    => "Use one of the following generator polynomials.
Rate 1/2 codes:
For K=3,  polys = [7,5]
For K=4,  polys = [15, 11]
For K=5,  polys = [23, 25]
For K=5,  polys = [19, 27]
For K=6,  polys = [47, 53]
For K=7,  polys = [109, 79]
For K=7,  polys = [91, 121]		(802.11a)
For K=8,  polys = [159, 229]
For K=9,  polys = [431, 285]
For K=15, polys = [17885, 27107]

Rate 1/3 codes:
For K=3,  polys = [7, 7, 5]
For K=4,  polys = [15, 11, 13]
For K=5,  polys = [31, 27, 21]
For K=6,  polys = [47, 53, 57]
For K=7,  polys = [79, 87, 109]
For K=8,  polys = [239, 155, 169]
For K=9,  polys = [493, 411, 295]

Rate 1/4 codes:
For K=7, polys = [91 121 101 91]    (DAB)

", 
			-buttons => ['Ok'],
			-bitmap  => 'info'); 
		$congDialog->Show;
		return 0;
	}
	1
}

