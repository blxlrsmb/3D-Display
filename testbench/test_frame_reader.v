/*
 * $File: test_frame_reader.v
 * $Date: Tue Jun 11 16:54:10 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 10ns/1ns
module test_frame_reader;
	wire clock, point_enable;
	wire [7:0] point_coord;
	clock_gen clock_gen_comp(clock);
	frame_reader frame_reader_comp(8'd2, clock, point_coord, point_enable);
endmodule


