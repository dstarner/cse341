module full_adder(sum, carry, a, b, c);
	output sum, carry;
	input a,b,c;
	wire w, x, y, z;
	// Sum
	xor  (w, a, b);
	xor  (sum, w, c);
	// Carry
	and  (x, a, c);
	and  (y, b, c);
	and  (z, a, b);
	or   (carry, x, y, z);
endmodule

module mux_2_1(y, x, a, b);
	input x, a, b;
	output y;
	wire notX;
	wire aAndx;
	wire bAndx;

	not mux_notX(notX, x);
	and mux_anda(aAndx, a, notX);
	and mux_andb(bAndx, b, x);
	or mux_or(y, bAndx, aAndx);

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

module alu_module(out, sub_mux_out, cout, set, a, b, cin, less, op);
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
	output cout, out, set, sub_mux_out;
	wire x;
	wire and000;  // Answer for 000
	wire or001;   // Answer for 001
	wire adder_result;  // Answer for 010 and 110
	wire slt_result;
	wire beq_result;


	// This is where all the fun stuff from the powerpoint goes
	// Op code 000  - and
	and op000(and000, a, b);  // Basic a AND b

	// Op code 001  - or
	or  op001(or001, a, b);

  // Adder code  if if sub = 1, then
	//wire sub_mux_out;
  wire notb;
  not not_b(notb, b);
	mux_2_1 sub_mux(sub_mux_out, op[2], b, notb); // If the 1__, then subtraction occurs
	full_adder op010(adder_result, cout, a, sub_mux_out, cin);

	// Set the 'Set'  ?? Unsure if correct ??
	assign set = adder_result;

  // Multiplex that shit at the end                       and    or      add         DC       beq          DC      sub        SLT
	//mux_8_1 the_final_countdown(out, op[2], op[1], op[0], and000, or001, adder_result, 1'b0,  adder_result, 1'b0, adder_result, 1'b0);
  assign out = adder_result;

endmodule

module testbench;
	reg a;
	reg b;
	reg [2:0] op;
  reg cin, less;
	wire sum, set, cout, sub_mux_out;

	alu_module woo(sum, sub_mux_out, cout, set, a, b, cin, less, op);
	initial begin
	  a=1; b=1; op=000;  // Assign random 32 bit number to a and b, 4 bit to op
		#50 a=1; b=1; op=010; cin=1; less=1;
		#50 a=1'b1; b=1'b1; op=000;
	end
	initial $monitor($time,," a=%d, b=%d, cin=%d, OP Code=%b, sum=%d, cout=%b, sub_mux=%b", a, b, cin, op, sum, cout, sub_mux_out);  // Record
endmodule
