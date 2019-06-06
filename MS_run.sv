module MS(
	rst_n , 
	clk , 
	maze ,
	in_valid ,
	out_valid,
	maze_not_valid,
	out_x, 
	out_y
);

input rst_n, clk, maze ,in_valid ;
output reg out_valid;
output reg maze_not_valid;
output reg [3:0]out_x, out_y ;

logic out_valid_next;
logic maze_not_valid_next;
logic [3:0] out_x_next, out_y_next ;

logic map [0:14][0:14];
logic map_next [0:14][0:14];
//coming from which direction
logic [1:0]map_directions [1:13][1:13];
logic [1:0]map_directions_next [1:13][1:13];

logic [7:0] counter_in;
logic [7:0] counter_in_next;

logic [3:0] queue_bfs_x[0:13];
logic [3:0] queue_bfs_y[0:13];
logic [3:0] queue_bfs_x_next[0:13];
logic [3:0] queue_bfs_y_next[0:13];
logic [3:0] position_x;// current position x
logic [3:0] position_y;// current position y
logic [3:0] position_x_next;
logic [3:0] position_y_next;

logic [3:0] counter_queue;// queue index
logic [3:0] counter_queue_next;

parameter LEFT 	= 0;
parameter UP 	= 1;
parameter RIGHT = 2;
parameter DOWN 	= 3;

logic [1:0] now;
logic [1:0] next;
parameter IDLE = 2'd0;
parameter FIND = 2'd1;
parameter BACK = 2'd2;
parameter DEAD = 2'd3;

