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
#
# Version 1.3 Updated date: 2009/2
#             The Father 
#/usr/bin/perl -w

@polys = (
    # Rate 1/2 codes
    "7 5",		# k=3
	"15 11",		    # k=4
	"23 25",		# k=5
	"19 27",		# k=5, used in GSM?
	"47 53",		# k=6
	"109 79",		# k=7; very popular with NASA and industry (802.11 for example)
	"91 121",       # k=7; for 802.11a
	"159 229",		# k=8
	"431 285",	    # k=9; used in IS-95 CDMA
	# It's horrible "17885 27107",	# k = 15
	
	
	# Rate 1/3 codes
	"7 7 5",	    # k = 3
	"15 11 13", 	# k = 4
	"31 27 21",	    # k = 5
	"47 53 57",	    # k = 6
	"79 87 109",	# k = 7; also popular with NASA and industry
	"239 155 169",	# k = 8
	"493 411 295",  # k = 9; used in IS-95 CDMA
	
    # Rate 1/4 codes:
    "91 121 101 91" # k = 7; used in DAB
    );
@K = ("3", "4","5","5","6","7","7","8","9","3","4","5","6","7","8","9","7");    
#require "perl/Oracle.pl";
$count = 10;
$SIMDIR  = "$HOMEDIR/sim/icarus";
$HOMEDIR = "../../";
$SCRIPTDIR = "perl";
%argv=@ARGV; 
die "\nusage: command -c number_of_test_cases -l logfile\n" if (exists($argv{'-help'}));

if(exists($argv{'-c'})){
    $count = $argv{'-c'};
}
if(exists($argv{'-l'})){
    open $LOGFILE, $argv{'-l'};
}else { open $LOGFILE , ">self_test.log";}

while($count!=0){
    my $index;
    
    $opt_SYNC_RAM = (rand(1)>0.5)?1:0;	
	$opt_DRT_TB = (rand(1)>0.5)?1:0;
	
	$count=$count-1;
	$index = int(rand(16));
    $POLYS = @polys[$index];
    $K     = @K[$index];
	$TBLEN = int(rand(300))+30; if($TBLEN>300){$TBLEN = int(rand(1500))+300;}
	
	$V     = 1;
	$B     = 1;# 1+int(rand($K-3)); # open $B will downspeed simulation.
	$U     = $B*$V;
	$TBOUT = ($TBLEN%2)?($TBLEN+1)/2:$TBLEN/2;
    for($i=0;(2**$i)<$TBOUT;$i++){}	
	$OSR   = $i;  
	$DBN   = 2;  
	if($opt_DRT_TB==0){
	    #we need to reset the TB_OUT and TB_LEN value, for TB_OUT = 2^OSR
	    $TBOUT = 2**$OSR;
	    $TBLEN = $DBN*$TBOUT;
	}
	$FACTSIZE     = ($TBOUT + $TBLEN)*(2**$U);
	for($i=0;(2**$i)<$FACTSIZE;$i++){}
	$RAW = $i;
	$RAMWORD = $V*2**($K-1-$U);
	$RAMSIZE = 2**$i;
	my $line;
    open RESULT, "perl \"$HOMEDIR/$SCRIPTDIR/Oracle.pl\" -HOMEDIR \"$HOMEDIR\" -SCRIPTDIR \"$SCRIPTDIR\" -POLYS \"$POLYS\" -V $V -B $B -OSR $OSR -DBN $DBN -RAW $RAW -SYNCRAM $opt_SYNC_RAM -DIRECTTB $opt_DRT_TB -TB_LEN $TBLEN -TB_OUT $TBOUT|" or die;
    while($line=<RESULT>){
        print $line,"\n";
        print $LOGFILE  $line, "\n";
        if($line=~/Error/){die " Generate source code failed\n";}
    }close RESULT;
    
    print "No.$count -POLYS \"$POLYS\" -K $K -V $V -B $B -OSR $OSR -DBN $DBN -RAW $RAW -SYNCRAM $opt_SYNC_RAM -DIRECTTB $opt_DRT_TB -TB_LEN $TBLEN -TB_OUT $TBOUT -RAMSIZE $RAMSIZE -RAMWORD $RAMWORD\n";
    print $LOGFILE "-POLYS \"$POLYS\" -K $K -V $V -B $B -OSR $OSR -DBN $DBN -RAW $RAW -SYNCRAM $opt_SYNC_RAM -DIRECTTB $opt_DRT_TB -TB_LEN $TBLEN -TB_OUT $TBOUT -RAMSIZE $RAMSIZE -RAMWORD $RAMWORD\n";
    open RESULT, "iverilog -o test_random_data.vvp -c block.list -s test_random_data|";
    while($line=<RESULT>){
        print $line,"\n";
        print $LOGFILE  $line, "\n";
        if($line=~/error/){die " Compile source code failed\n";}
    }close RESULT;
    
    open RESULT, " vvp -l test.log test_random_data.vvp|";
    while($line=<RESULT>){
        print $line,"\n";
        print $LOGFILE  $line, "\n";
        if($line=~/Error/){
            print "
            \$HOMEDIR   =  $HOMEDIR
            \$SCRIPTDIR =  $SCRIPTDIR
            \$POLYS     =  $POLYS
            \$K         =  $K
            \$V         =  $V 
            \$B         =  $B 
            \$OSR       =  $OSR 
            \$DBN       =  $DBN 
            \$RAW       =  $RAW 
            \$SYNCRAM   =  $opt_SYNC_RAM 
            \$DIRECTTB  =  $opt_DRT_TB 
            \$TB_LEN    =  $TBLEN 
            \$TB_OUT    =  $TBOUT
            ";
            print $LOGFILE  "
            \$HOMEDIR   =  $HOMEDIR
            \$SCRIPTDIR =  $SCRIPTDIR
            \$POLYS     =  $POLYS
            \$V         =  $V 
            \$B         =  $B 
            \$OSR       =  $OSR 
            \$DBN       =  $DBN 
            \$RAW       =  $RAW 
            \$SYNCRAM   =  $opt_SYNC_RAM 
            \$DIRECTTB  =  $opt_DRT_TB 
            \$TB_LEN    =  $TBLEN 
            \$TB_OUT    =  $TBOUT
            ";
            print $LOGFILE  " Simulation failed! Please Check, check\n";
            die " Simulation failed! Please Check, check\n";
            }
    }close RESULT;
}
print "Self Test Passed\n";
print $LOGFILE "Self Test Passed\n";
close $LOGFILE;
1
