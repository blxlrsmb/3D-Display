/*
 * $File: main.v
 * $Date: Tue Jun 04 00:52:42 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module main(
	output reg [0:15] row, col,
	input clock, cycle_marker);

	wire [0:255] data = 255'h0FF03FFC781E700EE007C003C003C003C003C003C003E007700E781E3FFC0FF0;

	wire [0:15] row0, col0;
	reg enable;

	disp_matrix disp_matrix(data, clock, row0, col0);

	always @(posedge clock) begin
		if (cycle_marker) begin
			row <= row0;
			col <= col0;
		end
		else begin
			row <= 0;
			col <= 0;
		end
	end

endmodule

