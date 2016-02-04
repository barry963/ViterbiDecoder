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
#  version 1.1 updated date: 2006/7

sub encode()
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
1
