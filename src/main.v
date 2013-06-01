/*
 * $File: main.v
 * $Date: Fri May 31 23:24:49 2013 +0800
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
	output reg [0:15] row, col);

	reg clock_row_scan, clock_col_scan, is_row_scan;
	wire [0:15] row_scan_row, row_scan_col, col_scan_row, col_scan_col;

	disp_matrix_colscan disp_by_col_scan(mat, clock_col_scan,
		col_scan_row, col_scan_col);

	disp_matrix_rowscan disp_by_row_scan(mat, clock_row_scan,
		row_scan_row, row_scan_col);

	always @(posedge clock) begin
		if (is_row_scan) begin
			clock_row_scan <= ~clock_row_scan;
			row <= row_scan_row;
			col <= row_scan_col;
		end
		else begin
			clock_col_scan <= ~clock_col_scan;
			row <= col_scan_row;
			col <= col_scan_col;
		end
		is_row_scan <= ~is_row_scan;
	end
endmodule

module disp_matrix_colscan(
	input [0:255] mat,
	input clock,
	output [0:15] row, col);

	wire [0:15] col_mask;

	assign col = ~col_mask;
	left_shift_register#(.WIDTH(16)) shift_col_mask(clock, col_mask);

	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1) begin: assign_row
			assign row[i] = |(mat[i*16:i*16+15] & col_mask);
		end
	endgenerate
endmodule

module disp_matrix_rowscan(
	input [0:255] mat_orig,
	input clock,
	output [0:15] row, col);

	left_shift_register#(.WIDTH(16)) shift_row_mask(clock, row);

	wire [0:255] mat;

	assign mat = ~mat_orig;

	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1) begin: assign_column
			assign col[i] =
				(row[0] & mat[i + 0]) |
				(row[1] & mat[i + 16]) |
				(row[2] & mat[i + 32]) |
				(row[3] & mat[i + 48]) |
				(row[4] & mat[i + 64]) |
				(row[5] & mat[i + 80]) |
				(row[6] & mat[i + 96]) |
				(row[7] & mat[i + 112]) |
				(row[8] & mat[i + 128]) |
				(row[9] & mat[i + 144]) |
				(row[10] & mat[i + 160]) |
				(row[11] & mat[i + 176]) |
				(row[12] & mat[i + 192]) |
				(row[13] & mat[i + 208]) |
				(row[14] & mat[i + 224]) |
				(row[15] & mat[i + 240]);
		end
	endgenerate
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

