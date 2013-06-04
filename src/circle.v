

module circle_move(
	input signed [15:0] x, y, r2,		// last x, y; r2 = radius^2
	input gclock,
	output reg signed [15:0] ox, oy);

	reg signed [15:0] d1, d2, d3;
	wire dx, dy;

	assign dx = y[15];
	assign dy = ~x[15];

	always @(x, y, r2) begin
		d1 <= x * x + (y + dy) * (y + dy) - r2;
		d2 <= (x + dx) * (x + dx) + y * y - r2;
		d3 <= (x + dx) * (x + dx) + (y + dy) * (y + dy) - r2;
	end
endmodule
