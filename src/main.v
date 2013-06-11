/*
 * $File: main.v
 * $Date: Tue Jun 11 14:13:08 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module main(
	output [0:15] row, col,
	input clock, clock_cycle);

	wire [0:255] data;
	wire cc;
	reg cc_prev;
	reg unsigned [2:0] addr;

	assign cc = ~cc_prev & clock_cycle;
	always @(posedge clock_cycle)
		cc_prev <= cc;

	disp_matrix disp_matrix_comp(data, clock, row, col);

	frame_reader frame_reader_comp({5'b0, addr}, clock, data);
endmodule

