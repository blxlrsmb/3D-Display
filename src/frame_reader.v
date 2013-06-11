/*
 * $File: frame_reader.v
 * $Date: Tue Jun 11 19:41:15 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


/*
* UFM memory layout:
* first k 8-bit words:
* (start addr >> 1) for frame k, start addr must be aligned on even bounder
*
*/
module frame_reader
	(input [7:0] frame_num,
	 input clock,
	 output reg [7:0] point_coord,
	 output reg point_enable);

	`include "frame_reader_fh.inc.v"

	// reg [0:FRAME_SIZE-1] frame_content;
	reg [1:0] state = 0;
	`define STATE_FIND_CONTENT_START	1
	`define STATE_FIND_CONTENT_END		2
	`define STATE_READ_CONTENT			3

	reg [8:0] ufm_addr;
	reg ufm_enable = 0;

	wire ufm_ready, ufm_so;

	reg [15:0]content_start, content_end;
	reg [4:0] ufm_data_cnt;	// how many bits of ufm so data have been read
	reg [7:0] ufm_8bit_shift, saved_frame_num, content_cur;
	wire [4:0] ufm_data_cnt_next;
	wire [7:0] content_cur_next;
	wire [7:0] frame_num_next;

	plus1 #(.WIDTH(8)) adder_frame_num (saved_frame_num, frame_num_next);
	plus1 #(.WIDTH(5)) adder_ufm_data_cnt(ufm_data_cnt, ufm_data_cnt_next);
	plus1 #(.WIDTH(8)) adder_content_start(content_cur, content_cur_next);

	ufm_reader ufm_reader_comp(.clock(clock),
		.enable(ufm_enable), .addr(ufm_addr),
		.data(ufm_so), .data_ready(ufm_ready));


	always@(posedge clock) begin
		case(state)
			`STATE_FIND_CONTENT_START: begin
				point_enable <= 0;
				if (!ufm_enable) begin
					ufm_enable <= 1;
					ufm_addr <= frame_num[7:1];
					saved_frame_num <= frame_num;
					ufm_data_cnt <= 0;
				end
				else if (ufm_ready) begin
					if (ufm_data_cnt[4]) begin
						ufm_enable <= 0;
						if (!saved_frame_num[0])
							content_start[7:0] <= content_start[15:8];
						state <= `STATE_FIND_CONTENT_END;
					end
					else begin
						content_start <= {content_start[14:0], ufm_so};
						ufm_data_cnt <= ufm_data_cnt_next;
					end
				end
			end	// STATE_FIND_CONTENT_START

			`STATE_FIND_CONTENT_END: begin
				point_enable <= 0;
				if (!ufm_enable) begin
					ufm_enable <= 1;
					ufm_addr <= frame_num_next[7:1];
					ufm_data_cnt <= 0;
				end
				else if (ufm_ready) begin
					if (ufm_data_cnt[4]) begin
						ufm_enable <= 0;
						if (!frame_num_next[0])
							content_end[7:0] <= content_end[15:8];
						state <= `STATE_READ_CONTENT;
					end
					else begin
						content_end <= {content_end[14:0], ufm_so};
						ufm_data_cnt <= ufm_data_cnt_next;
					end
				end
			end // STATE_FIND_CONTENT_END

			`STATE_READ_CONTENT: begin
				if (!ufm_enable) begin
					point_enable <= 0;
					if (content_start[7:0] == content_end[7:0]) begin
						state <= `STATE_FIND_CONTENT_START;
					end
					else begin
						content_cur <= content_start[7:0];
						ufm_enable <= 1;
						if (saved_frame_num >= `FRAME_HIGHERPART)
							ufm_addr <= {1'b1, content_start[7:0]};
						else
							ufm_addr <= {1'b0, content_start[7:0]};
						ufm_data_cnt <= 0;
					end
				end
				else if (ufm_ready) begin
					if (content_cur == content_end[7:0]) begin
						ufm_enable <= 0;
						if (frame_num == saved_frame_num)
							state <= `STATE_READ_CONTENT;
						else
							state <= `STATE_FIND_CONTENT_START;
					end
					else begin
						if (ufm_data_cnt[4] || ufm_data_cnt[3:0] == 4'b1000)  begin
							point_coord <= ufm_8bit_shift;
							point_enable <= 1;
						end

						if (ufm_data_cnt[4]) begin
							content_cur <= content_cur_next;
							ufm_data_cnt <= 1;
						end
						else ufm_data_cnt <= ufm_data_cnt_next;
					end
				end
			end // STATE_READ_CONTENT

			default: begin
				state <= `STATE_FIND_CONTENT_START;
				ufm_enable <= 0;
			end
		endcase
	end

	always@(posedge clock)
		ufm_8bit_shift <= {ufm_8bit_shift[6:0], ufm_so};

endmodule


module ufm_reader(
	input clock, enable,	// enable should be changed on posedge
	input [8:0] addr,		// should be readable on negedge
	output data,			// data should be read on posedge when data_ready is high
	output reg data_ready);

	reg [23:0] cmd_to_send;
	reg unsigned [4:0] counter_cmd;
	reg spi_enbl = 0;

	wire [4:0] counter_cmd_next;
	plus1 #(.WIDTH(5)) adder_counter_cmd(counter_cmd, counter_cmd_next);

	wire spi_si = cmd_to_send[23];

	reg enable_prev;
	wire enable_flip_to_high = ~enable_prev & enable,
		enable_flip_to_low = enable_prev & ~enable;
	always@(negedge clock)
		enable_prev <= enable;

	spi spi_comp (.ncs(~spi_enbl), .sck(clock), .si(spi_si), .so(data));

	// sending cmd on negedge
	always@(negedge clock) begin
		if (enable_flip_to_high) begin
			cmd_to_send <= {15'b000000110000000, addr};
			spi_enbl <= 1;
			data_ready <= 0;
			counter_cmd <= 0;
		end
		else if (spi_enbl) begin
			if (counter_cmd == 23)
				data_ready <= 1;
			cmd_to_send <= cmd_to_send << 1;
			counter_cmd <= counter_cmd_next;
		end
		if (enable_flip_to_low) begin
			data_ready <= 0;
			spi_enbl <= 0;
		end
	end

endmodule

