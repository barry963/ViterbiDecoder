// This is just your compare module.
`include "glb_def.v"

// module PM_Comparator (
    // input wire [`SM_Width-1:0] X1,
    // input wire [`SM_Width-1:0] X2,
    // output reg Y,
    // );

// input 	
    // always @* begin
		// Y=X1[`SM_Width-1]^X2[`SM_Width-1]^((X1[`SM_Width-2:0]<X2[`SM_Width-2:0])?1:0);
    // end
// endmodule

// module PM_Comparator (
    // X1,
    // X2,
    // Y,
    // );
// input signed [`SM_Width-1:0] X1;
// input signed [`SM_Width-1:0] X2;
// output Y;
// reg Y;	
    // always @(X1 or X2) begin
		// Y=X1[`SM_Width-1]^X2[`SM_Width-1]^((X1[`SM_Width-2:0]<X2[`SM_Width-2:0])?1:0);
    // end
// endmodule

// Compare 8 bytes at a time
// module PM_Comparator (
    // input wire [`SM_Width*32-1:0] array,   // 8 byte array
   // // output wire [`SM_Width-1:0] indexG,
    // output wire [`SM_Width-1:0] valueG
    // );
	
    // wire [`SM_Width-1:0] value_l1[15:0];
    // wire [`SM_Width-1:0] index_l1[15:0];
    // genvar i;
    // generate
    // for (i=0;i<32;i=i+2) begin :gen_comps_l1				
		// if(array[i*8]^array[(i+1)*8]^((array[i*8+6:i*8]<array[(i+1)*8+6:(i+1)*8])?1:0))
			// begin
				// value_l1[i/2]=array[i*8+7:i*8];
			// end
		// else
			// begin
				// value_l1[i/2]=array[(i+1)*8+7:(i+1)*8];;
			// end
    // end
    // endgenerate

    // wire [`SM_Width-1:0] value_l2[7:0];
    // wire [`SM_Width-1:0] index_l2[7:0];

    // generate
    // for (i=0;i<16;i=i+2) begin :gen_comps_l2
		// if(value_l1[i][7]^value_l1[i+1][7]^((value_l1[i][6:0]<value_l1[i+1][6:0])?1:0))
			// begin
				// value_l2[i/2]=value_l1[i];
			// end
		// else
			// begin
				// value_l2[i/2]=value_l1[i+1];;
			// end
    // end
    // endgenerate

    // wire [`SM_Width-1:0] value_l3[3:0];
    // wire [`SM_Width-1:0] index_l3[3:0];

    // generate
    // for (i=0;i<8;i=i+2) begin :gen_comps_l3
		// if(value_l2[i][7]^value_l2[i+1][7]^((value_l2[i][6:0]<value_l2[i+1][6:0])?1:0))
			// begin
				// value_l3[i/2]=value_l2[i];
			// end
		// else
			// begin
				// value_l3[i/2]=value_l2[i+1];;
			// end
    // end
    // endgenerate

    // wire [`SM_Width-1:0] value_l4[1:0];
    // wire [`SM_Width-1:0] index_l4[1:0];

    // generate
    // for (i=0;i<4;i=i+2) begin :gen_comps_l4
		// if(value_l3[i][7]^value_l3[i+1][7]^((value_l3[i][6:0]<value_l3[i+1][6:0])?1:0))
			// begin
				// value_l4[i/2]=value_l3[i];
			// end
		// else
			// begin
				// value_l4[i/2]=value_l3[i+1];;
			// end
    // end
    // endgenerate

    // wire [`SM_Width-1:0] value_l5[0:0];
    // wire [`SM_Width-1:0] index_l5[0:0];

    // generate
    // for (i=0;i<2;i=i+2) begin :gen_comps_l5
		// if(value_l4[i][7]^value_l4[i+1][7]^((value_l4[i][6:0]<value_l4[i+1][6:0])?1:0))
			// begin
				// value_l5[i/2]=value_l4[i];
			// end
		// else
			// begin
				// value_l5[i/2]=value_l4[i+1];;
			// end
    // end
    // endgenerate	
	
    // //assign indexG = index_l5[0];
    // assign valueG = value_l5[0];
