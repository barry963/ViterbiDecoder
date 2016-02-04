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
#   version 1.2  update date: 2008/12/18
#   version 1.1  update date: 2006/7
#
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
1
