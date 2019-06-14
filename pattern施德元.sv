`timescale 100ps/10ps
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

//======================================
integer input_file,out_x_file,out_y_file;
integer i,j,x,y,find_end,l;
integer total_latency,input_count,out_valid_count,output_count;
integer patcount;
integer x_queue[$], y_queue[$], out_x_queue[$], out_y_queue[$];
integer maze_step[0:14][0:14];
integer maze_reg[0:14][0:14];
integer q_size;
integer PATNUM = 100;



//=======================================
//clock
always #(CYCLE/2.0) clk = ~clk;
initial clk = 0;
//=======================================
//initial
initial begin

  in_valid = 0;
  maze = 0;
  total_latency = 0;
  input_count = 0;
  output_count = 0;
  out_valid_count = 0;

  

  force clk = 0;

  reset_signal_task;
  @(negedge clk);

  for(patcount = 0; patcount < PATNUM; patcount = patcount + 1)begin
    i = $urandom_range(10,0);
    repeat(i)@(negedge clk);
//////////////////////////////////////////////// reset queue
    $display("reset_queue");
    for(i = 0; i <15; i = i + 1)begin
        for(j = 0; j < 15; j = j + 1)begin
          maze_step[i][j] = 0;
        end
      end
    q_size = x_queue.size();
    for(i = 0; i < q_size; i = i + 1)begin 
      l = x_queue.pop_back();
      l = y_queue.pop_back();
    end
    q_size = out_x_queue.size();
    for(i = 0; i < q_size; i = i + 1)begin
      l = out_x_queue.pop_back();
      l = out_y_queue.pop_back();
    end
/////////////////////////////////////////////// input
    $display("input");
    in_valid = 1;

    for(y = 0; y < 15; y = y + 1)begin
      for(x = 0; x < 15; x = x + 1)begin
        if(x == 0||y == 0||x == 14||y == 14) maze = 1;
    else begin 
      l = $urandom_range(9,0);
      if(l>7) maze = 1;
      else maze = 0;

    end
        maze_reg[x][y] = maze;
        @(negedge clk);
      end
    end
    in_valid = 0;
///////////////////////////////////////////////BFS
    $display("BFS");
    x_queue.push_back(1);
    y_queue.push_back(1);

    if(maze_reg[1][1]===1)begin
      find_end = 0;
    end else begin
      maze_step[1][1] = 1;
    
    while(1)begin
      if(x_queue[0]==13&&y_queue[0]==13)begin
        find_end = 1;
     //   $display("maze_step(13,13) = %d",maze_step[13][13]);
        break;
      end else begin
       if(maze_reg[x_queue[0]+1][y_queue[0]]===0 && maze_step[x_queue[0]+1][y_queue[0]]===0)begin
         x_queue.push_back(x_queue[0]+1);
         y_queue.push_back(y_queue[0]);
         maze_step[x_queue[0]+1][y_queue[0]] = maze_step[x_queue[0]][y_queue[0]]+1;
       end
       if(maze_reg[x_queue[0]][y_queue[0]+1]===0 && maze_step[x_queue[0]][y_queue[0]+1]===0)begin
         x_queue.push_back(x_queue[0]);
         y_queue.push_back(y_queue[0]+1);
         maze_step[x_queue[0]][y_queue[0]+1] = maze_step[x_queue[0]][y_queue[0]]+1;
       end
       if(maze_reg[x_queue[0]-1][y_queue[0]]===0 && maze_step[x_queue[0]-1][y_queue[0]]===0)begin
         x_queue.push_back(x_queue[0]-1);
         y_queue.push_back(y_queue[0]);
         maze_step[x_queue[0]-1][y_queue[0]] = maze_step[x_queue[0]][y_queue[0]]+1;
       end
       if(maze_reg[x_queue[0]][y_queue[0]-1]===0 && maze_step[x_queue[0]][y_queue[0]-1]===0)begin
         x_queue.push_back(x_queue[0]);
         y_queue.push_back(y_queue[0]-1);
         maze_step[x_queue[0]][y_queue[0]-1] = maze_step[x_queue[0]][y_queue[0]] + 1;
       end
       l = x_queue.pop_front();
       l = y_queue.pop_front();
       if(x_queue.size()==0||y_queue.size()==0)begin
        find_end = 0;
        break;
       end
      end
      
    end
  end
  $display("find_end");
    if(find_end==1)begin
      x = 13;
      y = 13;
      out_x_queue.push_back(x);
      out_y_queue.push_back(y);
      while (1) begin
        //$display("(%d,%d)",x,y);
        if(maze_step[x][y-1]==maze_step[x][y]-1)begin
          out_x_queue.push_back(x);
          out_y_queue.push_back(y-1);
          x = x;
          y = y-1;
        end else if(maze_step[x-1][y]==maze_step[x][y]-1)begin
          out_x_queue.push_back(x-1);
          out_y_queue.push_back(y);
          x = x-1;
          y = y;
        end else if(maze_step[x][y+1]==maze_step[x][y]-1)begin
          out_x_queue.push_back(x);
          out_y_queue.push_back(y+1);
          x = x;
          y = y+1;
        end else if(maze_step[x+1][y]==maze_step[x][y]-1)begin
          out_x_queue.push_back(x+1);
          out_y_queue.push_back(y);
          x = x+1;
          y = y;
        end
        if(x == 1&&y == 1)begin
          break;
        end
      end
      q_size = out_x_queue.size();
      out_x_queue.push_front(q_size);
      out_y_queue.push_front(q_size);
    end
    else begin
      out_x_queue.push_back(0);
      out_x_queue.push_back(0);
      out_y_queue.push_back(0);
      out_y_queue.push_back(0);
    end
    $display("wait");
    wait_out_valid;
    ans_check;
    $display("%d",patcount);
  end

  repeat(10)@(negedge clk);
  YOU_PASS_task;


end
//=======================================

task ans_check;begin
  output_count = out_x_queue[0];
  l = out_x_queue.pop_front();
  l = out_y_queue.pop_front();
  if(find_end)begin
  for(i = 0;i < output_count; i = i + 1) begin
    if(out_x !== out_x_queue[0]||out_y !== out_y_queue[0]||maze_not_valid!==0)begin
      fail;
      $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
  		$display ("                                                                        FAIL!                                                               ");
		  $display ("                                                     Ans(x,y): %d, %d  Your output(x,y): %d, %d  at %8t                                     " ,out_x_queue[0],out_y_queue[0],out_x,out_y,$time);
      $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
      repeat(10)@(negedge clk);
      $finish;
    end
    l = out_x_queue.pop_front();
    l = out_y_queue.pop_front();
    @(negedge clk);
  end
  end else begin
    if(out_x!==0||out_y!==0||maze_not_valid!==1)begin
      fail;
      $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
  		$display ("                                                                        FAIL!                                                               ");
		  $display ("                                                     Ans(x,y): %d, %d  Your output(x,y): %d, %d  at %8t                                     " ,0,0,out_x,out_y,$time);
      $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
      repeat(10)@(negedge clk);
      $finish;
    end
    @(negedge clk);
  end
end endtask

task wait_out_valid;begin
  out_valid_count = 0;
  while(out_valid!==1)begin
    out_valid_count = out_valid_count + 1;
    if(out_valid_count === 3001)begin
      fail;
      $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
      $display ("                                                       out_valid over 3000 cycle                                                            ");
      $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
      $finish;
    end
    @(negedge clk);
  end
end endtask

always@(negedge clk)begin
  total_latency = total_latency + 1;
end

//=======================================

task reset_signal_task;begin
  #(0.5); rst_n = 0;
  #(2.0);
  if((out_valid !== 0)||(out_x !== 0)||(out_y !== 0)||(maze_not_valid !== 0))begin
    fail;
    $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %t                                 ",$time);
    $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
 //   repeat(2) @(negedge clk);
    $finish;
  end
  #(10); rst_n = 1;
  #(3); release clk;
  end
endtask

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


//		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
//		$display ("                                                                  FAIL                                                                      ");
//		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
//	$finish;

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
    $display ("                                                       latency:  %d                                      ",total_latency*CYCLE);
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");    
	$finish;	
end endtask



endmodule


