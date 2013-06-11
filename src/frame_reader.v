/*
 * $File: frame_reader.v
 * $Date: Tue Jun 11 16:10:20 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


/*
* UFM memory layout:
* first k 8-bit words:
* (start addr >> 1) for frame k, start addr must be aligned on even bounder
*
*/
module frame_reader
	#(parameter
		FRAME_NUM_WIDTH = 8,
		FRAME_SIZE = 256)	// must be divisor of 256
	(
		input [FRAME_NUM_WIDTH-1:0] frame_num,
		input clock,
		output reg [0:FRAME_SIZE-1] frame_content);

	`include "frame_reader_fh.inc.v"

	// reg [0:FRAME_SIZE-1] frame_content;
	reg frame_content_low_assign, frame_content_clr;
	reg [1:0] state = 0;
	`define STATE_FIND_CONTENT_START	0
	`define STATE_FIND_CONTENT_END		1
	`define STATE_READ_CONTENT			2
	`define STATE_SHIFT_FRAME			3

	reg [8:0] ufm_addr;
	reg ufm_enable = 0, disable_ufm_clk = 0;

	wire ufm_ready, ufm_so;
	wire [FRAME_NUM_WIDTH-1:0] frame_num_next;
	plus1 #(.WIDTH(FRAME_NUM_WIDTH)) adder_frame_num (frame_num, frame_num_next);

	reg [15:0]content_start, content_end;
	reg [7:0] frame_cur_cell = 0,		// cell number of frame_content[0]
				frame_target_cell = 0;	// read from UFM
	reg [4:0] ufm_data_cnt;	// how many bits of ufm so data have been read
	wire ufm_data_cnt_half = ufm_data_cnt[4] | (ufm_data_cnt[3] & ~(|ufm_data_cnt[2:0]));
	wire [4:0] ufm_data_cnt_next;
	wire [7:0] content_start_next, frame_cur_cell_next;
	wire [0:FRAME_SIZE-1] frame_content_and_clr;

	plus1 #(.WIDTH(5)) adder_ufm_data_cnt(ufm_data_cnt, ufm_data_cnt_next);
	plus1 #(.WIDTH(8)) adder_content_start(content_start[7:0], content_start_next);
	plus1 #(.WIDTH(8)) adder_frame_cur_cell(frame_cur_cell, frame_cur_cell_next);

	ufm_reader ufm_reader_comp(.clock(clock | disable_ufm_clk),
		.enable(ufm_enable), .addr(ufm_addr),
		.data(ufm_so), .data_ready(ufm_ready));

	genvar i;
	generate
		for (i = 0; i < FRAME_SIZE; i = i + 1) begin: and_frame_content
			assign frame_content_and_clr[i] =
				frame_content[i] & ~frame_content_clr;
		end
	endgenerate

	// change frame content at negative edge
	always@(negedge clock) begin
		frame_cur_cell <= frame_cur_cell_next;
		frame_content <= {frame_content_and_clr[1:FRAME_SIZE-1],
				frame_content_and_clr[0] | frame_content_low_assign};
	end

	always@(posedge clock) begin
		case(state)
			`STATE_FIND_CONTENT_START: begin
				if (!ufm_enable) begin
					ufm_enable <= 1;
					ufm_addr <= frame_num[FRAME_NUM_WIDTH-1:1];
					ufm_data_cnt <= 0;
				end
				else if (ufm_ready) begin
					if (ufm_data_cnt[4]) begin
						ufm_enable <= 0;
						if (!frame_num[0])
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
				if (!ufm_enable) begin
					ufm_enable <= 1;
					ufm_addr <= frame_num_next[FRAME_NUM_WIDTH-1:1];
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
					ufm_enable <= 1;
					if (frame_num >= `FRAME_HIGHERPART)
						ufm_addr <= {1'b1, content_start[7:0]};
					else
						ufm_addr <= {1'b0, content_start[7:0]};
					ufm_data_cnt <= 0;
				end
				else if (ufm_ready) begin
					if (content_start[7:0] == content_end[7:0]) begin
						ufm_enable <= 0;
						state <= `STATE_SHIFT_FRAME;
					end
					else begin
						if (ufm_data_cnt_half) begin
							if (frame_cur_cell != frame_target_cell)
								disable_ufm_clk <= 1;
							else begin
								disable_ufm_clk <= 0;
								if (ufm_data_cnt[4]) begin
									content_start[7:0] <= content_start_next;
									ufm_data_cnt <= 1;
									frame_target_cell[0] <= ufm_so;
								end else begin
									ufm_data_cnt <= ufm_data_cnt_next;
									frame_target_cell <= {frame_target_cell[6:0], ufm_so};
								end
							end
						end
						else begin
							ufm_data_cnt <= ufm_data_cnt_next;
							frame_target_cell <= {frame_target_cell[6:0], ufm_so};
						end
					end
				end
			end // STATE_READ_CONTENT

			`STATE_SHIFT_FRAME: begin
				if (!frame_cur_cell) begin
					// frame_content_out <= frame_content;
					state <= `STATE_FIND_CONTENT_START;
				end
			end	// STATE_SHIFT_FRAME

			default: begin
				state <= `STATE_FIND_CONTENT_START;
				ufm_enable <= 0;
			end
		endcase

		if (state == `STATE_READ_CONTENT && ufm_ready && ufm_data_cnt_half
				&& frame_cur_cell == frame_target_cell)
			frame_content_low_assign <= 1;
		else
			frame_content_low_assign <= 0;
	end

endmodule


module ufm_reader(
	input clock, enable,	// enable should be changed on posedge
	input [8:0] addr,		// should be readable on negedge
	output data,			// data should be read on posedge when data_ready is high
	output reg data_ready);

	wire spi_si;

	reg [23:0] cmd_to_send;
	reg unsigned [4:0] counter_cmd;
	reg spi_ncs = 1'b1;	
	wire [4:0] counter_cmd_next;
	plus1 #(.WIDTH(5)) adder_counter_cmd(counter_cmd, counter_cmd_next);

	reg enable_prev;
	wire enable_flip_to_high, enable_flip_to_low;
	assign enable_flip_to_high = ~enable_prev & enable;
	assign enable_flip_to_low = enable_prev & ~enable;
	always@(negedge clock)
		enable_prev <= enable;

	assign spi_si = cmd_to_send[23];

	spi spi_component (.ncs(spi_ncs), .sck(clock), .si(spi_si), .so(data));

	// sending cmd on negedge
	always@(negedge clock) begin
		if (enable_flip_to_high) begin
			cmd_to_send <= {15'b000000110000000, addr};
			spi_ncs <= 0;
			data_ready <= 0;
			counter_cmd <= 0;
		end
		else if (!spi_ncs) begin
			if (counter_cmd == 23)
				data_ready <= 1;
			cmd_to_send <= cmd_to_send << 1;
			counter_cmd <= counter_cmd_next;
		end
		if (enable_flip_to_low) begin
			data_ready <= 0;
			spi_ncs <= 1;
		end
	end

endmodule

