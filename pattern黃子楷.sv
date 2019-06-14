
module PATTERN(
	rst_n, 
	clk, 
	maze ,
	in_valid ,
	out_valid,
	maze_not_valid,
	out_x, 
	out_y
);

real	CYCLE = 5;
//Port Declaration
input				out_valid;
input			maze_not_valid;
input		[3:0]	out_x;
input		[3:0]	out_y;
output reg 			clk;
output reg     		rst_n; 
output reg     		in_valid;
output reg     		maze;

logic [3:0] row;	//y 
logic [3:0] col;	//x

logic random_map[0:14][0:14];
logic mark[0:14][0:14];

logic [3:0] row_list[63:0];
logic [3:0] col_list[63:0];
//logic [5:0] list_counter;
logic [5:0] mark_counter;

//================================================================
//BFS part
//================================================================

logic [6:0] golden_mark[0:14][0:14];		//number:steps
logic [3:0] queue_row[127:0];	//x position reg
logic [3:0] queue_col[127:0];	//y position reg

logic [6:0] steps;
logic [3:0] golden_x[97:0];
logic [3:0] golden_y[97:0];
logic no_ans;

//================================================================
// parameters & integer
//================================================================
integer i , j , k ;
integer total_lat;
integer this_lat;
integer patcount;
integer PATNUM = 50;
integer list_counter;
integer seed;
integer output_length;
integer q_counter;


always  #(CYCLE/2.0) clk = ~clk;

	


//================================================================
// initial
//================================================================

initial begin
	total_lat = -1;
	seed = 0;
	rst_n = 1'b1;
	in_valid = 0;
	maze = 1'bx;
	force clk = 0;
	reset_task;
	for(patcount = 0 ; patcount < PATNUM + 8; patcount = patcount + 1) begin
		if(patcount == PATNUM) begin
			ninety_seven;
		end else if(patcount == PATNUM + 1) begin
			empty;
		end else if(patcount == PATNUM + 2) begin
			full_of_wall;
		end else if(patcount == PATNUM + 3) begin
			wall_1;
		end else if(patcount == PATNUM + 4) begin
			wall_2;
		end else if(patcount == PATNUM + 5) begin
			didilong;
		end else if(patcount == PATNUM + 6) begin
			didilong2;
		end else if(patcount == PATNUM + 7) begin
			index_bomb;
		end else begin
			maze_generate;
		end
		$display("This is map NO. %d ", patcount+1);
		for (i = 0; i < 15; i++) begin
			$display("\033[33m| %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d |\033[37m",random_map[i][0],random_map[i][1],random_map[i][2],random_map[i][3],random_map[i][4],random_map[i][5],random_map[i][6],random_map[i][7],random_map[i][8],random_map[i][9],random_map[i][10],random_map[i][11],random_map[i][12],random_map[i][13],random_map[i][14]);
		end
		find_ans;

		in_valid = 1;
		for (i = 0; i < 15; i++) begin
			for (j = 0; j < 15; j++) begin
				maze = random_map[i][j];
				@(negedge clk);
			end
		end
		//@(negedge clk);
		maze = 0;
		in_valid = 0;
		wait_outvalid;
		ans_check;
        repeat(15)@(negedge clk);
    end

    repeat(10)@(negedge clk);
    YOU_PASS_task;
end

task ninety_seven ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
	for (i = 0; i < 7; i++) begin
		for (j = 1; j < 14; j++) begin
			random_map[i*2+1][j] = 0;
		end
	end
	random_map[2][13] = 0;
	random_map[4][1] = 0;
	random_map[6][13] = 0;
	random_map[8][1] = 0;
	random_map[10][13] = 0;
	random_map[12][1] = 0;
end
endtask

task empty ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
	for (i = 1; i < 14; i++) begin
		for (j = 1; j < 14; j++) begin
			random_map[i][j] = 0;
		end
	end
end
endtask

task wall_1 ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
	for (i = 1; i < 14; i++) begin
		for (j = 1; j < 14; j++) begin
			random_map[i][j] = 0;
		end
	end
	random_map[1][1] = 1;
end
endtask

task wall_2 ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
	for (i = 1; i < 14; i++) begin
		for (j = 1; j < 14; j++) begin
			random_map[i][j] = 0;
		end
	end
	random_map[13][13] = 1;
