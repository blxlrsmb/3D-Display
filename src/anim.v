/*
* $File: anim.v
* $Date: Tue Jun 11 11:40:51 2013 +0800
* $Author: jiakai <jia.kai66@gmail.com>
*/


/*
* render an animation
* fb: frame bucket, frames to be displayed in one cycle
*/
module animation_renderer
	(input clock, clock_cycle,
	 clock_fb, // signal to switch to next frame bucket
	 output reg unsigned [7:0] frame_num);

	`define COUNTER_WIDTH	26
	`define FB_SIZE	8'd9
	`define FB_SIZE_M1	8'd8
	`define FB_SIZE_INV	26'd14913081

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

	assign clk_per_frame = clk_per_fb * 2; //`FB_SIZE_INV;

	always@(posedge clock)
		if (clock_cycle_flip) begin
			clk_per_fb <= fb_clk_cnt;
			fb_clk_cnt <= 0;
		end
		else fb_clk_cnt <= fb_clk_cnt_next;


	always@(posedge clock)
		if (cur_frame_clk_cnt >= clk_per_frame) begin
			cur_frame_clk_cnt <= 0;
			if (frame_num == `FB_SIZE_M1)
				frame_num <= 0;
			else
				frame_num <= frame_num_next;
		end
		else cur_frame_clk_cnt <= cur_frame_clk_cnt_next;


endmodule


