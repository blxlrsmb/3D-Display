/*
* $File: anim.v
* $Date: Wed Jun 12 16:31:50 2013 +0800
* $Author: jiakai <jia.kai66@gmail.com>
*/


/*
* render an animation
* fb: frame bucket, frames to be displayed in one cycle
*/
module animation_renderer
	(input clock, clock_cycle,
	 clock_next_fb, // signal to switch to next frame bucket (unimplemented)
	 output reg unsigned [7:0] frame_num);

	`define COUNTER_WIDTH	26
	`include "frame_reader_fh.inc.v"

	wire [7:0] frame_num_next;
	plus1 #(.WIDTH(8)) adder_frame_num(frame_num, frame_num_next);

	reg unsigned [`COUNTER_WIDTH-1:0]
		clk_per_fb = 0, fb_clk_cnt = 0, cur_frame_clk_cnt = 0;
	reg clock_cycle_prev;
	wire clock_cycle_flip;
	wire [`COUNTER_WIDTH-1:0]
		fb_clk_cnt_next, clk_per_frame, cur_frame_clk_cnt_next;
	assign clock_cycle_flip = ~clock_cycle_prev & clock_cycle;

	always@(posedge clock)
		clock_cycle_prev <= clock_cycle;

	plus1 #(.WIDTH(`COUNTER_WIDTH)) adder_fb_clk_cnt(fb_clk_cnt, fb_clk_cnt_next);
	plus1 #(.WIDTH(`COUNTER_WIDTH)) adder_cur_frame_clk_cnt(
		cur_frame_clk_cnt, cur_frame_clk_cnt_next);
	small_divider #(.WIDTH(`COUNTER_WIDTH)) div_clk_per_frame(clock,
		clk_per_fb, {18'b0, `FB_SIZE}, clk_per_frame);

	always@(posedge clock)
		if (clock_cycle_flip) begin
			clk_per_fb <= fb_clk_cnt;
			fb_clk_cnt <= 0;
		end
		else fb_clk_cnt <= fb_clk_cnt_next;


	always@(posedge clock)
		if (cur_frame_clk_cnt >= clk_per_frame) begin
			cur_frame_clk_cnt <= 0;
			if (frame_num >= `FB_SIZE_M1)
				frame_num <= 0;
			else
				frame_num <= frame_num_next;
		end
		else cur_frame_clk_cnt <= cur_frame_clk_cnt_next;


	initial begin
		frame_num = 0;
		clk_per_fb = `FB_SIZE * 10000;
	end
endmodule

