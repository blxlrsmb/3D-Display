/*
 * $File: main.v
 * $Date: Tue Jun 11 23:00:18 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module main(
	input clock, clock_cycle,
	output [0:15] row, col);

	wire [7:0] point;
	wire point_enable, clock_cycle_stable;
	wire [7:0] frame_num;
	reg clock_div;

	always @(posedge clock)
		clock_div <= ~clock_div;

	disp_matrix disp_matrix_comp(
		.enable(point_enable), .addr(point), .row(row), .col(col));

	frame_reader frame_reader_comp(
		.frame_num(frame_num), .clock(clock_div), .point_coord(point),
		.point_enable(point_enable));

	animation_renderer anim_comp(
		.clock(clock), .clock_cycle(clock_cycle_stable), .clock_next_fb(1'b0),
		.frame_num(frame_num));

	signal_stablizer #(.STABLE_TIME_LOG(13)) signal_stablizer_clock_cycle(
		.clock(clock), .si(clock_cycle), .so(clock_cycle_stable));
endmodule

