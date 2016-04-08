// version1.3
///////////////////////////////////////////////////////////////////
         //////                                    //////
///////////////////////////////////////////////////////////////////
///                                                             ///
/// This file is generated by Viterbi HDL Code Generator(VHCG)  ///
/// which is written by Mike Johnson at OpenCores.org  and      ///
/// distributed under GPL license.                              ///
///                                                             ///
/// If you have any advice,                                     ///
/// please email to jhonson.zhu@gmail.com                       ///
///                                                             ///
///////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////




// B=1, symbol_num=2, W=4, V=1, U=1
// para_polys=91 121
// Support Direct Traceback, Synchronous Ram


`timescale 1ns/1ps
`define SM_Width 8 
`define Bit_Width 3 
`define BM_Width 4 
`define SYMBOLS_NUM 2

`define U 1
`define V 1
`define W 4
`define K 7


// number of clock cycles used to process input symbols before next symbols can be 
// sent to the decoder (= 2^u).
`define SLICE_NUM           2

`define BIG 1           // the width of big slice

// secret debug flag 
//`define DEBUG				1
`ifdef DEBUG
`define DEBUG_OUT_FILE		"f_debug.txt" 
`endif