/*
 * $File: display.v
 * $Date: Tue Jun 11 17:19:50 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module disp_matrix(
	input enable,
	input [7:0] addr,
	output [0:15] row, col);

	wire [0:15] ncol, row_nenbl;
	assign col = ~ncol;

	addr2mask mask_row(addr[7:4], row_nenbl);
	addr2mask mask_col(addr[3:0], ncol);

	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1) begin: assign_mask
			assign row[i] = row_nenbl[i] & enable;
		end
	endgenerate
endmodule

module addr2mask
	#(parameter WIDTH = 4)
	(input [WIDTH-1:0] addr,
	output [0:2**WIDTH-1] mask);

	genvar i;
	generate
		for (i = 0; i < 2**WIDTH; i = i + 1) begin: assign_mask
			assign mask[i] = (addr == i);
		end
	endgenerate
endmodule

