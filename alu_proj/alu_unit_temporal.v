/* Daniel Starner dcstarne */
/* Basic ALU */

module full_adder(sum, carry, a, b, c);
	output sum, carry;
	input a,b,c;
	wire w, x, y, z;
	// Sum
	xor #1 (w, a, b);
	xor #1 (sum, w, c);
	// Carry
	and #1 (x, a, c);
	and #1 (y, b, c);
	and #1 (z, a, b);
	or  #1 (carry, x, y, z);
endmodule

module mux_2_1(y, x, a, b);
	input x, a, b;
	output y;
	wire notX;
	wire aAndx;
	wire bAndx;

	not #1 mux_notX(notX, x);
	and #1 mux_anda(aAndx, a, notX);
	and #1 mux_andb(bAndx, b, x);
	or  #1 mux_or(y, bAndx, aAndx);

endmodule

// Op code 001 goes in as s2=0, s1=0, s0=1
module mux_8_1(y, s2, s1, s0, a, b, c, d, e, f, g, h);
	output y;
	input s0, s1, s2, a, b, c, d, e, f, g, h;
	wire ab, cd, ef, gh, abcd, efgh;

	// a = 000 - AND   |    b = 001 - OR
	// c = 010 - ADD   |    d = 011 - Dont care
	// e = 100 - BEQ   |    f = 101 - Dont care
	// g = 110 - SUB   |    h = 111 - SLT

	mux_2_1 muxab(ab, s0, a, b);
	mux_2_1 muxcd(cd, s0, c, d);
	mux_2_1 muxef(ef, s0, e, f);
	mux_2_1 muxgh(gh, s0, g, h);

	mux_2_1 muxabcd(abcd, s1, ab, cd);
	mux_2_1 muxefgh(efgh, s1, ef, gh);

	mux_2_1 muxfinal(y, s2, abcd, efgh);

endmodule

module alu_module(out, cout, set, a, b, cin, less, op);
	/* a    bit :
	 * b    bit :
	 * op  [3:0]: opcode to perform
	 * less bit : slt for set than (0 except for last)
	 * cin  bit : carry in bit from previous
	 * cout bit : carry out bit from operation
	 * out  bit : the bit of value at the position
	 */
  input a, b, less, cin;
	input [2:0] op;
	output cout, out, set;
	wire x;
	wire and000;  // Answer for 000
	wire or001;   // Answer for 001
	wire adder_result;  // Answer for 010 and 110
	wire slt_result;
	wire beq_result;


	// This is where all the fun stuff from the powerpoint goes
	// Op code 000  - and
	and #1 op000(and000, a, b);  // Basic a AND b

	// Op code 001  - or
	or #1 op001(or001, a, b);

  // Adder code  if if sub = 1, then
	wire sub_mux_out;
	wire notb;
	not #1 not_b(notb, b);
	mux_2_1 sub_mux(sub_mux_out, op[2], b, notb); // If the 1__, then subtraction occurs
	full_adder op010(adder_result, cout, a, sub_mux_out, cin);

	// Set the 'Set'  ?? Unsure if correct ??
	or #1 set_set(set, adder_result, 1'b0);

  // Multiplex that shit at the end                       and    or      add         DC       beq          DC      sub        SLT
	mux_8_1 the_final_countdown(out, op[2], op[1], op[0], and000, or001, adder_result, 1'b0,  adder_result, 1'b0, adder_result, less);
	//assign out = adder_result;

endmodule