always_ff @( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
	// inputting
		now <= IDLE;
		out_valid <= 0;
		maze_not_valid <= 0;
		out_x <= 0;
		out_y <= 0;
	end else begin
	// inputting
		now <= next;
		map <= map_next;
		out_valid <= out_valid_next;
		maze_not_valid <= maze_not_valid_next;
		out_x <= out_x_next;
		out_y <= out_y_next;
		counter_in <= counter_in_next;

	// running
		queue_bfs_x <= queue_bfs_x_next;
		queue_bfs_y <= queue_bfs_y_next;
		position_x <= position_x_next;
		position_y <= position_y_next;
		counter_queue <= counter_queue_next;
		map_directions <= map_directions_next;
	end
end

always_comb begin
	// default first!!
	next = now;
	out_valid_next = 0;
	maze_not_valid_next = 0;
	counter_in_next = 0;
	map_next = map;
	out_x_next = 0;
	out_y_next = 0;
	
	counter_queue_next = 0;
	position_x_next = position_x;
	position_y_next = position_y;
	queue_bfs_x_next = queue_bfs_x;
	queue_bfs_y_next = queue_bfs_y;
	map_directions_next = map_directions;

	// input
	if(in_valid) begin
		counter_in_next = counter_in + 1;
		map_next[14][0:13] = map[14][1:14];
		map_next[14][14] 	 = maze;
		map_next[13][0:13] = map[13][1:14];
		map_next[13][14] 	 = map[14][0];
		map_next[12][0:13] = map[12][1:14];
		map_next[12][14] 	 = map[13][0];
		map_next[11][0:13] = map[11][1:14];
		map_next[11][14] 	 = map[12][0];
		map_next[10][0:13] = map[10][1:14];
		map_next[10][14] 	 = map[11][0];
		map_next[9][0:13]  = map[9][1:14];
		map_next[9][14] 	 = map[10][0];
		map_next[8][0:13]  = map[8][1:14];
		map_next[8][14] 	 = map[9][0];
		map_next[7][0:13]  = map[7][1:14];
		map_next[7][14] 	 = map[8][0];
		map_next[6][0:13]  = map[6][1:14];
		map_next[6][14] 	 = map[7][0];
		map_next[5][0:13]  = map[5][1:14];
		map_next[5][14] 	 = map[6][0];
		map_next[4][0:13]  = map[4][1:14];
		map_next[4][14] 	 = map[5][0];
		map_next[3][0:13]  = map[3][1:14];
		map_next[3][14] 	 = map[4][0];
		map_next[2][0:13]  = map[2][1:14];
		map_next[2][14] 	 = map[3][0];
		map_next[1][0:13]  = map[1][1:14];
		map_next[1][14] 	 = map[2][0];
		map_next[0][0:13]  = map[0][1:14];
		map_next[0][14] 	 = map[1][0];
	end

	// FSM
	case(now)
		IDLE:
			if (counter_in == 8'd224)
				if (map[1][2]==1 || map[13][14]==1) next = DEAD;
				else next = FIND;
 		// FIND:
			// if (position_x==13 && position_y==13) next = BACK;
			// else if(counter_queue == 0) next = DEAD;
 		BACK: if (position_x==1 && position_y==1) next = IDLE;
 		DEAD: next = IDLE;
	endcase

	// other things
	case(now)
		IDLE:begin
			position_x_next = 1;
			position_y_next = 1;
		end
 		FIND:begin
			// you see see how to do this a better way Mark
			// need this to avoid state transition error
		 	if (position_x == 13 && position_y == 13) begin
			// found
			 	next = BACK;
			end else if (!map[position_x][position_y - 1]) begin
			// LEFT
				queue_bfs_x_next[counter_queue] = position_x;
				queue_bfs_y_next[counter_queue] = position_y - 1;
				counter_queue_next = counter_queue + 1;
				map_next[position_x][position_y - 1] = 1;
				map_directions_next[position_x][position_y - 1] = RIGHT;
			end else if (!map[position_x - 1][position_y]) begin
			// UP
				queue_bfs_x_next[counter_queue] = position_x - 1;
				queue_bfs_y_next[counter_queue] = position_y;
				counter_queue_next = counter_queue + 1;
				map_next[position_x - 1][position_y] = 1;
				map_directions_next[position_x - 1][position_y] = DOWN;
			end else if (!map[position_x][position_y + 1]) begin
			// RIGHT
				queue_bfs_x_next[counter_queue] = position_x;
				queue_bfs_y_next[counter_queue] = position_y + 1;
				counter_queue_next = counter_queue + 1;
				map_next[position_x][position_y + 1] = 1;
				map_directions_next[position_x][position_y + 1] = LEFT;
			end else if (!map[position_x + 1][position_y]) begin
			// DOWN
				queue_bfs_x_next[counter_queue] = position_x + 1;
				queue_bfs_y_next[counter_queue] = position_y;
				counter_queue_next = counter_queue + 1;
				map_next[position_x + 1][position_y] = 1;
				map_directions_next[position_x + 1][position_y] = UP;
			end else if ( counter_queue > 0 ) begin
			// pop queue
				position_x_next = queue_bfs_x[0];
				position_y_next = queue_bfs_y[0];
				counter_queue_next = counter_queue - 1;
				queue_bfs_x_next[0:12] = queue_bfs_x[1:13];
				queue_bfs_x_next[13] = 0;
				queue_bfs_y_next[0:12] = queue_bfs_y[1:13];
				queue_bfs_y_next[13] = 0;
			end else if (counter_queue == 0) begin
			// dead
				next = DEAD;
			end
		end
 		BACK:begin
			out_valid_next = 1;
			out_x_next = position_y;
			out_y_next = position_x;

			case(map_directions[position_x][position_y])
				UP: begin
					position_x_next = position_x - 1;
					position_y_next = position_y;
				end
				LEFT: begin
					position_x_next = position_x;
					position_y_next = position_y - 1;
				end
				DOWN: begin
					position_x_next = position_x + 1;
					position_y_next = position_y;
				end
				RIGHT: begin
					position_x_next = position_x;
					position_y_next = position_y + 1;
				end
			endcase
		end
 		DEAD:begin
			out_valid_next = 1;
			maze_not_valid_next = 1;
		end
	endcase
end

endmodule