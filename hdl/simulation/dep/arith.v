/*
 * $File: arith.v
 * $Date: Wed Jun 12 16:02:19 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module plus1
    #(parameter WIDTH)
    (input [WIDTH-1:0] a,
     output [WIDTH-1:0] b);

	wire carry[WIDTH-1:0];
	assign carry[0] = 1;
	genvar i;
	generate
		for (i = 0; i + 1 < WIDTH; i = i + 1) begin: assign_cary
			assign b[i] = a[i] ^ carry[i];
			assign carry[i + 1] = a[i] & carry[i];
		end
	endgenerate
	assign b[WIDTH - 1] = a[WIDTH - 1] ^ carry[WIDTH - 1];
endmodule

/*
* slow but small(low LE consumption) divider
* numerator = denominator * quotient + remainder
*/
module small_divider
	#(parameter WIDTH, WIDTH_LOG_MAX = 5)
	(input clock,
	 input unsigned [WIDTH-1:0] numerator, denominator,
	 output reg unsigned [WIDTH-1:0] quotient);


	reg [WIDTH*2-2:0] a = 0, b = 0;
	reg [WIDTH-1:0] c;	// c = a / b
	reg unsigned [WIDTH_LOG_MAX-1:0] pos;
	wire [WIDTH_LOG_MAX-1:0] pos_next;
	reg state = 0;
	`define STATE_READ_DATA	0
	`define STATE_CALC		1

	plus1 #(.WIDTH(WIDTH_LOG_MAX)) adder_pos(pos, pos_next);

	always@(posedge clock) begin 
		case (state)
			`STATE_READ_DATA: begin
				quotient <= c;
				a[WIDTH-1:0] <= numerator;
				b[WIDTH*2-2:WIDTH-1] <= denominator;
				state <= `STATE_CALC;
				pos <= 0;
			end
			`STATE_CALC: begin
				if (a >= b) begin
					a <= a - b;
					c <= {c[WIDTH-2:0], 1'b1};
				end else
					c <= {c[WIDTH-2:0], 1'b0};

				if (pos == WIDTH - 1) begin
					state <= `STATE_READ_DATA;
					a <= 0;
					b <= 0;
				end
				else b <= {1'b0, b[WIDTH*2-2:1]};
				pos <= pos_next;
			end
		endcase
	end

endmodule