module thirty_two_bit_alu(zero, sum, a, b, op);
	input [31:0] a, b;  // For `a OP b = sum
	output [31:0] sum;
	output zero;
	wire [31:0] carry;
	wire [31:0] setout;
	input [2:0] op;

	wire lsb_add;
	mux_2_1 lsb_mux(lsb_add, op[2], 1'b0, 1'b1);

  // SHIT TONS OF ALUs BABYYYY!!!!!!     (0 'cept 31)                           (0 'cept 0)
                    // a OP b     cout       set       a[i]   b[i]     cin        less      op code
	alu_module alu_bit0( sum[0],  carry[0],  setout[0],  a[0],  b[0],  lsb_add,   setout[31], op[2:0]);
	alu_module alu_bit1( sum[1],  carry[1],  setout[1],  a[1],  b[1],  carry[0],  1'b0,  op[2:0]);
	alu_module alu_bit2( sum[2],  carry[2],  setout[2],  a[2],  b[2],  carry[1],  1'b0,  op[2:0]);
	alu_module alu_bit3( sum[3],  carry[3],  setout[3],  a[3],  b[3],  carry[2],  1'b0,  op[2:0]);
	alu_module alu_bit4( sum[4],  carry[4],  setout[4],  a[4],  b[4],  carry[3],  1'b0,  op[2:0]);
	alu_module alu_bit5( sum[5],  carry[5],  setout[5],  a[5],  b[5],  carry[4],  1'b0,  op[2:0]);
	alu_module alu_bit6( sum[6],  carry[6],  setout[6],  a[6],  b[6],  carry[5],  1'b0,  op[2:0]);
	alu_module alu_bit7( sum[7],  carry[7],  setout[7],  a[7],  b[7],  carry[6],  1'b0,  op[2:0]);
	alu_module alu_bit8( sum[8],  carry[8],  setout[8],  a[8],  b[8],  carry[7],  1'b0,  op[2:0]);
	alu_module alu_bit9( sum[9],  carry[9],  setout[9],  a[9],  b[9],  carry[8],  1'b0,  op[2:0]);
	alu_module alu_bit10(sum[10], carry[10], setout[10], a[10], b[10], carry[9],  1'b0, op[2:0]);
	alu_module alu_bit11(sum[11], carry[11], setout[11], a[11], b[11], carry[10], 1'b0, op[2:0]);
	alu_module alu_bit12(sum[12], carry[12], setout[12], a[12], b[12], carry[11], 1'b0, op[2:0]);
	alu_module alu_bit13(sum[13], carry[13], setout[13], a[13], b[13], carry[12], 1'b0, op[2:0]);
	alu_module alu_bit14(sum[14], carry[14], setout[14], a[14], b[14], carry[13], 1'b0, op[2:0]);
	alu_module alu_bit15(sum[15], carry[15], setout[15], a[15], b[15], carry[14], 1'b0, op[2:0]);
	alu_module alu_bit16(sum[16], carry[16], setout[16], a[16], b[16], carry[15], 1'b0, op[2:0]);
	alu_module alu_bit17(sum[17], carry[17], setout[17], a[17], b[17], carry[16], 1'b0, op[2:0]);
	alu_module alu_bit18(sum[18], carry[18], setout[18], a[18], b[18], carry[17], 1'b0, op[2:0]);
	alu_module alu_bit19(sum[19], carry[19], setout[19], a[19], b[19], carry[18], 1'b0, op[2:0]);
	alu_module alu_bit20(sum[20], carry[20], setout[20], a[20], b[20], carry[19], 1'b0, op[2:0]);
	alu_module alu_bit21(sum[21], carry[21], setout[21], a[21], b[21], carry[20], 1'b0, op[2:0]);
	alu_module alu_bit22(sum[22], carry[22], setout[22], a[22], b[22], carry[21], 1'b0, op[2:0]);
	alu_module alu_bit23(sum[23], carry[23], setout[23], a[23], b[23], carry[22], 1'b0, op[2:0]);
	alu_module alu_bit24(sum[24], carry[24], setout[24], a[24], b[24], carry[23], 1'b0, op[2:0]);
	alu_module alu_bit25(sum[25], carry[25], setout[25], a[25], b[25], carry[24], 1'b0, op[2:0]);
	alu_module alu_bit26(sum[26], carry[26], setout[26], a[26], b[26], carry[25], 1'b0, op[2:0]);
	alu_module alu_bit27(sum[27], carry[27], setout[27], a[27], b[27], carry[26], 1'b0, op[2:0]);
	alu_module alu_bit28(sum[28], carry[28], setout[28], a[28], b[28], carry[27], 1'b0, op[2:0]);
	alu_module alu_bit29(sum[29], carry[29], setout[29], a[29], b[29], carry[28], 1'b0, op[2:0]);
	alu_module alu_bit30(sum[30], carry[30], setout[30], a[30], b[30], carry[29], 1'b0, op[2:0]);
	alu_module alu_bit31(sum[31], carry[31], setout[31], a[31], b[31], carry[30], 1'b0, op[2:0]);

	wire notZero;
	or or_zero(notZero, sum[0], sum[1], sum[2], sum[3], sum[4], sum[5], sum[6], sum[7], sum[8], sum[9],
		sum[10], sum[11], sum[12], sum[13], sum[14], sum[15], sum[16], sum[17], sum[18], sum[19],
		sum[20], sum[21], sum[22], sum[23], sum[24], sum[25], sum[26], sum[27], sum[28], sum[29],
		sum[30], sum[31]);
	not (zero, notZero);


endmodule

module testbench;
	reg [31:0] a;
	reg [31:0] b;
	reg [2:0] op;
	wire [31:0] sum;
	wire zero;

	thirty_two_bit_alu woo(zero, sum, a, b, op);
	initial begin
	  a=1; b=1; op=000;  // Assign random 32 bit number to a and b, 4 bit to op
		#100 a=8'b11011010; b=8'b10101010; op=000;
		#100 a=8'b11001010; b=8'b11101010; op=000;
		#100 a=8'b11011010; b=8'b10111010; op=000;
		#100 a=8'b00011010; b=8'b00001010; op=000;

		#100 a=8'b11011010; b=8'b10101010; op=001;
		#100 a=8'b00000001; b=8'b00000001; op=001;
		#100 a=8'b00100001; b=8'b00000001; op=001;
		#100 a=8'b00101001; b=8'b00111001; op=001;

		#100 a=8'b11011010; b=8'b10101010; op=010;
		#100 a=8'b00011110; b=8'b00101110; op=010;
		#100 a=8'b00000010; b=8'b00001010; op=010;
		#100 a=8'b00011110; b=8'b00101110; op=010;

		#100 a=8'b11011010; b=8'b10101010; op=100;
		#100 a=8'b11011010; b=8'b11011010; op=100;
		#100 a=8'b00000010; b=8'b00000010; op=100;
		#100 a=8'b01011010; b=8'b00101010; op=100;

		#100 a=8'b11011010; b=8'b00111010; op=110;
		#100 a=8'b11011110; b=8'b00101110; op=110;
		#100 a=8'b11011010; b=8'b00101011; op=110;

		#100 a=8'b11011010; b=8'b10101010; op=111;
		#100 a=8'b00000111; b=8'b10101010; op=111;
		#100 a=8'b00000111; b=8'b00000111; op=111;

		#100 a=1538; b=2155; op=3'b010;
		#100 a=134; b=198; op=3'b000;
		#100 a=1538; b=2155; op=3'b010;
		#100 a=567953; b=213534; op=3'b110;
		#100 a=1538; b=2155; op=3'b010;
		#100 a=111111; b=1; op=3'b111;
		#100 a=1538; b=2155; op=3'b010;
		#100 a=564; b=1345; op=3'b100;
		#100 a=1538; b=2155; op=3'b010;
	end
	initial $monitor($time,," a=%d, b=%d, OP Code=%b, sum=%d, zero=%b", a, b, op, sum, zero);  // Record
endmodule