end
endtask

task wall_3 ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
	for (i = 1; i < 14; i++) begin
		for (j = 1; j < 14; j++) begin
			random_map[i][j] = 0;
		end
	end
	random_map[1][2] = 1;
	random_map[2][1] = 1;
end
endtask

task full_of_wall ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
end
endtask

task didilong ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
	random_map[1][1] = 0;
	random_map[1][2] = 0;
	random_map[1][3] = 0;
	random_map[1][4] = 0;
	random_map[1][5] = 0;
	random_map[1][6] = 0;
	random_map[1][7] = 0;
	random_map[1][8] = 0;
	random_map[1][9] = 0;
	random_map[1][10] = 0;
	random_map[1][11] = 0;
	random_map[1][12] = 0;
	random_map[1][13] = 0;
	random_map[2][13] = 0;
	random_map[3][13] = 0;
	random_map[4][13] = 0;
	random_map[5][13] = 0;
	random_map[6][13] = 0;
	random_map[7][13] = 0;
	random_map[8][13] = 0;
	random_map[9][13] = 0;
	random_map[10][13] = 0;
	random_map[11][13] = 0;
	random_map[12][13] = 0;
	random_map[13][13] = 0;
end
endtask

task didilong2 ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
	random_map[13][1] = 0;
	random_map[13][2] = 0;
	random_map[13][3] = 0;
	random_map[13][4] = 0;
	random_map[13][5] = 0;
	random_map[13][6] = 0;
	random_map[13][7] = 0;
	random_map[13][8] = 0;
	random_map[13][9] = 0;
	random_map[13][10] = 0;
	random_map[13][11] = 0;
	random_map[13][12] = 0;
	random_map[13][13] = 0;
	random_map[1][1] = 0;
	random_map[2][1] = 0;
	random_map[3][1] = 0;
	random_map[4][1] = 0;
	random_map[5][1] = 0;
	random_map[6][1] = 0;
	random_map[7][1] = 0;
	random_map[8][1] = 0;
	random_map[9][1] = 0;
	random_map[10][1] = 0;
	random_map[11][1] = 0;
	random_map[12][1] = 0;
	
end
endtask

task index_bomb ;begin
	for (i = 0; i < 15; i++) begin
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			golden_mark[i][j] = 0;
		end
	end
	for (i = 1; i < 14; i++) begin
		for (j = 1; j < 14; j++) begin
			random_map[i][j] = 0;
		end
	end
	random_map[2][2] = 1;
	random_map[2][3] = 1;
	random_map[2][4] = 1;
	random_map[2][6] = 1;
	random_map[2][5] = 1;
	random_map[3][2] = 1;
	random_map[4][2] = 1;
	random_map[5][2] = 1;
	random_map[6][2] = 1;
	random_map[6][6] = 1;
	random_map[7][7] = 1;
	random_map[8][8] = 1;
	random_map[9][9] = 1;
	random_map[11][11] = 1;
	random_map[9][3] = 1;
	random_map[9][5] = 1;
	random_map[11][5] = 1;
	random_map[3][9] = 1;
	random_map[5][9] = 1;
	random_map[5][11] = 1;

	
end
endtask

