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

logic out_valid_ns;
logic maze_not_valid_ns;
logic [3:0] out_x_ns, out_y_ns ;

logic map [0:14][0:14];
logic map_ns [0:14][0:14];
//logic [224:0] map;
//logic [224:0] map_ns;

parameter IDLE = 0;
parameter IN = 1;
parameter FIND = 2;
parameter BACK = 3;
parameter DEAD = 4;

logic [2:0] now;
logic [2:0] next;

always_ff @( posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		now <= IDLE;
		map <= 0;
		out_valid <= 0;
		maze_not_valid <= 0;
		out_x <= 0;
		out_y <= 0;
	end else begin
		now <= next;
		//map <= map_ns;
		out_valid <= out_valid_ns;
		maze_not_valid <= maze_not_valid_ns;
		out_x <= out_x_ns;
		out_y <= out_y_ns;
	end
end

always_comb begin
	next = now;
	case(now)
		IDLE:;
		IN:;
 		FIND:;
 		BACK:;
 		DEAD:;
		default:
	endcase
	/*
	map_ns = map;
	if (in_valid) begin
		map_ns = {maze, map[224:1]};
	end
	*/
	out_valid_ns = ;
	maze_not_valid_ns = ;
	out_x_ns = ;
	out_y_ns = ;
end

/*
always_ff @(posedge clk or negedge rst_n) begin
	if(in_valid) begin
		map[14][0:14] <= {map[14][1:14], maze};
		map[13][0:14] <= {map[13][1:14], map[14:0]};
		map[12][0:14] <= {map[12][1:14], map[13:0]};
		map[11][0:14] <= {map[11][1:14], map[12:0]};
		map[10][0:14] <= {map[10][1:14], map[11:0]};
		map[9][0:14] <= {map[9][1:14], map[10:0]};
		map[8][0:14] <= {map[8][1:14], map[9:0]};
		map[7][0:14] <= {map[7][1:14], map[8:0]};
		map[6][0:14] <= {map[6][1:14], map[7:0]};
		map[5][0:14] <= {map[5][1:14], map[6:0]};
		map[4][0:14] <= {map[4][1:14], map[5:0]};
		map[3][0:14] <= {map[3][1:14], map[4:0]};
		map[2][0:14] <= {map[2][1:14], map[3:0]};
		map[1][0:14] <= {map[1][1:14], map[2:0]};
		map[0][0:14] <= {map[0][1:14], map[1:0]};
	end
end

*/










logic [7:0] queue_bfs[0:12];
logic [7:0] position;// current position
logic [3:0] counter;// queue index
// position <= queue
if (position == 8'd11011101) begin
	
end
	//found
end
//up left down right
if (!map[position + ?]) begin
	// position + ? => queue
end
// queue empty => dead

endmodule