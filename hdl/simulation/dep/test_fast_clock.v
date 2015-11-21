/*
 * $File: test_fast_clock.v
 * $Date: Tue Jun 11 21:52:58 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ns

module test_anim;
	reg clock = 0;
	reg clock_cycle = 0;
	wire [7:0] frame_num;

	animation_renderer anim_comp(
		clock, clock_cycle, 1'b0, frame_num);

	always 
		#1 clock = ~clock;

	always
		#20 clock_cycle <= ~clock_cycle;

endmodule

module test_divider;
	reg clock = 0;
	reg [7:0] a, b;
	wire [7:0] c;

	small_divider #(.WIDTH(8)) div_comp(clock, a, b, c);
	always
		#1 clock = ~clock;

	initial begin
		a = 8;
		b = 4;
		#20
		a = 123;
		b = 5;
		#20
		a = 255;
		b = 1;
		#20
		a = 1;
		b = 5;
		#20
		a = 0;
		b = 10;
	end

endmodule

