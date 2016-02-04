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
# # If you have any problem, please email to me: Jhonson.zhu@gmail.com           #  
# #                                                                              #  
# ################################################################################
################################################################################
#   Version 1.3 support direct traceback option  2009/2/2
#               add do.txt, block.list, etc. files
#   Version 1.2 updated date: 2008/12/18
#               test_fix_data: orignal test
#               test_random_data: created by moti, combine encoder and decoder
#   Version 1.1 updated date: 2006/7
#
sub readIni()
{
    my $line;
    if(open($INIFILE,"<$home_dir/morphs.ini")){
        close($INIFILE);} 
    else {
        open($INIFILE,">$home_dir/morphs.ini");
        print $INIFILE  "TouchDir = 1\n";
        close($INIFILE);
        touchdir();        }
}    
sub touchdir()
{   
    mkdir "$home_dir/c";
    mkdir "$home_dir/sim";
    mkdir "$home_dir/bench";
    mkdir "$home_dir/rtl";
    mkdir "$home_dir/rtl/verilog";
    mkdir "$home_dir/sim/icarus";
    mkdir "$home_dir/sim/modelsim";
    mkdir "$home_dir/bench/verilog";   
}

sub compile_bat()
{
    print '
    iverilog -o test_random_data.vvp -cblock.list -s test_random_data
    iverilog -o test_fix_data.vvp -cblock.list -s test_fix_data
    ';
}

sub gtk_bat(){ print 'gtkwave test.vcd -a test.sav '; }

sub run_fix_data_bat(){ print 'vvp -l test.log test_fix_data.vvp'; }

sub run_random_data_bat(){print 'vvp -l test.log test_random_data.vvp';}

sub self_test_bat(){ print 'perl ..\\..\\perl\\Architect.pl';}
    
sub block_list()
{
    print "
    +incdir+..\\..\\rtl\\verilog",($DIRECTTB==1)?"
    ..\\..\\rtl\\verilog\\delayT.v
    ..\\..\\rtl\\verilog\\acs2.v 
    ..\\..\\rtl\\verilog\\brameter2.v 
    ..\\..\\rtl\\verilog\\butfly2.v 
    ..\\..\\rtl\\verilog\\ctrl.v 
    ..\\..\\rtl\\verilog\\centrofilo.v 
    ..\\..\\rtl\\verilog\\tbdir_mod.v
    ..\\..\\rtl\\verilog\\smu.v 
    ..\\..\\rtl\\verilog\\pe.v 
    ..\\..\\rtl\\verilog\\dirtraback.v 
    ..\\..\\rtl\\verilog\\vit.v 
    ..\\..\\rtl\\verilog\\virtual_mem.v 
    ..\\..\\rtl\\verilog\\decoder.v 
    ..\\..\\rtl\\verilog\\encoder.v 
    ..\\..\\bench\\verilog\\test_fix_data.v 
    ..\\..\\bench\\verilog\\test_random_data.v":
    "
    ..\\..\\rtl\\verilog\\delayT.v
    ..\\..\\rtl\\verilog\\acs2.v 
    ..\\..\\rtl\\verilog\\brameter2.v 
    ..\\..\\rtl\\verilog\\butfly2.v 
    ..\\..\\rtl\\verilog\\ctrl.v 
    ..\\..\\rtl\\verilog\\filo.v 
    ..\\..\\rtl\\verilog\\smu.v 
    ..\\..\\rtl\\verilog\\pe.v 
    ..\\..\\rtl\\verilog\\traceback.v 
    ..\\..\\rtl\\verilog\\vit.v 
    ..\\..\\rtl\\verilog\\virtual_mem.v 
    ..\\..\\rtl\\verilog\\decoder.v 
    ..\\..\\rtl\\verilog\\encoder.v 
    ..\\..\\bench\\verilog\\test_fix_data.v 
    ..\\..\\bench\\verilog\\test_random_data.v","
    ";
}