// endmodule



// This is just your compare module.
module PMComparator (
	input wire en_comp_in,
    input wire [7:0] X1,
    input wire [5:0] indexX1,
    input wire [7:0] X2,
    input wire [5:0] indexX2,
    output reg [7:0] Y,
    output reg [5:0] indexY
    );

    always @(*) begin
	if(en_comp_in)
		begin
			if ((X1[7]^X2[7]^(X1[6:0]<X2[6:0]))) begin
				Y = X1;
				indexY = indexX1;
			end
			else begin
				Y = X2;
				indexY = indexX2;
			end
			//$display("(#%d %d) (#%d %d)",indexX1,X1,indexX2,X2);
		end
	end
endmodule

// Compare 8 bytes at a time
module SelectMiniPM (
    input wire [255:0] array,   // 32*8 byte array
	input wire [`U-1:0] slice,
	//input wire [159:0] index,   // 32*5 byte array
	input wire en_comp_in,
    output wire [5:0] indexG,
    output wire [7:0] valueG
    );
	
	//always @(en_comp_in) begin
	//if(en_comp_in)
		//begin
			wire [7:0] value_l1[15:0];
			wire [5:0] index_l1[15:0];

			genvar i;
			generate
			for (i=0;i<32;i=i+2) begin :gen_comps_l1
				PMComparator cl1 (en_comp_in,
						 array[(i<<3)+:8],
						 //index[i*5+4:i*5],
						 i,
						 array[((i+1)<<3)+:8],
						 //index[(i+1)*5+4:(i+1)*5],
						 (i+1),
						 value_l1[i>>1],
						 index_l1[i>>1]
						);
					
			end
			endgenerate

			wire [7:0] value_l2[7:0];
			wire [5:0] index_l2[7:0];

			generate
			for (i=0;i<16;i=i+2) begin :gen_comps_l2
				PMComparator cl2 (en_comp_in,
				value_l1[i],
						 index_l1[i],
						 value_l1[i+1],
						 index_l1[i+1],
						 value_l2[i>>1],
						 index_l2[i>>1]
						);
			end
			endgenerate

			wire [7:0] value_l3[3:0];
			wire [5:0] index_l3[3:0];

			generate
			for (i=0;i<8;i=i+2) begin :gen_comps_l3
				PMComparator cl3 (en_comp_in,
				value_l2[i],
						 index_l2[i],
						 value_l2[i+1],
						 index_l2[i+1],
						 value_l3[i>>1],
						 index_l3[i>>1]
						);
			end
			endgenerate

			wire [7:0] value_l4[1:0];
			wire [5:0] index_l4[1:0];

			generate
			for (i=0;i<4;i=i+2) begin :gen_comps_l4
				PMComparator cl4 (en_comp_in,
				value_l3[i],
						 index_l3[i],
						 value_l3[i+1],
						 index_l3[i+1],
						 value_l4[i>>1],
						 index_l4[i>>1]
						);
			end
			endgenerate
			wire [7:0] value_l5[0:0];
			wire [5:0] index_l5[0:0];

			generate
			for (i=0;i<2;i=i+2) begin :gen_comps_l5
				PMComparator cl5 (en_comp_in,
				value_l4[i],
						 index_l4[i],
						 value_l4[i+1],
						 index_l4[i+1],
						 value_l5[i>>1],
						 index_l5[i>>1]
						);
			end
			endgenerate	
			
			//assign indexG = (slice==`U'd0)?((index_l5[0]<16)?(15-index_l5[0]):(63-index_l5[0])):((index_l5[0]<16)?(31-index_l5[0]):(79-index_l5[0]));
			assign indexG = (slice==`U'd0)?(31-index_l5[0]):(63-index_l5[0]);
			//assign indexG = (slice==`U'd0)?(31-index_l5[0]):(index_l5[0]);
			//assign indexG = 63-index_l5[0];
			//assign indexG = (index_l5[0]<16)?(31-index_l5[0]):(79-index_l5[0]);
			assign valueG = value_l5[0];
		//end	
		
	//end	
endmodule