task maze_generate; begin
	for (i = 0; i < 15; i++) begin	//walls
		for (j = 0; j < 15; j++) begin
			random_map[i][j] = 1;
			mark[i][j] = 0;
			golden_mark[i][j] = 0;
		end
	end
	for (i = 0; i < 7; i++) begin
		for (j = 0; j < 7; j++) begin 
			random_map[i*2+1][j*2+1] = 0;
		end
	end
	row = 1;
	col = 1;
	row_list[0] = 1;
	col_list[0] = 3;
	row_list[1] = 3;
	col_list[1] = 1;
	list_counter = 1;
	mark[1][1] = 1;
	mark_counter = 1;
	while(1) begin
		if(mark_counter === 49) begin
			break;
		end
		seed = $urandom_range(100000,0)%list_counter;
		k = $urandom_range(seed,0);
		k = 1 + k;

		row = row_list[k];
		col = col_list[k];
		if(mark[row][col] === 0) begin
			/*$display("row = %d,col = %d",row,col);
			$display("list_counter = %d",list_counter);
			$display("--------------------------------" );
			$display("mark_counter = %d",mark_counter);
			$display("--------------------------------" );*/
			if(mark[row-2][col] === 1) begin				//up
				//$display("if 1");
				random_map[row-1][col] = 0;
				row_list[k] = row_list[list_counter];
				col_list[k] = col_list[list_counter];
				list_counter = list_counter - 1;
				if(mark[row][col-2] === 0) begin			//put blocks into list
					row_list[list_counter+1] = row;
					col_list[list_counter+1] = col - 2;
					list_counter = list_counter + 1;
				end
				if(mark[row+2][col] === 0) begin
					row_list[list_counter+1] = row + 2;
					col_list[list_counter+1] = col;
					list_counter = list_counter + 1;
				end
				if(mark[row][col+2] === 0) begin
					row_list[list_counter+1] = row;
					col_list[list_counter+1] = col + 2;
					list_counter = list_counter + 1;
				end
				mark[row][col] = 1;
			end

			else if(mark[row][col-2] === 1) begin	//left
				//$display("if 2");
				random_map[row][col-1] = 0;
				row_list[k] = row_list[list_counter];
				col_list[k] = col_list[list_counter];
				list_counter = list_counter - 1;
				if(mark[row-2][col] === 0) begin			//put blocks into list
					row_list[list_counter+1] = row - 2;
					col_list[list_counter+1] = col;
					list_counter = list_counter + 1;
				end
				if(mark[row+2][col] === 0) begin
					row_list[list_counter+1] = row + 2;
					col_list[list_counter+1] = col;
					list_counter = list_counter + 1;
				end
				if(mark[row][col+2] === 0) begin
					row_list[list_counter+1] = row;
					col_list[list_counter+1] = col + 2;
					list_counter = list_counter + 1;
				end
				mark[row][col] = 1;
			end 

			else if(mark[row+2][col] === 1) begin	//down
				//$display("if 3");

				random_map[row+1][col] = 0;
				row_list[k] = row_list[list_counter];
				col_list[k] = col_list[list_counter];
				list_counter = list_counter - 1;
				if(mark[row-2][col] === 0) begin			//put blocks into list
					row_list[list_counter+1] = row-2;
					col_list[list_counter+1] = col;
					list_counter = list_counter + 1;
				end
				if(mark[row][col-2] === 0) begin			
					row_list[list_counter+1] = row;
					col_list[list_counter+1] = col - 2;
					list_counter = list_counter + 1;
				end
				if(mark[row][col+2] === 0) begin
					row_list[list_counter+1] = row;
					col_list[list_counter+1] = col + 2;
					list_counter = list_counter + 1;
				end
				mark[row][col] = 1;
			end 

			else if(mark[row][col+2] === 1) begin	//right
				//$display("if 4");

				random_map[row][col-1] = 0;
				row_list[k] = row_list[list_counter];
				col_list[k] = col_list[list_counter];
				list_counter = list_counter - 1;
				if(mark[row-2][col] === 0) begin			//put blocks into list
					row_list[list_counter+1] = row - 2;
					col_list[list_counter+1] = col;
					list_counter = list_counter + 1;
				end
				if(mark[row][col-2] === 0) begin			
					row_list[list_counter+1] = row;
					col_list[list_counter+1] = col - 2;
					list_counter = list_counter + 1;
				end
				if(mark[row+2][col] === 0) begin
					row_list[list_counter+1] = row + 2;
					col_list[list_counter+1] = col;
					list_counter = list_counter + 1;
				end
				mark[row][col] = 1;
			end
			mark_counter = mark_counter + 1;
		end else begin
			if(mark[row][col-2] === 1) begin	//left
				//$display("case2left");
				random_map[row][col-1] = 1;
				row_list[k] = row_list[list_counter];
				col_list[k] = col_list[list_counter];
				list_counter = list_counter - 1;
			end
			else if(mark[row-2][col] === 1) begin		//up
				//$display("case2up");
				random_map[row-1][col] = 1;
				row_list[k] = row_list[list_counter];
				col_list[k] = col_list[list_counter];
				list_counter = list_counter - 1;
			end
			else if(mark[row][col+2] === 1) begin	//right
				//$display("case2right");
				random_map[row][col-1] = 1;
				row_list[k] = row_list[list_counter];
				col_list[k] = col_list[list_counter];
				list_counter = list_counter - 1;
			end
			else if(mark[row+2][col] === 1) begin	//down
				//$display("case2down");
				random_map[row+1][col] = 1;
				row_list[k] = row_list[list_counter];
				col_list[k] = col_list[list_counter];
				list_counter = list_counter - 1;
			end
		end
	end
