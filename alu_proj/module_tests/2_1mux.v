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

module test;
reg b;
reg notb;
reg [2:0] op;
wire y;

mux_2_1 mux(y, op[2], b, notb);

initial begin
	b=0; notb=1; op=100;
end

initial $monitor("b=%b, notb=%b, x=%b, y=%b", b, notb, op[2], y);

endmodule
