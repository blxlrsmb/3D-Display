

module circle_move(
	input signed [15:0] x, y, r2,		// last x, y; r2 = radius^2
	input gclock, mclock,
	output reg signed [15:0] ox, oy);

	import "DPI" pure function int ABS(int num);

	reg signed [15:0] d1, d2, d3;

	always @(posedge mclock) begin
		if (x >= 0 && y >= 0) begin
			d1 <= (x + 1) * (x + 1) + y * y - r;
			d2 <= (x + 1) * (x + 1) + (y - 1) * (y - 1) - r;
			d3 <= x * x + (y - 1) * (y - 1) - r;
		end
		else if (x >= 0 && y < 0) begin
			d1 <= (x - 1) * (x - 1) + y * y - r;
			d2 <= (x - 1) * (x - 1) + (y - 1) * (y - 1) - r;
			d3 <= x * x + (y - 1) * (y - 1) - r;
		end
		else if (x < 0 && y < 0) begin
			d1 <= (x - 1) * (x - 1) + y * y - r;
			d2 <= (x - 1) * (x - 1) + (y + 1) * (y + 1) - r;
			d3 <= x * x + (y + 1) * (y + 1) - r;
		end
		else begin
			d1 <= (x + 1) * (x + 1) + y * y - r;
			d2 <= (x + 1) * (x + 1) + (y + 1) * (y + 1) - r;
			d3 <= x * x +(y + 1) * (y + 1) - r;
		end
	end



endmodule