end
endtask



task reset_task; begin
	#(0.5);rst_n = 0;
	#(2.0);
	if((out_valid !== 0)||(out_x !== 0)||(out_y !== 0)||(maze_not_valid !== 0)) begin
		$display("----------------------------" );
       	$display("            FAIL            " );
	   	$display(" out should be 0 after rst  " );
       	$display("----------------------------" );
	   	$finish ;
	end
	#(10);rst_n = 1;
	#(5);release clk;
	@(negedge clk);
end
endtask

task find_ans ; begin
	golden_mark[1][1] = 1;		//start at step = 1
	queue_row[0] = 1;
	queue_col[0] = 1;
	q_counter = 0;
	row = 1;
	col = 1;
	no_ans = 0;
	k = 1;
	golden_x[0] = 13;
	golden_y[0] = 13;
	while(1)begin
		if((row == 13)&&(col == 13))begin
			row = 13;
			col = 13;
			steps = golden_mark[13][13] - 1;
			break;
		end
		
		else begin
			/*$display("row = %d,col = %d",row,col);
			$display("q_counter = %d",q_counter);
			$display("--------------------------------" );*/
			if((random_map[row+1][col] == 0)&&(golden_mark[row+1][col] == 0))begin		//up
				golden_mark[row+1][col] = golden_mark[row][col] + 1;		//step +1
				//$display("if up" );
				queue_row[q_counter+1] = row + 1;
				queue_col[q_counter+1] = col;
				q_counter = q_counter + 1;
			end
			if((random_map[row-1][col] == 0)&&(golden_mark[row-1][col] == 0))begin		//down
				golden_mark[row-1][col] = golden_mark[row][col] + 1;		//step +1
				//$display("if down" );
				queue_row[q_counter+1] = row - 1;
				queue_col[q_counter+1] = col;
				q_counter = q_counter + 1;
			end
			if((random_map[row][col+1] == 0)&&(golden_mark[row][col+1] == 0))begin		//right
				golden_mark[row][col+1] = golden_mark[row][col] + 1;		//step +1
				//$display("if right" );
				queue_row[q_counter+1] = row;
				queue_col[q_counter+1] = col + 1;
				q_counter = q_counter + 1;
			end
			if((random_map[row][col-1] == 0)&&(golden_mark[row][col-1] == 0))begin		//left
				golden_mark[row][col-1] = golden_mark[row][col] + 1;		//step +1
				//$display("if left" );
				queue_row[q_counter+1] = row;
				queue_col[q_counter+1] = col - 1;
				q_counter = q_counter + 1;
			end
			if((q_counter == 0)||(random_map[1][1] == 1))begin
				no_ans = 1;
				$display(" This maze has NO EXIT" );
				break; 
			end
			for (i = 0; i < 128; i++) begin
				queue_row[i] = queue_row[i+1];
				queue_col[i] = queue_col[i+1];
			end
			q_counter = q_counter - 1;
			row = queue_row[0];
			col = queue_col[0];
		end
	end
	$display(" ROUTE:" );
	for (i = 0; i < 15; i++) begin
		$display("\033[33m| %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d |\033[37m",golden_mark[i][0],golden_mark[i][1],golden_mark[i][2],golden_mark[i][3],golden_mark[i][4],golden_mark[i][5],golden_mark[i][6],golden_mark[i][7],golden_mark[i][8],golden_mark[i][9],golden_mark[i][10],golden_mark[i][11],golden_mark[i][12],golden_mark[i][13],golden_mark[i][14]);
	end
	while(1)begin
		/*$display("row = %d,col = %d",row,col);
		$display("k = %d",k); 
		$display("step = %d",steps);
		$display("-----------------");*/
		if((row == 1)&&(col == 1))begin
			break;
		end
		else if(no_ans) begin
			k = 1;
			break;
		end
		else if(golden_mark[row-1][col] == steps) begin		//up
			golden_x[k] = col;
			golden_y[k] = row - 1;
			row = row - 1;
		end
		else if(golden_mark[row][col-1] == steps) begin		//left
			golden_x[k] = col - 1;
			golden_y[k] = row;
			col = col - 1;
		end
		else if(golden_mark[row+1][col] == steps) begin		//down
			golden_x[k] = col;
			golden_y[k] = row + 1;
			row = row + 1;
		end
		else if(golden_mark[row][col+1] == steps) begin		//right
			golden_x[k] = col + 1;
			golden_y[k] = row;
			col = col + 1;
		end
		k ++;
		steps --;
	end
