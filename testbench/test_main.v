/*
 * $File: test_main.v
 * $Date: Tue Jun 11 17:36:00 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 10ns/1ns

module test_main;
	wire clock;
	wire [0:15] row, col;
	clock_gen clock_gen_comp(clock);
	main main_comp(clock, 0'b0, row, col);
endmodule


