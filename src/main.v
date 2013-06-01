/*
 * $File: main.v
 * $Date: Sat Jun 01 08:59:25 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module main(
	output [0:15] row, col,
	input clock);

	wire [0:255] data = 255'h204028A024222223212621A46128102017FE1224092008A0108037FF40400040;

	disp_matrix disp_matrix(data, clock, row, col);

endmodule

module disp_matrix(
	input [0:255] mat,
	input clock,
	output [0:15] row, col);

	wire [0:15] row_mask, col_mask, row_raw;
	
	left_shift_register #(.WIDTH(16)) col_mask_generator(clock, col_mask);
	left_shift_register #(.WIDTH(16)) row_mask_generator(~col_mask[0], row_mask);

	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1) begin: assign_row
			assign row_raw[i] = |(mat[i*16:i*16+15] & col_mask);
		end
	endgenerate
	assign row = row_raw & row_mask;
	assign col = ~col_mask;
endmodule

module left_shift_register
	#(parameter WIDTH)
	(input clock, output reg [0:WIDTH - 1] value = 0);

	genvar i;
	generate
		for (i = 1; i < WIDTH; i = i + 1) begin: shift_one
			always@(posedge clock) begin
				value[i - 1] <= value[i];
			end
		end
	endgenerate
	always@(posedge clock) begin
		value[WIDTH - 1] <= ~(|value[1:WIDTH-1]);
	end
endmodule