end
endtask



task wait_outvalid ; begin
	this_lat = -1;
	while(out_valid==0)begin
		total_lat = total_lat+1;
		this_lat = this_lat + 1;
		if(this_lat == 3000) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                     The execution latency are over 3000 cycles                                             ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk);
			$finish;
		end
	@(negedge clk);
	end
end endtask

task outvalid_toolong ; begin
	while(out_valid)begin
		fail;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                           your out_valid was tooooooo long                                                 ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(10)@(negedge clk);
		$finish;
	end
end endtask


task ans_check; begin
	output_length = 0;
    while(out_valid) begin
    	if(output_length > k) begin
    		outvalid_toolong;
    	end
    	if(no_ans) begin
    		if((~maze_not_valid)||(out_x !== 0)||(out_y !== 0)) begin
    			fail;
        		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
				$display ("                                                                        FAIL!                                                               ");
				$display ("                                                                 YOUR: x = %d, x = %d                                                       ",out_x,out_y);
				$display ("                                                               GOLDEN: maze_not_valid                                                       ");			
				$display ("                                                                      time : %8t                                                            ",$time());
				$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
				repeat(2)@(negedge clk);
				$finish;
    		end
    		break;
    	end
        else if((out_x !== golden_x[output_length]) || (out_y !== golden_y[output_length]) || (maze_not_valid)) begin
            fail;
        	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                 YOUR: x = %d, x = %d                                                       ",out_x,out_y);
			$display ("                                                               GOLDEN: x = %d, y = %d                                                       ",golden_x[output_length],golden_y[output_length]);			
			$display ("                                                                      time : %8t                                                            ",$time());
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk);
			$finish;
        end
        @(negedge clk);
        output_length ++;
    end
end endtask


task fail; begin


