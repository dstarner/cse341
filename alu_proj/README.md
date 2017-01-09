## 32 Bit ALU Verilog Project

This is a functional ALU written in Verilog with these Op Codes:

* 000: AND - Logically AND two 32 bit numbers
* 001: OR  - Logically OR two 32 bit numbers
* 010: ADD - Add two 32 bit numbers
* 100: BEQ - Sets 'zero' to 1 if two 32 bit numbers are equal
* 110: SUB - Subtracts two 32 bit numbers
* 111: SLT - Sets result to 1 if a < b for two 32 bit numbers  

The project directory is outlined as follows:
* README - Contains information about project structure.
* ALU_Design.pdf - PDF containing the writeup, verilog output, and gate level design
* `alu_zero.v` - A zero gate delay module showing that the ALU works.
* `alu_unit_temporal.v` - A temporal delay ALU given a medium-sized set of operations.
* `alu_unit_5000.v` - A temporal delay ALU given 4995 random data sets/ops with 5 planned operations for analysis.
* `average.py` - Given a `txt` file of `vvp` output, it will analyze the data.
* `run.sh` - USE THIS TO SAMPLE OUTPUT. This will compile the verilog, test it, analyze it, and clean up afterwards.

Any questions or concerns, please email Daniel Starner at dcstarne@buffalo.edu
