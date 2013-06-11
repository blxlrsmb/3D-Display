/*
 * $File: main.v
 * $Date: Tue Jun 11 18:20:26 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module main(
	input clock, clock_cycle,
	output [0:15] row, col);

	reg cc_prev;
	wire [7:0] coord;
	wire coord_enable;
	reg unsigned [23:0] clock_div;
	reg unsigned [2:0] addr = 0;

	always @(posedge clock)
		clock_div <= clock_div + 1'b1;

	always @(posedge clock_div[23])
		addr <= addr + 1'b1;

	disp_matrix disp_matrix_comp(
		.enable(coord_enable), .addr(coord), .row(row), .col(col));

	frame_reader frame_reader_comp(
		.frame_num({5'b0, addr}), .clock(clock_div[0]), .point_coord(coord),
		.point_enable(coord_enable));

endmodule

