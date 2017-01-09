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


module testbench;
	reg a;
	reg b;
	wire sum;
  reg cin;
  wire cout;

	full_adder woo(sum, cout, a, b, cin);
	initial begin
		 a=0; b=0; cin=0;
		#50 a=0; b=0; cin=1;
    #50 a=0; b=1; cin=0;
		#50 a=0; b=1; cin=1;

    #50 a=1; b=0; cin=0;
		#50 a=1; b=0; cin=1;
    #50 a=1; b=1; cin=0;
		#50 a=1; b=1; cin=1;
	end
	initial $monitor($time,," a=%d, b=%d, cin=%b, sum=%d, cout=%b", a, b, cin, sum, cout);  // Record
endmodule
