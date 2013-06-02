/*
 * $File: main.v
 * $Date: Sat Jun 01 20:34:44 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module main(
	output [0:15] row, col,
	input clock);

	wire [0:255] data = 255'h0FF03FFC781E700EE007C003C003C003C003C003C003E007700E781E3FFC0FF0;

	disp_matrix disp_matrix(data, clock, row, col);

endmodule

