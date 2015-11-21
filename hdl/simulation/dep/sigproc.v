/*
 * $File: sigproc.v
 * $Date: Tue Jun 11 23:06:00 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module signal_stablizer
	#(parameter STABLE_TIME_LOG)
	(input clock, si,
	 output reg so);
	
	reg unsigned [STABLE_TIME_LOG-1:0]stable_cnt = 0;
	wire [STABLE_TIME_LOG-1:0] stable_cnt_next;
	plus1 #(.WIDTH(STABLE_TIME_LOG)) adder_stable_cnt(stable_cnt, stable_cnt_next);

	always@(posedge clock)
		if (so == si)
			stable_cnt <= 0;
		else begin
			if (&stable_cnt)
				so <= si;
			stable_cnt <= stable_cnt_next;
		end

endmodule

