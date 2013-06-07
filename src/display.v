/*
 * $File: display.v
 * $Date: Tue Jun 04 01:55:08 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


/*
 * 16x16 led matrix display driver
 * input: mat: matrix to be displayed, row-major order, 1 means light
 */

module disp_matrix(
	input [0:255] mat,
	input clock,
	output reg [0:15] row, col);

	reg is_row_scan;
	wire [0:15] scan_mask, row_scan_rst, col_scan_rst;

	left_shift_register#(.WIDTH(16)) shift_scan_mask(is_row_scan, scan_mask);


	always @(posedge clock) begin
		if (is_row_scan) begin
			row <= scan_mask;
			col <= row_scan_rst;
		end
		else begin
			row <= col_scan_rst;
			col <= ~scan_mask;
		end
		is_row_scan <= ~is_row_scan;
	end


	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1) begin: assign_column
			assign row_scan_rst[i] = ~(
				(scan_mask[0] & mat[i + 0]) |
				(scan_mask[1] & mat[i + 16]) |
				(scan_mask[2] & mat[i + 32]) |
				(scan_mask[3] & mat[i + 48]) |
				(scan_mask[4] & mat[i + 64]) |
				(scan_mask[5] & mat[i + 80]) |
				(scan_mask[6] & mat[i + 96]) |
				(scan_mask[7] & mat[i + 112]) |
				(scan_mask[8] & mat[i + 128]) |
				(scan_mask[9] & mat[i + 144]) |
				(scan_mask[10] & mat[i + 160]) |
				(scan_mask[11] & mat[i + 176]) |
				(scan_mask[12] & mat[i + 192]) |
				(scan_mask[13] & mat[i + 208]) |
				(scan_mask[14] & mat[i + 224]) |
				(scan_mask[15] & mat[i + 240]));
		end
	endgenerate
	generate
		for (i = 0; i < 16; i = i + 1) begin: assign_row
			assign col_scan_rst[i] = |(mat[i*16:i*16+15] & scan_mask);
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

