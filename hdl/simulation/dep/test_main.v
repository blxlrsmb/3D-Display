/*
 * $File: test_main.v
 * $Date: Wed Jun 12 16:12:04 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 10ns/1ns

module test_main;
	wire clock;
	wire [0:15] row, col;
	reg clock_cycle = 0;
	clock_gen clock_gen_comp(clock);
	main main_comp(clock, clock_cycle, row, col);

	always
		#500000 clock_cycle = ~clock_cycle;
endmodule


