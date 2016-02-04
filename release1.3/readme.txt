HOW TO USE

Run morpheusrun.bat, you need install perl/tk. See homepage for link.


INTRODUCTION

Unzip all files into a directory. You can see "morpheusrun.bat", "readme.txt",
"doc" and "perl" in this directory. Under this directory,
Run the following command to generate Verilog HDL codes in GUI:
	
	$> perl perl/morphsGUI.pl

You need the perltk lib to run the GUI version, or you can run the command version:
	
	$> perl perl/Oracle.pl

All Verilog HDL codes are put into "rtl/verilog" directory now. An encoder written in C is generated under "c" directory for verification.



Good Luck!

%Version 1.3
  Add Direct Traceback Option and Self test module
  Rejust the GUI Interface.

%Version 1.2 
  Adjust directory structure, remove "source" "data" directory, add
"testvector" "sim" "bench" directory.
  Change negedge reset to posedge reset
  Add soft reset signal to traceback.v
  Some other changes, see the head in each file.

%Version 1.1 
  Add synchronous ram surpport
  Redefine the interface and something else