sub do_txt()
{
    print "
    vlog +incdir+..\\\\..\\\\rtl\\\\verilog \\
    +acc=rn \\
"; 
    if($DIRECTTB==1){ print <<"EOF"; 
    ..\\\\..\\\\rtl\\\\verilog\\\\delayT.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\acs2.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\brameter2.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\butfly2.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\ctrl.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\centrofilo.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\smu.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\pe.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\dirtraback.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\tbdir_mod.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\vit.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\virtual_mem.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\decoder.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\encoder.v \\
    ..\\\\..\\\\bench\\\\verilog\\\\test_fix_data.v \\
    ..\\\\..\\\\bench\\\\verilog\\\\test_random_data.v 
EOF
    }
    else { print <<"EOF";
    ..\\\\..\\\\rtl\\\\verilog\\\\delayT.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\acs2.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\brameter2.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\butfly2.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\ctrl.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\filo.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\smu.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\pe.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\traceback.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\vit.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\virtual_mem.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\decoder.v \\
    ..\\\\..\\\\rtl\\\\verilog\\\\encoder.v \\
    ..\\\\..\\\\bench\\\\verilog\\\\test_fix_data.v \\
    ..\\\\..\\\\bench\\\\verilog\\\\test_random_data.v 
EOF
    }
print "
vsim work.test_random_data
";
}

