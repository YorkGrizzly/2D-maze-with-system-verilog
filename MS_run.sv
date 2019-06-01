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
logic map_was_here [0:14][0:14];
logic map_was_here_next [0:14][0:14];

logic [7:0] counter_in;
logic [7:0] counter_in_next;

logic [3:0] queue_bfs_x[0:12];
logic [3:0] queue_bfs_y[0:12];
logic [3:0] queue_bfs_x_next[0:12];
logic [3:0] queue_bfs_y_next[0:12];
logic [3:0] position_x;// current position x
logic [3:0] position_y;// current position y
logic [3:0] position_x_next;// current position x
logic [3:0] position_y_next;// current position y
logic signed [4:0] counter_queue;// queue index
logic signed [4:0] counter_queue_next;

logic[2:0] direction, direction_next;
parameter UP = 0, DOWN = 2, LEFT = 1, RIGHT = 3, OVER = 4;

// reset -> waiting for input -> input -> begin to find 
// if found -> go back and output the path at same time
// if not found -> 
parameter IDLE = 2'd0;
parameter FIND = 2'd1;
parameter BACK = 2'd2;
parameter DEAD = 2'd3;

logic [1:0] now;
logic [1:0] next;

// state & I/O
always_ff @( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		now <= IDLE;
		map <= '{default:0};
		out_valid <= 0;
		maze_not_valid <= 0;
		out_x <= 0;
		out_y <= 0;
		counter_in <= 0;
	end else begin
		now <= next;
		map <= map_next;
		out_valid <= out_valid_next;
		maze_not_valid <= maze_not_valid_next;
		out_x <= out_x_next;
		out_y <= out_y_next;
		counter_in <= counter_in_next;
	end
end

always_comb begin
	next = now;
	out_valid_next = 0;
	case(now)
		IDLE: if (counter_in == 8'd224) next = FIND;
 		FIND:
			if (position_x==13 && position_y==13) next = BACK;
			else if(counter_queue == -1) next = DEAD;
 		BACK: if (position_x==1 && position_y==1) next = IDLE;
 		DEAD: if (counter_queue==0) next = IDLE;
	endcase
	if (now == DEAD || now == BACK) begin
		out_valid_next = (now == BACK)||(now == DEAD);
	end
	if (now == DEAD) begin
		maze_not_valid_next = now == DEAD;
	end
	if (now == BACK) begin








		out_x_next = position_y;
		out_y_next = position_x;









	end
	map_next = map;
	if(in_valid) begin
		counter_in_next = counter_in + 1;
		map_next[14][0:14] = {map[14][1:14], maze};
		map_next[13][0:14] = {map[13][1:14], map[14][0]};
		map_next[12][0:14] = {map[12][1:14], map[13][0]};
		map_next[11][0:14] = {map[11][1:14], map[12][0]};
		map_next[10][0:14] = {map[10][1:14], map[11][0]};
		map_next[9][0:14] = {map[9][1:14], map[10][0]};
		map_next[8][0:14] = {map[8][1:14], map[9][0]};
		map_next[7][0:14] = {map[7][1:14], map[8][0]};
		map_next[6][0:14] = {map[6][1:14], map[7][0]};
		map_next[5][0:14] = {map[5][1:14], map[6][0]};
		map_next[4][0:14] = {map[4][1:14], map[5][0]};
		map_next[3][0:14] = {map[3][1:14], map[4][0]};
		map_next[2][0:14] = {map[2][1:14], map[3][0]};
		map_next[1][0:14] = {map[1][1:14], map[2][0]};
		map_next[0][0:14] = {map[0][1:14], map[1][0]};
	end
end

// traversing operations
always_ff @( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		queue_bfs_x <= '{default:0};
		queue_bfs_y <= '{default:0};
		position_x <= 0;
		position_y <= 0;
		counter_queue <= 0;
	  map_was_here <= '{default:0};
		direction <= UP;
	end else begin
		queue_bfs_x <= queue_bfs_x_next;
		queue_bfs_y <= queue_bfs_y_next;
		position_x <= position_x_next;
		position_y <= position_y_next;
		counter_queue <= counter_queue_next;
	  map_was_here <= map_was_here_next;
		direction <= direction_next;
	end
end

always_comb begin
	map_was_here_next = map_was_here;
	counter_queue_next = counter_queue;
	position_x_next = position_x;
	position_y_next = position_y;
	queue_bfs_x_next = queue_bfs_x;
	queue_bfs_y_next = queue_bfs_y;

	if (now == IDLE) begin
		queue_bfs_x_next = '{default:0};
		queue_bfs_y_next = '{default:0};
		counter_queue_next = 0;
		position_x_next = 1;
		position_y_next = 1;
		map_was_here_next[1][1] = 1;
		map_was_here_next[14][0:14] = '{default:0};
		map_was_here_next[13][0:14] = '{default:0};
		map_was_here_next[12][0:14] = '{default:0};
		map_was_here_next[11][0:14] = '{default:0};
		map_was_here_next[10][0:14] = '{default:0};
		map_was_here_next[9][0:14] = '{default:0};
		map_was_here_next[8][0:14] = '{default:0};
		map_was_here_next[7][0:14] = '{default:0};
		map_was_here_next[6][0:14] = '{default:0};
		map_was_here_next[5][0:14] = '{default:0};
		map_was_here_next[4][0:14] = '{default:0};
		map_was_here_next[3][0:14] = '{default:0};
		map_was_here_next[2][0:14] = '{default:0};
		map_was_here_next[1][2:14] = '{default:0};
		map_was_here_next[1][0] = 0;
		map_was_here_next[0][0:14] = '{default:0};
	end
	direction_next = direction;
//finding path
	if (now == FIND) begin
		if (!map[position_x - 1][position_y] && direction <= UP && !map_was_here[position_x - 1][position_y]) begin
			queue_bfs_x_next[counter_queue] = position_x - 1;
			queue_bfs_y_next[counter_queue] = position_y;
			counter_queue_next = counter_queue + 1;
			direction_next = LEFT;
		end else if (!map[position_x][position_y - 1] && direction <= LEFT && !map_was_here[position_x][position_y - 1]) begin
			queue_bfs_x_next[counter_queue] = position_x;
			queue_bfs_y_next[counter_queue] = position_y - 1;
			counter_queue_next = counter_queue + 1;
			direction_next = DOWN;
		end else if (!map[position_x + 1][position_y] && direction <= DOWN && !map_was_here[position_x + 1][position_y]) begin
			queue_bfs_x_next[counter_queue] = position_x + 1;
			queue_bfs_y_next[counter_queue] = position_y;
			counter_queue_next = counter_queue + 1;
			direction_next = RIGHT;
		end else if (!map[position_x][position_y + 1] && direction <= RIGHT && !map_was_here[position_x][position_y + 1]) begin
			queue_bfs_x_next[counter_queue] = position_x;
			queue_bfs_y_next[counter_queue] = position_y + 1;
			counter_queue_next = counter_queue + 1;
			direction_next = OVER;
		end else if ( counter_queue > 0 ) begin
		//	position_x_next = queue_bfs_x[counter_queue - 1];
			position_x_next = queue_bfs_x[0];
		//	position_y_next = queue_bfs_y[counter_queue - 1];
			position_y_next = queue_bfs_y[0];
			counter_queue_next = counter_queue - 1;
		  map_was_here_next[position_x][position_y] = 1;
			direction_next = UP;
			// pop queue
			queue_bfs_x_next = {queue_bfs_x[1:12], 0};
			queue_bfs_y_next = {queue_bfs_y[1:12], 0};
		end
	end
//going back
	else if(now == BACK) begin
		map_was_here_next[position_x][position_y] = 0;
		if(map_was_here[position_x - 1][position_y]) begin //UP
			position_x_next = position_x - 1;
			position_y_next = position_y;
		end else if(map_was_here[position_x][position_y - 1]) begin //LEFT
			position_x_next = position_x;
			position_y_next = position_y - 1;
		end else if(map_was_here[position_x + 1][position_y]) begin //DOWN
			position_x_next = position_x + 1;
			position_y_next = position_y;
		end else if(map_was_here[position_x][position_y + 1]) begin //RIGHT
			position_x_next = position_x;
			position_y_next = position_y + 1;
		end else begin
			position_x_next = position_x;
			position_y_next = position_y;
			direction_next = direction;
		end
	end
end
endmodule