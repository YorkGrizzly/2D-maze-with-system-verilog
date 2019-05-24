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

logic [224:0] map;
logic [224:0] map_ns;

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
		map <= map_ns;
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
	map_ns = map;
	if (in_valid) begin
		map_ns = {maze, map[224:1]};
	end
	out_valid_ns = ;
	maze_not_valid_ns = ;
	out_x_ns = ;
	out_y_ns = ;
end

logic [7:0] queue_bfs[0:12];
logic [7:0] position;// current position
logic [3:0] counter;// queue index
// position <= queue
if (position == 8'd??) begin
	//found
end
//up left down right
if (!map[position + ?]) begin
	// position + ? => queue
end
// queue empty => dead

endmodule 
