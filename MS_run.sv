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
output reg [3:0] out_x, out_y ;

logic out_valid_next;
logic maze_not_valid_next;
logic [3:0] out_x_next, out_y_next ;

logic map [0:14][0:14];
logic map_next [0:14][0:14];
//coming from which direction
logic [1:0]	map_directions [0:12][0:12];
logic [1:0]	map_directions_next [0:12][0:12];

logic [7:0] counter_in;
logic [7:0] counter_in_next;

logic [3:0] queue_bfs_x [0:23];
logic [3:0] queue_bfs_y [0:23];
logic [3:0] queue_bfs_x_next [0:23];
logic [3:0] queue_bfs_y_next [0:23];

logic [4:0] counter_queue;// queue index
logic [4:0] counter_queue_next;

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

logic x1;
logic [1:0] x2;
logic [1:0] x3;
logic [1:0] x4;

always_ff @( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
	// inputting
		now 			<= IDLE;
		out_valid 		<= 0;
		maze_not_valid 	<= 0;
		out_x 			<= 0;
		out_y 			<= 0;

		// map <= '{default:0};
		// map_directions <= '{default:0};
		counter_in <= 0;
		counter_queue <= 0;
		queue_bfs_x <= '{default:0};
		queue_bfs_y <= '{default:0};
	end else begin
	// inputting
		now 			<= next;
		map 			<= map_next;
		out_valid 		<= out_valid_next;
		maze_not_valid 	<= maze_not_valid_next;
		out_x 			<= out_x_next;
		out_y 			<= out_y_next;
		counter_in 		<= counter_in_next;

	// running
		queue_bfs_x 	<= queue_bfs_x_next;
		queue_bfs_y 	<= queue_bfs_y_next;
		counter_queue 	<= counter_queue_next;
		map_directions 	<= map_directions_next;
	end
end

always_comb begin
	// default first!!
	next 				= now;
	out_valid_next 		= 0;
	maze_not_valid_next = 0;
	counter_in_next 	= 0;
	map_next 			= map;
	out_x_next 			= 0;
	out_y_next 			= 0;
	counter_queue_next 	= 0;
	queue_bfs_x_next 	= queue_bfs_x;
	queue_bfs_y_next 	= queue_bfs_y;
	map_directions_next = map_directions;
	
	map_next[1][0] 		= 1;
	map_next[1][1] 		= 1;
	map_next[0][0:14] 	= '{default:1};

	// input
	if(in_valid) begin
		counter_in_next 	= counter_in + 1;
		map_next[14][0:13] 	= map[14][1:14];
		map_next[14][14]   	= maze;
		map_next[13][0:13] 	= map[13][1:14];
		map_next[13][14]   	= map[14][0];
		map_next[12][0:13] 	= map[12][1:14];
		map_next[12][14]   	= map[13][0];
		map_next[11][0:13] 	= map[11][1:14];
		map_next[11][14]   	= map[12][0];
		map_next[10][0:13] 	= map[10][1:14];
		map_next[10][14]   	= map[11][0];
		map_next[9][0:13]  	= map[9][1:14];
		map_next[9][14]    	= map[10][0];
		map_next[8][0:13]  	= map[8][1:14];
		map_next[8][14]    	= map[9][0];
		map_next[7][0:13]  	= map[7][1:14];
		map_next[7][14]    	= map[8][0];
		map_next[6][0:13]  	= map[6][1:14];
		map_next[6][14]    	= map[7][0];
		map_next[5][0:13]  	= map[5][1:14];
		map_next[5][14]    	= map[6][0];
		map_next[4][0:13]  	= map[4][1:14];
		map_next[4][14]    	= map[5][0];
		map_next[3][0:13]  	= map[3][1:14];
		map_next[3][14]    	= map[4][0];
		map_next[2][0:13]  	= map[2][1:14];
		map_next[2][14]    	= map[3][0];
		map_next[1][2:13]  	= map[1][3:14];
		map_next[1][14]    	= map[2][0];
	end

	// FSM
	case(now)
		IDLE:
			if (counter_in == 8'd224)
				if (map[1][2] == 1 || map[13][14] == 1) 		next = DEAD;
				else 											next = FIND;
 		BACK: if (queue_bfs_x[0] == 1 && queue_bfs_y[0] == 1) 	next = IDLE;
 		DEAD: 													next = IDLE;
	endcase

	case(now)
		IDLE:begin
			queue_bfs_x_next[0] = 1;
			queue_bfs_y_next[0] = 1;
		end
 		FIND:begin
		 	if (queue_bfs_x[0] == 13 && queue_bfs_y[0] == 13) begin
			// found
			 	next = BACK;
			end else if (counter_queue == 31) begin
			// dead
				next = DEAD;
			end else begin
				// pop queue
				queue_bfs_x_next[0:22] 	= queue_bfs_x[1:23];
				queue_bfs_x_next[23] 	= 0;
				queue_bfs_y_next[0:22] 	= queue_bfs_y[1:23];
				queue_bfs_y_next[23] 	= 0;
				x1 = 0;
				if (!map[queue_bfs_x[0]][queue_bfs_y[0] - 1]) begin
				// LEFT
					queue_bfs_x_next[counter_queue] 							= queue_bfs_x[0];
					queue_bfs_y_next[counter_queue] 							= queue_bfs_y[0] - 1;
					map_next[queue_bfs_x[0]][queue_bfs_y[0] - 1] 				= 1;
					map_directions_next[queue_bfs_x[0] - 1][queue_bfs_y[0] - 2] = RIGHT;
					x1 = 1;
				end
				x2 = x1;
				if (!map[queue_bfs_x[0] - 1][queue_bfs_y[0]]) begin
				// UP
					queue_bfs_x_next[counter_queue + x1] 						= queue_bfs_x[0] - 1;
					queue_bfs_y_next[counter_queue + x1] 						= queue_bfs_y[0];
					map_next[queue_bfs_x[0] - 1][queue_bfs_y[0]] 				= 1;
					map_directions_next[queue_bfs_x[0] - 2][queue_bfs_y[0] - 1] = DOWN;
					x2 = x1 + 1;
				end
				x3 = x2;
				if (!map[queue_bfs_x[0]][queue_bfs_y[0] + 1]) begin
				// RIGHT
					queue_bfs_x_next[counter_queue + x2] 					= queue_bfs_x[0];
					queue_bfs_y_next[counter_queue + x2] 					= queue_bfs_y[0] + 1;
					map_next[queue_bfs_x[0]][queue_bfs_y[0] + 1] 			= 1;
					map_directions_next[queue_bfs_x[0] - 1][queue_bfs_y[0]] = LEFT;
					x3 = x2 + 1;
				end
				x4 = x3;
				if (!map[queue_bfs_x[0] + 1][queue_bfs_y[0]]) begin
				// DOWN
					queue_bfs_x_next[counter_queue + x3] 					= queue_bfs_x[0] + 1;
					queue_bfs_y_next[counter_queue + x3] 					= queue_bfs_y[0];
					map_next[queue_bfs_x[0] + 1][queue_bfs_y[0]] 			= 1;
					map_directions_next[queue_bfs_x[0]][queue_bfs_y[0] - 1] = UP;
					x4 = x3 + 1;
				end
				counter_queue_next = counter_queue - 1 + x4;
			end
		end
 		BACK:begin
			out_valid_next 	= 1;
			out_x_next 		= queue_bfs_y[0];
			out_y_next 		= queue_bfs_x[0];

			case(map_directions[queue_bfs_x[0] - 1][queue_bfs_y[0] - 1])
				UP: begin
					queue_bfs_x_next[0] = queue_bfs_x[0] - 1;
					queue_bfs_y_next[0] = queue_bfs_y[0];
				end
				LEFT: begin
					queue_bfs_x_next[0] = queue_bfs_x[0];
					queue_bfs_y_next[0] = queue_bfs_y[0] - 1;
				end
				DOWN: begin
					queue_bfs_x_next[0] = queue_bfs_x[0] + 1;
					queue_bfs_y_next[0] = queue_bfs_y[0];
				end
				RIGHT: begin
					queue_bfs_x_next[0] = queue_bfs_x[0];
					queue_bfs_y_next[0] = queue_bfs_y[0] + 1;
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