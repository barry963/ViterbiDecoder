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
# Version 1.2 based on version 1.1, updated date: 2008/12/18
#             modification: line138 case(next_big_slice), combine default statement.
#             line153 case(next_shift_cnt) same as above.
#             reset signal change from low-sensity to high-sensity
# Version 1.1 updated date: 2006/7
#/usr/bin/perl
sub ctrl()
{
my $i;
my @piece_slices;
foreach $i (1..$B){
	push(@piece_slices ,"next_slice[".($i*$V-1).":".($i*$V-$V)."]");
}
my @next_adrs_shift=prefix("next_",@adrs_shift,"");

print "`include \"glb_def.v\"\n";

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

module ctrl
(
    mclk, 
    rst, ", ($DIRECTTB==1)?"
    tb_dir,": "" , " 
    valid, 
    ", join(",
    ", @SYMBOLS), ", 
    pattern, 
    valid_slice, 
    slice, 
    shift_cnt, 
    ", join(",
    ", @adrs_shift, @reg_symbols), ", 
    reg_pattern,", ($DIRECTTB==1)?"
    tb_dir_vit,": "" , "  
    valid_decs
);

input mclk, rst, valid;
input[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
input[`SYMBOLS_NUM-1:0] pattern;           //////////////////////////////////////////////
", ($DIRECTTB==1)?"
input  tb_dir;": "" , " 
output[`U-1:0] slice;
output[`V-1:0] shift_cnt;      ///////// 
output[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////
output[`Bit_Width-1:0] ", join(", ", @reg_symbols), ";
output[`SYMBOLS_NUM-1:0] reg_pattern;           //////////////////////////////////////////////
output valid_slice, valid_decs;
", ($DIRECTTB==1)?"
output tb_dir_vit;": "" , " 

reg valid_slice;
reg[`U-1:0] slice;
reg[`V-1:0] shift_cnt;      
reg[`BIG-1:0] big_slice;
reg[`U-1:0] ",join(", ", @adrs_shift), ";             /////////////////////////////
", ($DIRECTTB==1)?"
reg tb_dir_vit, lock_tb_dir;":"","

wire[`U-1:0] next_slice;
wire[`V-1:0] next_shift_cnt; 
reg[`BIG-1:0] next_big_slice;
wire[`BIG-1:0] tmp_next_big_slice;
wire[`U+`V-1:0] ", join(", ", parties(@wire_adrs, "={next_slice,`V'd",@PE_Z, "}")), ";
reg[`U-1:0] ",join(", ", @adrs), ";             /////////////////////////////
reg[`U-1:0] ",join(", ", @next_adrs_shift), ";             /////////////////////////////

delayT #(`Bit_Width*`SYMBOLS_NUM+`SYMBOLS_NUM+1,1) delayT_symbols(.mclk(mclk), .rst(rst), .in({", join(", ", @SYMBOLS), ", pattern, valid_slice}), .out({", join(", ", @reg_symbols), ", reg_pattern, valid_decs}));

", ($DIRECTTB==1)?"
// tb_direct logic lock
always @(posedge mclk or posedge rst)
begin
    if(rst) begin
        tb_dir_vit<=0;
        lock_tb_dir<=0;
    end else begin
        if(!lock_tb_dir&&tb_dir&& (valid&&slice==`LAST_SLICE||valid_slice&&slice!=`LAST_SLICE) ) 
            lock_tb_dir<=1;
        else if(slice==`LAST_SLICE&&valid_slice&&lock_tb_dir) 
            lock_tb_dir<=0;
        
        if(lock_tb_dir&&valid_slice&&slice==`LAST_SLICE || tb_dir&&!valid&&slice==`LAST_SLICE) 
            tb_dir_vit<=1; 
        else 
            tb_dir_vit<=0;
        
    end
end ":"", " 
 
always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin
        {big_slice,slice} <= {`LAST_BIG_SLICE,`LAST_SLICE};    /////////////////////
	valid_slice<=0;
	shift_cnt<=0;", prefix("
	",@adrs_shift,"<=0;"),"
    end
    else if(slice==`LAST_SLICE)
    begin
	if(valid)
	begin
		slice<=next_slice;
		big_slice<=next_big_slice;
		valid_slice<=1;
		shift_cnt<=next_shift_cnt;
		",parties(@adrs_shift,"<=",@next_adrs_shift,";
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
	",parties(@adrs_shift,"<=",@next_adrs_shift,";
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
	"; if ($i == $MAX_BIG_SLICE-1) {print "default";}else{print "$i"}; print ":
	begin ";for($j=0;$j<$PATH_NUM;$j++){print "
	    ",$adrs[$j],
	    "={";for($k=$U+$V-1;$k>$V;$k--){print 
	    $wire_adrs[$j],"[", ($k+($MAX_BIG_SLICE-$i)*$V)%($U+$V), "], ";} print
	    $wire_adrs[$j],"[", ($k+($MAX_BIG_SLICE-$i)*$V)%($U+$V), "]};"} print "
	end";} print "
	endcase
end

// for using banks in SMU, we should shift down the read addresses order by barriel shift
always @(next_shift_cnt or ", join(" or ", @adrs),")
begin
    case(next_shift_cnt)";for($i=0;$i<$PATH_NUM;$i++){print "
	"; if ($i == $MAX_BIG_SLICE-1) {print "default";}else{print "$i"}; print ":
	begin";for($j=0;$j<$PATH_NUM;$j++){print "
	    ",$next_adrs_shift[$j],
	    "=",$adrs[($j+$PATH_NUM-$i)%$PATH_NUM],";"} print "
	end";} print "
	endcase
end

endmodule
";
}

1