$display("\033[33m	                                                         .:                                                                                         ");      
$display("                                                   .:                                                                                                 ");
$display("                                                  --`                                                                                                 ");
$display("                                                `--`                                                                                                  ");
$display("                 `-.                            -..        .-//-                                                                                      ");
$display("                  `.:.`                        -.-     `:+yhddddo.                                                                                    ");
$display("                    `-:-`             `       .-.`   -ohdddddddddh:                                                                                   ");
$display("                      `---`       `.://:-.    :`- `:ydddddhhsshdddh-                       \033[31m.yhhhhhhhhhs       /yyyyy`       .yhhy`   +yhyo           \033[33m");
$display("                        `--.     ./////:-::` `-.--yddddhs+//::/hdddy`                      \033[31m-MMMMNNNNNNh      -NMMMMMs       .MMMM.   sMMMh           \033[33m");
$display("                          .-..   ////:-..-// :.:oddddho:----:::+dddd+                      \033[31m-MMMM-......     `dMMmhMMM/      .MMMM.   sMMMh           \033[33m");
$display("                           `-.-` ///::::/::/:/`odddho:-------:::sdddh`                     \033[31m-MMMM.           sMMM/.NMMN.     .MMMM.   sMMMh           \033[33m");
$display("             `:/+++//:--.``  .--..+----::://o:`osss/-.--------::/dddd/             ..`     \033[31m-MMMMysssss.    /MMMh  oMMMh     .MMMM.   sMMMh           \033[33m");
$display("             oddddddddddhhhyo///.-/:-::--//+o-`:``````...------::dddds          `.-.`      \033[31m-MMMMMMMMMM-   .NMMN-``.mMMM+    .MMMM.   sMMMh           \033[33m");
$display("            .ddddhhhhhddddddddddo.//::--:///+/`.````````..``...-:ddddh       `.-.`         \033[31m-MMMM:.....`  `hMMMMmmmmNMMMN-   .MMMM.   sMMMh           \033[33m");
$display("            /dddd//::///+syhhdy+:-`-/--/////+o```````.-.......``./yddd`   `.--.`           \033[31m-MMMM.        oMMMmhhhhhhdMMMd`  .MMMM.   sMMMh```````    \033[33m");
$display("            /dddd:/------:://-.`````-/+////+o:`````..``     `.-.``./ym.`..--`              \033[31m-MMMM.       :NMMM:      .NMMMs  .MMMM.   sMMMNmmmmmms    \033[33m");
$display("            :dddd//--------.`````````.:/+++/.`````.` `.-      `-:.``.o:---`                \033[31m.dddd`       yddds        /dddh. .dddd`   +ddddddddddo    \033[33m");
$display("            .ddddo/-----..`........`````..```````..  .-o`       `:.`.--/-      ``````````` \033[31m ````        ````          ````   ````     ``````````     \033[33m");
$display("             ydddh/:---..--.````.`.-.````````````-   `yd:        `:.`...:` `................`                                                         ");
$display("             :dddds:--..:.     `.:  .-``````````.:    +ys         :-````.:...```````````````..`                                                       ");
$display("              sdddds:.`/`      ``s.  `-`````````-/.   .sy`      .:.``````-`````..-.-:-.````..`-                                                       ");
$display("              `ydddd-`.:       `sh+   /:``````````..`` +y`   `.--````````-..---..``.+::-.-``--:                                                       ");
$display("               .yddh``-.        oys`  /.``````````````.-:.`.-..`..```````/--.`      /:::-:..--`                                                       ");
$display("                .sdo``:`        .sy. .:``````````````````````````.:```...+.``       -::::-`.`                                                         ");
$display(" ````.........```.++``-:`        :y:.-``````````````....``.......-.```..::::----.```  ``                                                              ");
$display("`...````..`....----:.``...````  ``::.``````.-:/+oosssyyy:`.yyh-..`````.:` ````...-----..`                                                             ");
$display("                 `.+.``````........````.:+syhdddddddddddhoyddh.``````--              `..--.`                                                          ");
$display("            ``.....--```````.```````.../ddddddhhyyyyyyyhhhddds````.--`             ````   ``                                                          ");
$display("         `.-..``````-.`````.-.`.../ss/.oddhhyssssooooooossyyd:``.-:.         `-//::/++/:::.`                                                          ");
$display("       `..```````...-::`````.-....+hddhhhyssoo+++//////++osss.-:-.           /++++o++//s+++/                                                          ");
$display("     `-.```````-:-....-/-``````````:hddhsso++/////////////+oo+:`             +++::/o:::s+::o            \033[31m     `-/++++:-`                              \033[33m");
$display("    `:````````./`  `.----:..````````.oysso+///////////////++:::.             :++//+++/+++/+-            \033[31m   :ymMMMMMMMMms-                            \033[33m");
$display("    :.`-`..```./.`----.`  .----..`````-oo+////////////////o:-.`-.            `+++++++++++/.             \033[31m `yMMMNho++odMMMNo                           \033[33m");
$display("    ..`:..-.`.-:-::.`        `..-:::::--/+++////////////++:-.```-`            +++++++++o:               \033[31m hMMMm-      /MMMMo  .ssss`/yh+.syyyyyyyyss. \033[33m");
$display("     `.-::-:..-:-.`                 ```.+::/++//++++++++:..``````:`          -++++++++oo                \033[31m:MMMM:        yMMMN  -MMMMdMNNs-mNNNNNMMMMd` \033[33m");
$display("        `   `--`                        /``...-::///::-.`````````.: `......` ++++++++oy-                \033[31m+MMMM`        +MMMN` -MMMMh:--. ````:mMMNs`  \033[33m");
$display("           --`                          /`````````````````````````/-.``````.::-::::::/+                 \033[31m:MMMM:        yMMMm  -MMMM`       `oNMMd:    \033[33m");
$display("          .`                            :```````````````````````--.`````````..````.``/-                 \033[31m dMMMm:`    `+MMMN/  -MMMN       :dMMNs`     \033[33m");
$display("                                        :``````````````````````-.``.....````.```-::-.+                  \033[31m `yNMMMdsooymMMMm/   -MMMN     `sMMMMy/////` \033[33m");
$display("                                        :.````````````````````````-:::-::.`````-:::::+::-.`             \033[31m   -smNMMMMMNNd+`    -NNNN     hNNNNNNNNNNN- \033[33m");
$display("                                `......../```````````````````````-:/:   `--.```.://.o++++++/.           \033[31m      .:///:-`       `----     ------------` \033[33m");
$display("                              `:.``````````````````````````````.-:-`      `/````..`+sssso++++:                                                        ");
$display("                              :`````.---...`````````````````.--:-`         :-````./ysoooss++++.                                                       ");
$display("                              -.````-:/.`.--:--....````...--:/-`            /-..-+oo+++++o++++.                                                       ");
$display("             `:++/:.`          -.```.::      `.--:::::://:::::.              -:/o++++++++s++++                                                        ");
$display("           `-+++++++++////:::/-.:.```.:-.`              :::::-.-`               -+++++++o++++.                                                        ");
$display("           /++osoooo+++++++++:`````````.-::.             .::::.`-.`              `/oooo+++++.                                                         ");
$display("           ++oysssosyssssooo/.........---:::               -:::.``.....`     `.:/+++++++++:                                                           ");
$display("           -+syoooyssssssyo/::/+++++/+::::-`                 -::.``````....../++++++++++:`                                                            ");
$display("             .:///-....---.-..-.----..`                        `.--.``````````++++++/:.                                                               ");
$display("                                                                   `........-:+/:-.`                                                            \033[37m      ");


		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                  FAIL                                                                      ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

