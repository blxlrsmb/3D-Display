/*
 * $File: main.v
 * $Date: Sat Jun 01 09:18:35 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module main(
	output [0:15] row, col,
	input clock);

	wire [0:255] data = 255'h204028A024222223212621A46128102017FE1224092008A0108037FF40400040;

	disp_matrix disp_matrix(data, clock, row, col);

endmodule

