/*
 * $File: adder.v
 * $Date: Mon Jun 10 17:10:37 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

module plus1
    #(parameter WIDTH)
    (input [WIDTH-1:0] i,
    output [WIDTH-1:0] o);

    assign o = i + 1'b1;
endmodule