sub test_random_data_tbdir()
{
my ($i, $j);

my $FRAME_LEN  = $TB_LEN+int(rand($TB_LEN));
my $FRAME_NUM  = 3+int(rand(10));
my $FRMEND_DLY = int(rand($TB_LEN));
my $CLK_TIME   = 1;
my $RAND_SEED  = int(rand(1000));

print "`include \"glb_def.v\"\n";
print "
// uncomment to VCD dump 
//`define VCD_DUMP_ENABLE     1

// the length of the code source 
`define FRAME_LEN            $FRAME_LEN
`define FRAME_NUM            $FRAME_NUM
`define FRMEND_DLY           $FRMEND_DLY
// data generation seed - change this value to change encoder input data sequence 
`define RAND_SEED			 $RAND_SEED            

// test bench files names 
`define ENC_IN_FILE			\"enc_in.txt\"
`define ENC_OUT_FILE		\"enc_out.txt\"
`define DEC_OUT_FILE		\"dec_out.txt\"

// number of clock cycles used to process input symbols before next symbols can be 
// sent to the decoder (= 2^u).
`define SLICE_NUM           $MAX_SLICE

// traceback depth used to bound the decoder delay 
`define OUT_NUM             $OUT_NUM 

// the simulation cycle time of clock 
`define CLK_TIME            $CLK_TIME

// simulation end command 
// use $stop command for modelsim and $finish for icarus verilog 
`define END_COMMAND         \$finish
//`define END_COMMAND         \$stop

module test_random_data;

reg clock;
reg reset;
wire srst = 0;
reg frm_end;
reg enc_bit_in, enc_valid_in;
wire enc_", join(", enc_", @SYMBOLS), ";
wire enc_valid_out;
reg [`Bit_Width-1:0] dec_", join(", dec_", @SYMBOLS), ";
reg dec_valid_in;
wire [`SYMBOLS_NUM-1:0] pattern;
wire dec_bit_out, dec_valid_out;
integer ccnt, count, frm_cnt;
reg [2*`OUT_NUM-1:0] enc_in_buf;
integer buf_in_cnt, buf_out_cnt, total_count;
reg dec_out_error;
wire err1, err2, err3;
wire tb_dir_o;
reg tb_dir;
reg enc_hold;
integer frame_num;
integer rand;

// VCD dump - if enabled 
`ifdef VCD_DUMP_ENABLE 
initial 
begin 
    $dumpfile(\"test.vcd\");
    $dumpvars(0, test_random_data);
end 
`endif 

initial 
begin
    clock = 1;
    reset = 1;
    # 100.5 reset = 0;
end

initial forever # `CLK_TIME clock = ~clock;

initial 
begin
    enc_valid_in = 0;
    enc_bit_in = 0;
    rand = \$random(`RAND_SEED);
    buf_in_cnt = 0;
    buf_out_cnt = 0;
    total_count = 0;
    dec_out_error = 0;
end

// encoder input interface 
always @(posedge clock or posedge reset)
begin
    if (reset)
    begin
    	enc_bit_in <= 0;
        enc_valid_in <= 0;
        ccnt = 0;
        count = 0;
        frm_cnt = 0;
        frm_end <= 0;
        enc_hold <= 0;
    end
    else
    begin
        frm_end<=0;
        enc_valid_in<=0;
      if(enc_hold)begin
      end
      else begin
        ccnt = ccnt + 1;
        if (ccnt == `SLICE_NUM)
        begin 
            // input bit is valid 
            rand = \$random;
            enc_valid_in <= 1;
            enc_bit_in <= rand;
            
            // update encoder input bit 
            if(count>=`FRAME_LEN-`K) enc_bit_in <=0;
            if(count>=`FRAME_LEN) enc_valid_in<=0;
            
            if(count==`FRAME_LEN-1+`FRMEND_DLY)begin
                if(frm_cnt==`FRAME_NUM-1) frm_end <= 1;
                else frm_end<= \$random;
                count = 0;
                
                if(frm_cnt==`FRAME_NUM-1)
                    enc_hold<=1;
                else 
                    frm_cnt = frm_cnt+1;
            end else begin
                frm_end <= 0;
                count = count+1;
            end
            
            
            // update counters 
            ccnt = 0;
            
        end
        else 
            enc_valid_in <= 0;
      
      end
    end
end

// encoder module 
encoder enc 
(
	.clock(clock), 
	.reset(reset), 
	.srst(srst),
	.frm_end_i(frm_end), 
	.bit_in(enc_bit_in), 
	.valid_in(enc_valid_in), ";
	for ($i=0; $i<$para_symbol_num; $i++) { print "
	.symbol$i(enc_symbol$i),";
	} print "
	.valid_out(enc_valid_out),
	.frm_end_o(frm_end_o)
);

// connect the symbols from the encoder output to the decoder input 
always @ (posedge reset or posedge clock)
begin 
	if (reset) 
	begin
		dec_valid_in <= 1'b0;";
        for ($i=0; $i<$para_symbol_num; $i++) { print "
		dec_symbol$i <= 0;";
		} print "
		tb_dir <= 0;
	end 
	else begin
	    tb_dir <=frm_end_o;
    	if (enc_valid_out) 
    	begin 
    		dec_valid_in <= 1'b1; "; 
            for ($i=0; $i<$para_symbol_num; $i++) { print "
            if (enc_symbol$i) 
    			dec_symbol$i <= `Bit_Width'b", 1 x$Bit_Width,";
    		else 
    			dec_symbol$i <= `Bit_Width'b", 0 x$Bit_Width,";";
            } print "
    	end 
    	else 
    		dec_valid_in <= 1'b0;
    end
end 
always @(*) begin
 if(err1===1) \$display(\"Traceback Error\");
 if(err2===1) \$display(\"Filo Error\");
 if(err3===1) \$display(\"Tb_Dir Error\");
 if(err1===1||err2===1||err3===1)
    `END_COMMAND;
end
// decoder module 
decoder dec 
(
    .mclk(clock), 
    .rst(reset), 
    .srst(srst), 
    .tb_dir(tb_dir),
    .valid_in(dec_valid_in),";
    for ($i=0; $i<$para_symbol_num; $i++) { print "
	.symbol$i(dec_symbol$i),";
    } print "
    .pattern(pattern), 
    .bit_out(dec_bit_out), 
    .valid_out(dec_valid_out),
    .tb_dir_o(tb_dir_o),
    
    .traceback_error(err1),
	.filo_error(err2),
	.tbdir_mod_err(err3)
);
// test bench does not check puncturing 
assign pattern = `SYMBOLS_NUM'b", 1x$para_symbol_num, ";

// store the encoder input bits to check the decoder 
always @ (posedge reset or posedge clock)
begin 
	if (reset)
		buf_in_cnt <= 0;
	else if (enc_valid_in) 
	begin 
		// write next bit 
		enc_in_buf[buf_in_cnt] <= enc_bit_in;
		
		// check overflow condition & update the buffer address counter 
		if ((buf_in_cnt + 1) == buf_out_cnt)
		begin 
			\$display(\"Error: data buffer overflow probably due to decoder latency.\");
			repeat (5) @(posedge clock);
            `END_COMMAND;
        end 
        else if (buf_in_cnt == 2*`OUT_NUM-1)
			buf_in_cnt <= 0;
		else 
			buf_in_cnt <= buf_in_cnt + 1;
	end 
end 

// compare decoder output bits to encoder input bits 
always @ (posedge reset or posedge clock)
begin 
	if (reset)
	begin 
		buf_out_cnt <= 0;
		total_count <= 0;
		frame_num   <= 0;
		dec_out_error <= 0;
	end 
	else if (dec_valid_out)
	begin 
		// compare decoder output to encoder input 
		if (dec_bit_out !== enc_in_buf[buf_out_cnt])
		begin 
			\$display(\"Error: decoder output failure.\");
			dec_out_error <= 1;
			repeat (5) @(posedge clock);
            `END_COMMAND;
		end 
		
		// update buffer output counter 
        if (buf_out_cnt == 2*`OUT_NUM-1)
        begin 
			buf_out_cnt <= 0;
			\$display(\"Info: decoder output correct at bit index %d\", total_count);
		end 
		else 
			buf_out_cnt <= buf_out_cnt + 1;
		
		// update the total decoded bits counter 
		if(total_count == `FRAME_LEN-1) begin
		    \$display(\"Info: decoder output correct at bit index %d,  frame %4d\", total_count, frame_num);
		    if(frame_num==`FRAME_NUM-1)begin
		        \$display(\"\");
		        repeat (5) @(posedge clock);
		        `END_COMMAND;
		    end
		    frame_num<=frame_num+1;
		    total_count<=0;
		    dec_out_error<=0;
		end
		else 
		    total_count <= total_count + 1;
	end 
end 

// record encoder inputs 
integer f_enc_in;
initial
	f_enc_in = \$fopen(`ENC_IN_FILE);

always @ (posedge clock)
begin
    if (enc_valid_in)
        \$fwrite(f_enc_in,\"%b\\n\", {enc_bit_in});
end

// record encoder outputs 
integer f_enc_out;
initial
	f_enc_out = \$fopen(`ENC_OUT_FILE);

always @ (posedge clock)
begin
    if (enc_valid_out)
        \$fwrite(f_enc_out,\"%b\\n\", {enc_symbol0, enc_symbol1});
end

// record decoder outputs 
integer f_dec_out;
initial
	f_dec_out = \$fopen(`DEC_OUT_FILE);

always @ (posedge clock)
begin
    if (dec_valid_out)
        \$fwrite(f_dec_out,\"%b\\n\", {dec_bit_out});
end

endmodule
";
}

sub test_fix_data()
{
my ($i, $j);

my $CODE_LEN=32768;
my $CODE_FILE="../../testvector/91_121_101_91/code_8192_32768.dat";
my $SOURCE_FILE="../../testvector/91_121_101_91/data_8192_32768.dat";
my $CLK_TIME=1;

print "`include \"glb_def.v\"\n";

print "
`define DEC_NUM $NUM_DEC_TBU           // equal to 2^(w+v)
`define RAM_BYTE_WIDTH $RAM_BYTE_WIDTH    // DEC_WIDTH*DEC_NUM
`define RAM_ADR_WIDTH  $RAM_ADR_WIDTH  // the size of ram is 1024bits, letting it be pow of two makes address generation work well.
`define OUT_STAGE_RADIX  $OUT_STAGE_RADIX    // the number of stages of one traceback output. It should be pow of two. The stage is the stage of encode lattice of radix r.
`define OUT_NUM_RADIX  $OUT_NUM_RADIX // radix of output number of DECS of one traceback action. It is equal U+OUT_STAGE_RADIX
`define OUT_STAGE   $OUT_STAGE    // 2^OUT_STAGE_RADIX

`define SLICE_NUM  $MAX_SLICE    //2^u
`define CODE_LEN  $CODE_LEN    // the length of the code source.
`define CLK_TIME  $CLK_TIME  // the cycle time of clock mclk

module test_fix_data;
reg unpunctured_code[`CODE_LEN-1:0];
reg mclk;
reg rst;
reg valid_in;
reg[`Bit_Width-1:0] ", join(", ", @SYMBOLS), ";
reg[`SYMBOLS_NUM-1:0] pattern;
integer i, j;

initial \$readmemb(\"$CODE_FILE\", unpunctured_code);
initial 
begin
   	mclk=1;
   	rst=1;
   	pattern=`SYMBOLS_NUM'b", 1x$para_symbol_num,";
    valid_in=0;
   	# 50 rst=1;
   	# 5000 rst=0;
end

initial forever # `CLK_TIME mclk=~mclk;

always @(posedge mclk or posedge rst)
begin
    if(rst)
    begin
        i=0;
        j=0;
        valid_in<=0;",
	prefix("\n\t", @SYMBOLS, "<=0;"),"
        pattern<=`SYMBOLS_NUM'b",1x$para_symbol_num, ";
    end
    else
    begin
      if(j==0) begin
        valid_in<=1;";
        for($i=0;$i<$para_symbol_num;$i++){ print 
	"\n\tif(unpunctured_code[i+$i]==1'b1)
		",$SYMBOLS[$i],"<=`Bit_Width'b", 1x$Bit_Width,";
	else
		",$SYMBOLS[$i],"<=`Bit_Width'b", 0 x$Bit_Width,";
	";
	} print "
	end
	j=j+1;
        if(j==`SLICE_NUM)
        begin
            i=i+`SYMBOLS_NUM;
            j=0;
        end
        if(i==`CODE_LEN)
            \$finish;
    end
end

wire decoder_out, decoder_en;
            
decoder decoder_i
(
    .mclk(mclk), 
    .rst(rst), 
    .valid_in(valid_in), 
    .", join(", 
    .", party(@SYMBOLS, @SYMBOLS)), ", 
    .pattern(pattern), 
    .bit_out(decoder_out), 
    .valid_out(decoder_en)
);
////////////////////////////////// test module //////////////////////////////////////////////////////////

integer f_decoder_out, line;
reg source_data[`CODE_LEN-1:0];
integer data_count;
initial
begin
line=0; 
data_count=0;
f_decoder_out=\$fopen(\"f_decoder_out\");
end
initial \$readmemb(\"$SOURCE_FILE\", source_data);
always @(posedge mclk or posedge rst)
begin
    if(!rst)     // it is not reset
    begin
        if(decoder_en)
        begin
            if(decoder_out!==source_data[data_count]) begin
                \$display(\"missmatch at line %d\\n\", data_count);
                \$fwrite(f_decoder_out, \"missmatch! %b, %b\\n\", decoder_out, source_data[data_count]);
            end else begin 
                if(data_count!=0 && data_count%256==0) \$display(\" compare data is correct at %d\\n\", data_count);
                \$fwrite(f_decoder_out,\"%b\", {decoder_out});
                \$fwrite(f_decoder_out,\"\\n\");
            end
            data_count=data_count+1;
            
            /*
            \$fwrite(f_decoder_out,",'"%b"',", {decoder_out});
            if(line%4==3)
            begin
                \$fwrite(f_decoder_out,",'"\n"',");
            end
            if(line%16==15)
            begin
                \$fwrite(f_decoder_out,",'"\n"',");
            end
            line=line+1;
            */
        end
    end
end
endmodule
";
}

sub test_random_data()
{
my ($i, $j);

my $CODE_LEN = 1280;
my $CLK_TIME = 1;

print "`include \"glb_def.v\"\n";
print "
// uncomment to VCD dump 
//`define VCD_DUMP_ENABLE     1

// the length of the code source 
`define CODE_LEN            $CODE_LEN

// data generation seed - change this value to change encoder input data sequence 
`define RAND_SEED			$RAND_SEED            

// test bench files names 
`define ENC_IN_FILE			\"enc_in.txt\"
`define ENC_OUT_FILE		\"enc_out.txt\"
`define DEC_OUT_FILE		\"dec_out.txt\"

// number of clock cycles used to process input symbols before next symbols can be 
// sent to the decoder (= 2^u).
`define SLICE_NUM           $MAX_SLICE

// traceback depth used to bound the decoder delay 
`define OUT_NUM             $OUT_NUM 

// the simulation cycle time of clock 
`define CLK_TIME            $CLK_TIME

// simulation end command 
// use \$stop command for modelsim and \$finish for icarus verilog 
`define END_COMMAND         \$finish
//`define END_COMMAND         \$stop

module test_random_data;

reg clock;
reg reset;
wire srst = 0;
reg enc_bit_in, enc_valid_in;
wire enc_", join(", enc_", @SYMBOLS), ";
wire enc_valid_out;
reg [`Bit_Width-1:0] dec_", join(", dec_", @SYMBOLS), ";
reg dec_valid_in;
wire [`SYMBOLS_NUM-1:0] pattern;
wire dec_bit_out, dec_valid_out;
integer ccnt, count;
reg [2*`OUT_NUM-1:0] enc_in_buf;
integer buf_in_cnt, buf_out_cnt, total_count;
reg dec_out_error;

// VCD dump - if enabled 
`ifdef VCD_DUMP_ENABLE 
initial 
begin 
    \$dumpfile(\"test.vcd\");
    \$dumpvars(0, test_random_data);
end 
`endif 

initial 
begin
    clock = 1;
    reset = 1;
    # 100.5 reset = 0;
end

initial forever # `CLK_TIME clock = ~clock;

initial 
begin
    enc_valid_in = 0;
    enc_bit_in = \$random(\`RAND_SEED);
    buf_in_cnt = 0;
    buf_out_cnt = 0;
    total_count = 0;
    dec_out_error = 0;
end

// encoder input interface 
always @(posedge clock or posedge reset)
begin
    if (reset)
    begin
    	enc_bit_in <= 0;
        enc_valid_in <= 0;
        ccnt = 0;
        count = 0;
    end
    else
    begin
        ccnt = ccnt + 1;
        if (ccnt == \`SLICE_NUM)
        begin 
            // input bit is valid 
            enc_valid_in <= 1;
            
            // update encoder input bit 
            enc_bit_in <= \$random();
            
            // update counters 
            count = count + 1;
            ccnt = 0;
        end
        else 
            enc_valid_in <= 0;
        
        if (count == \`CODE_LEN)
            `END_COMMAND;
    end
end

// encoder module 
encoder enc 
(
	.clock(clock), 
	.reset(reset), 
	.srst(srst), 
	.bit_in(enc_bit_in), 
	.valid_in(enc_valid_in), ";
for ($i=0; $i<$para_symbol_num; $i++) { print "
	.symbol$i(enc_symbol$i),";
}print "
	.valid_out(enc_valid_out)
);

// connect the symbols from the encoder output to the decoder input 
always @ (posedge reset or posedge clock)
begin 
	if (reset) 
	begin
		dec_valid_in <= 1'b0; ";
for ($i=0; $i<$para_symbol_num; $i++) { print "
		dec_symbol$i <= 0;";
}print "
	end 
	else if (enc_valid_out) 
	begin 
		dec_valid_in <= 1'b1; ";
for ($i=0; $i<$para_symbol_num; $i++) { print "

		if (enc_symbol$i) 
			dec_symbol$i <= `Bit_Width'b", 1 x$Bit_Width,";
		else 
			dec_symbol$i <= `Bit_Width'b", 0 x$Bit_Width,";";
}print "
	end 
	else 
		dec_valid_in <= 1'b0;
end 

// decoder module 
decoder dec 
(
    .mclk(clock), 
    .rst(reset), 
    .srst(srst), 
    .valid_in(dec_valid_in), ";
for ($i=0; $i<$para_symbol_num; $i++) { print "
	.symbol$i(dec_symbol$i),";
}print "
    .pattern(pattern), 
    .bit_out(dec_bit_out), 
    .valid_out(dec_valid_out)
);
// test bench does not check puncturing 
assign pattern = \`SYMBOLS_NUM'b", 1x$para_symbol_num,";

// store the encoder input bits to check the decoder 
always @ (posedge reset or posedge clock)
begin 
	if (reset)
		buf_in_cnt <= 0;
	else if (enc_valid_in) 
	begin 
		// write next bit 
		enc_in_buf[buf_in_cnt] <= enc_bit_in;
		
		// check overflow condition & update the buffer address counter 
		if ((buf_in_cnt + 1) == buf_out_cnt)
		begin 
			\$display(\"Error: data buffer overflow probably due to decoder latency.\");
			repeat (5) @(posedge clock);
            `END_COMMAND;
        end 
        else if (buf_in_cnt == 2*`OUT_NUM-1)
			buf_in_cnt <= 0;
		else 
			buf_in_cnt <= buf_in_cnt + 1;
	end 
end 

// compare decoder output bits to encoder input bits 
always @ (posedge reset or posedge clock)
begin 
	if (reset)
	begin 
		buf_out_cnt <= 0;
		total_count <= 0;
		dec_out_error <= 0;
	end 
	else if (dec_valid_out)
	begin 
		// compare decoder output to encoder input 
		if (dec_bit_out !== enc_in_buf[buf_out_cnt])
		begin 
			\$display(\"Error: decoder output failure.\");
			dec_out_error <= 1;
			repeat (5) @(posedge clock);
            `END_COMMAND;
		end 
		
		// update buffer output counter 
        if (buf_out_cnt == 2*`OUT_NUM-1)
        begin 
			buf_out_cnt <= 0;
			\$display(\"Info: decoder output correct at bit index %d\", total_count);
		end 
		else 
			buf_out_cnt <= buf_out_cnt + 1;
		
		// update the total decoded bits counter 
		total_count <= total_count + 1;
	end 
end 

// record encoder inputs 
integer f_enc_in;
initial
	f_enc_in = \$fopen(\`ENC_IN_FILE);

always @ (posedge clock)
begin
    if (enc_valid_in)
        \$fwrite(f_enc_in,\"%b\\n\", {enc_bit_in});
end

// record encoder outputs 
integer f_enc_out;
initial
	f_enc_out = \$fopen(\`ENC_OUT_FILE);

always @ (posedge clock)
begin
    if (enc_valid_out)
        \$fwrite(f_enc_out,\"%b\\n\", {enc_", join(", enc_", @SYMBOLS), "});
end

// record decoder outputs 
integer f_dec_out;
initial
	f_dec_out = \$fopen(\`DEC_OUT_FILE);

always @ (posedge clock)
begin
    if (dec_valid_out)
        \$fwrite(f_dec_out,\"%b\\n\", {dec_bit_out});
end

endmodule
";
}

1

