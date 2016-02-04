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
#  version 1.2 update date: 2008/12/18
#              add DEBUG_OUT_FILE by moti
#  version 1.1 update date: 2006/7

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
`define K $para_conv_k


// number of clock cycles used to process input symbols before next symbols can be 
// sent to the decoder (= 2^u).
`define SLICE_NUM           $MAX_SLICE

`define BIG $BIG           // the width of big slice

// secret debug flag 
//`define DEBUG				1
`ifdef DEBUG
`define DEBUG_OUT_FILE		\"f_debug.txt\" 
`endif
";
}
1