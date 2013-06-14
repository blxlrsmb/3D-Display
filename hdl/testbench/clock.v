/*
 * $File: clock.v
 * $Date: Mon Jun 10 11:18:57 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


`timescale 10 ns/1ns
module clock_gen(
	output reg clock = 0);

	always #25 clock = ~clock;
endmodule