end endtask









task YOU_PASS_task;begin
  $display("                                                             \033[33m`-                                                                            ");        
  $display("                                                             /NN.                                                                           ");        
  $display("                                                            sMMM+                                                                           ");        
  $display(" .``                                                       sMMMMy                                                                           ");        
  $display(" oNNmhs+:-`                                               oMMMMMh                                                                           ");        
  $display("  /mMMMMMNNd/:-`                                         :+smMMMh                                                                           ");        
  $display("   .sNMMMMMN::://:-`                                    .o--:sNMy                                                                           ");        
  $display("     -yNMMMM:----::/:-.                                 o:----/mo                                                                           ");        
  $display("       -yNMMo--------://:.                             -+------+/                                                                           ");        
  $display("         .omd/::--------://:`                          o-------o.                                                                           ");        
  $display("           `/+o+//::-------:+:`                       .+-------y                                                                            ");        
  $display("              .:+++//::------:+/.---------.`          +:------/+                                                                            ");        
  $display("                 `-/+++/::----:/:::::::::::://:-.     o------:s.          \033[37m:::::----.           -::::.          `-:////:-`     `.:////:-.    \033[33m");        
  $display("                    `.:///+/------------------:::/:- `o-----:/o          \033[37m.NNNNNNNNNNds-       -NNNNNd`       -smNMMMMMMNy   .smNNMMMMMNh    \033[33m");        
  $display("                         :+:----------------------::/:s-----/s.          \033[37m.MMMMo++sdMMMN-     `mMMmMMMs      -NMMMh+///oys  `mMMMdo///oyy    \033[33m");        
  $display("                        :/---------------------------:++:--/++           \033[37m.MMMM.   `mMMMy     yMMM:dMMM/     +MMMM:      `  :MMMM+`     `    \033[33m");        
  $display("                       :/---///:-----------------------::-/+o`           \033[37m.MMMM.   -NMMMo    +MMMs -NMMm.    .mMMMNdo:.     `dMMMNds/-`      \033[33m");        
  $display("                      -+--/dNs-o/------------------------:+o`            \033[37m.MMMMyyyhNMMNy`   -NMMm`  sMMMh     .odNMMMMNd+`   `+dNMMMMNdo.    \033[33m");        
  $display("                     .o---yMMdsdo------------------------:s`             \033[37m.MMMMNmmmdho-    `dMMMdooosMMMM+      `./sdNMMMd.    `.:ohNMMMm-   \033[33m");        
  $display("                    -yo:--/hmmds:----------------//:------o              \033[37m.MMMM:...`       sMMMMMMMMMMMMMN-  ``     `:MMMM+ ``      -NMMMs   \033[33m");        
  $display("                   /yssy----:::-------o+-------/h/-hy:---:+              \033[37m.MMMM.          /MMMN:------hMMMd` +dy+:::/yMMMN- :my+:::/sMMMM/   \033[33m");        
  $display("                  :ysssh:------//////++/-------sMdyNMo---o.              \033[37m.MMMM.         .mMMMs       .NMMMs /NMMMMMMMMmh:  -NMMMMMMMMNh/    \033[33m");        
  $display("                  ossssh:-------ddddmmmds/:----:hmNNh:---o               \033[37m`::::`         .::::`        -:::: `-:/++++/-.     .:/++++/-.      \033[33m");        
  $display("                  /yssyo--------dhhyyhhdmmhy+:---://----+-                                                                                  ");        
  $display("                  `yss+---------hoo++oosydms----------::s    `.....-.                                                                       ");        
  $display("                   :+-----------y+++++++oho--------:+sssy.://:::://+o.                                                                      ");        
  $display("                    //----------y++++++os/--------+yssssy/:--------:/s-                                                                     ");        
  $display("             `..:::::s+//:::----+s+++ooo:--------+yssssy:-----------++                                                                      ");        
  $display("           `://::------::///+/:--+soo+:----------ssssys/---------:o+s.``                                                                    ");        
  $display("          .+:----------------/++/:---------------:sys+----------:o/////////::::-...`                                                        ");        
  $display("          o---------------------oo::----------::/+//---------::o+--------------:/ohdhyo/-.``                                                ");        
  $display("          o---------------------/s+////:----:://:---------::/+h/------------------:oNMMMMNmhs+:.`                                           ");        
  $display("          -+:::::--------------:s+-:::-----------------:://++:s--::------------::://sMMMMMMMMMMNds/`                                        ");        
  $display("           .+++/////////////+++s/:------------------:://+++- :+--////::------/ydmNNMMMMMMMMMMMMMMmo`                                        ");        
  $display("             ./+oo+++oooo++/:---------------------:///++/-   o--:///////::----sNMMMMMMMMMMMMMMMmo.                                          ");        
  $display("                o::::::--------------------------:/+++:`    .o--////////////:--+mMMMMMMMMMMMMmo`                                            ");        
  $display("               :+--------------------------------/so.       +:-:////+++++///++//+mMMMMMMMMMmo`                                              ");        
  $display("              .s----------------------------------+: ````` `s--////o:.-:/+syddmNMMMMMMMMMmo`                                                ");        
  $display("              o:----------------------------------s. :s+/////--//+o-       `-:+shmNNMMMNs.                                                  ");        
  $display("             //-----------------------------------s` .s///:---:/+o.               `-/+o.                                                    ");        
  $display("            .o------------------------------------o.  y///+//:/+o`                                                                          ");        
  $display("            o-------------------------------------:/  o+//s//+++`                                                                           ");        
  $display("           //--------------------------------------s+/o+//s`                                                                                ");        
  $display("          -+---------------------------------------:y++///s                                                                                 ");        
  $display("          o-----------------------------------------oo/+++o                                                                                 ");        
  $display("         `s-----------------------------------------:s   ``                                                                                 ");        
  $display("          o-:::::------------------:::::-------------o.                                                                                     ");        
  $display("          .+//////////::::::://///////////////:::----o`                                                                                     ");        
  $display("          `:soo+///////////+++oooooo+/////////////:-//                                                                                      ");        
  $display("       -/os/--:++/+ooo:::---..:://+ooooo++///////++so-`                                                                                     ");        
  $display("      syyooo+o++//::-                 ``-::/yoooo+/:::+s/.                                                                                  ");        
  $display("       `..``                                `-::::///:++sys:                                                                                ");        
  $display("                                                    `.:::/o+  \033[37m                                                                              ");											  
  $display ("--------------------------------------------------------------------------------------------------------------------------------------------");                                                                      
	$display ("                                                            Congratulations!                                                                ");
	$display ("                                                     You have passed all patterns!                                                          ");
    $display ("                                                       latency:  %d                                                                         ",total_lat*CYCLE);
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");    
	$finish;	
end endtask



endmodule


