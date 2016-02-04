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
#   version 1.2 created by moti
#
sub encoder()
{

my ($i);
my $shift_len = $para_conv_k-1;
my @polys_exp = gen_polys("cval", "^");
	
print "
`include \"glb_def.v\"

`define CONV_K		$para_conv_k

module encoder
(
	clock, 
	reset, 
	srst, ",($DIRECTTB==1)?"
	frm_end_i,":"","
	bit_in, 
	valid_in, 
	", join(", \n\t", @SYMBOLS), ", 
	valid_out", ($DIRECTTB==1)?",
	frm_end_o":"","
);

input clock, reset, srst, bit_in, valid_in;", ($DIRECTTB==1)?"
input frm_end_i;
output frm_end_o;":"","
output ", join(", ", @SYMBOLS), ";
output valid_out;

",($DIRECTTB==1)?"reg frm_end_o;":"","
reg ", join(", ", @SYMBOLS), ";
reg valid_out;
reg [`CONV_K-2:0] shift_reg;
wire [`CONV_K-1:0] cval;
", ($DIRECTTB==1)?"
always @ (posedge reset or posedge clock)
begin
    if (reset)
    begin
        frm_end_o<=1'b0;
    end
    else if(srst)
    begin
        frm_end_o<=1'b0;
    end
    else begin
        frm_end_o<=frm_end_i;
    end
end":"", "

always @ (posedge reset or posedge clock)
begin 
	if (reset)
		shift_reg <= {(\`CONV_K-1){1'b0}};
	else if (srst) 
		shift_reg <= {(\`CONV_K-1){1'b0}};
	else if (valid_in) 
		shift_reg <= {bit_in, shift_reg[`CONV_K-2:1]};
end 

assign cval = {bit_in, shift_reg};

always @ (posedge reset or posedge clock)
begin 
	if (reset)
	begin 
		", join(" <= 1'b0;\n\t\t", @SYMBOLS), " <= 1'b0;
		valid_out <= 1'b0;
	end 
	else if (srst)
	begin 
		", join(" <= 1'b0;\n\t\t", @SYMBOLS), " <= 1'b0;
		valid_out <= 1'b0;
	end 
	else if (valid_in) 
	begin ";
for ($i=0; $i<$para_symbol_num; $i++) { print "
		symbol$i <= ", $polys_exp[$i], ";  // output symbol$i";
}print "
		valid_out <= 1'b1;
	end 
	else 
		valid_out <= 1'b0;
end 
    
endmodule
";
}
1
