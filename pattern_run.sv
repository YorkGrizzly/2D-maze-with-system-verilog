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
input	out_valid;
input	maze_not_valid;
input	[3:0]	out_x;
input	[3:0]	out_y;
output reg clk;
output reg rst_n; 
output reg in_valid;
output reg maze;

integer invalid_count;
integer lat;
integer goldnum = 1;
integer outcount = 0;
integer gold_x = 0, gold_y = 0;
integer input_file;
integer output_file_x;
integer output_file_y;
integer f;
integer PAT_NUM = 100;
integer patcount = 0;

always	#(CYCLE/2.0) clk = ~clk;

initial begin
  clk = 0;
  in_valid = 0;
  maze = 0;

  input_file = $fopen("input.txt", "r");
  output_file_x = $fopen("out_x.txt", "r");
  output_file_y = $fopen("out_y.txt", "r");
  reset_check;
  for (patcount = 0; patcount < PAT_NUM; patcount = patcount + 1) begin
    give_input;
    f = $fscanf(output_file_x, "%d", goldnum); //scan TA file for number of outputs
    f = $fscanf(output_file_y, "%d", goldnum); //scan TA file for number of outputs
    @(negedge out_valid);
    @(negedge clk);
  end
  repeat(500)@(negedge clk);
  YOU_PASS_task;
end


always@(negedge clk) begin
  if(out_valid===1) begin
    if(goldnum===0) begin //not valid maze
      if(maze_not_valid!==1) begin
        $display("--------------------------------------------\n\n");
        $display("  The maze is not valid!   at %t, pattern number %d\n\n", $time, patcount + 1);
        $display("--------------------------------------------");
        repeat(4)@(negedge clk); $finish;
      end
    end
    else begin  //valid maze
      outcount = outcount + 1;
      f = $fscanf(output_file_x, "%d", gold_x);
      f = $fscanf(output_file_y, "%d", gold_y);
      if(out_x!==gold_x||out_y!==gold_y) begin  //wrong output
        $display("---------------------------------------------\n\n");
        $display("   correct answer x: %d, y: %d\n   your answer  out_x: %d, out_y: %d  at %t, pattern  number %d\n\n", gold_x,   gold_y, out_x, out_y, $time, patcount + 1);
        $display("---------------------------------------------");
        repeat(4)@(negedge clk); $finish;
      end
    end
  end
  else if(out_valid===0 && outcount!== 0) begin //wrong path length
    if(outcount < goldnum) begin
      $display("---------------------------------------------\n\n");
      $display("    You haven't finished giving the path!\n\n");
      $display("---------------------------------------------");
      repeat(4)@(negedge clk); $finish;
    end else if(outcount > goldnum) begin
      $display("---------------------------------------------\n\n");
      $display("    Your path is too long!\n\n");
      $display("---------------------------------------------");
      repeat(4)@(negedge clk); $finish;        
    end
    else outcount = 0;
  end  
end

always@(negedge clk) begin
  if(in_valid===1||out_valid===1) lat = 0;
  else lat = lat + 1;
  if(lat > 1000) begin
    $display("---------------------------------------------\n\n");
    $display("        Latency over 1000 cycles!            \n\n");
    $display("---------------------------------------------");
    $finish;
  end
end


task give_input; begin
  @(negedge clk);
  in_valid = 1;
  for(invalid_count = 0; invalid_count < 225; invalid_count = invalid_count + 1) begin
    f = $fscanf(input_file, "%d", maze);
    @(negedge clk);
  end
  in_valid = 0;
  maze = 0;
end endtask

task reset_check; begin
  rst_n = 1;
  #(5.0); rst_n = 0;
  #(20.0);
  if((out_valid!==0)||(maze_not_valid!==0)||(out_x!==0)||(out_y!==0)) begin
    $display("------------------------------------------------\n\n");
    $display("      reset signal!\n\n");
    $display("------------------------------------------------");
    #(1000.0); $finish;
  end
  #(10.0); rst_n = 1;
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
    $display ("                                                       latency:  %.1f ns                                      ",$time*0.1);
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");    
	$finish;	
end endtask



endmodule
