#include <iostream>
#include <fstream>
#include <cstdlib>
#include <ctime>
#include <vector>
#include <algorithm>
#include <queue>
#include <stack>

using namespace std;
// #define SEED 89
#define MINIMUM_WALL_NUM 0
#define START_POINT_INDEX 16
#define TERMINAL_POINT_INDEX 208
#define PATTERN_NUM 100

bool check_connected(bool maze[15][15], int start, int end)
{
    int maze_dfs[15][15];
    for (int i = 0; i < 15; i++)
    {
        for (int j = 0; j < 15; j++)
        {
            maze_dfs[i][j] = maze[i][j];
        }
    }
    int start_x = start / 15;
    int start_y = start % 15;
    int end_x = end / 15;
    int end_y = end % 15;
    stack<int> dfs_stack_x;
    stack<int> dfs_stack_y;
    dfs_stack_x.push(start_x);
    dfs_stack_y.push(start_y);
    while (dfs_stack_x.size() != 0)
    {
        int x = dfs_stack_x.top();
        int y = dfs_stack_y.top();
        maze_dfs[x][y] = true;
        dfs_stack_x.pop();
        dfs_stack_y.pop();
        if (!maze_dfs[x + 1][y])
        {
            dfs_stack_x.push(x + 1);
            dfs_stack_y.push(y);
        }
        if (!maze_dfs[x][y + 1])
        {
            dfs_stack_x.push(x);
            dfs_stack_y.push(y + 1);
        }
        if (!maze_dfs[x - 1][y])
        {
            dfs_stack_x.push(x - 1);
            dfs_stack_y.push(y);
        }
        if (!maze_dfs[x][y - 1])
        {
            dfs_stack_x.push(x);
            dfs_stack_y.push(y - 1);
        }
    }
    cout << "this wall placement valid (1 : valid(place), 0 : not valid(cause unconnection, don't place)) ? " << maze_dfs[end_x][end_y] << endl;
    return maze_dfs[end_x][end_y];
}

int main()
{
    ofstream file;
    file.open("input.txt");
    srand(time(NULL));
    // srand(SEED);
    for (int i = 0; i < PATTERN_NUM; i++)
    {
        bool maze[15][15] = {false};
        for (int i = 0; i < 15; i++)
        {
            maze[0][i] = 1;
            maze[i][0] = 1;
            maze[14][i] = 1;
            maze[i][14] = 1;
        }
        int num_wall = (rand() % (145 - MINIMUM_WALL_NUM)) + MINIMUM_WALL_NUM;
        vector<int> random_array;
        int start_inside = (START_POINT_INDEX / 15 - 1) * 13 + START_POINT_INDEX % 15 - 1;
        int end_inside = (TERMINAL_POINT_INDEX / 15 - 1) * 13 + TERMINAL_POINT_INDEX % 15 - 1;
        for (int i = 0; i < 169; i++)
        {
            if (i != start_inside && i != end_inside)
            {
                random_array.push_back(i);
            }
        }
        random_shuffle(random_array.begin(), random_array.end());
        cout << "shuffle done, number of wall : " << num_wall << endl;

        while (num_wall != 0)
        {
            int x = random_array[num_wall] % 13 + 1;
            int y = random_array[num_wall] / 13 + 1;
            maze[x][y] = true;
            cout << "placing wall at maze[" << x << "\t][" << y << "\t] ";
            if (!check_connected(maze, START_POINT_INDEX, TERMINAL_POINT_INDEX))
            {
                maze[x][y] = false;
            }
            num_wall--;
        }
        for (int i = 0; i < 15; i++)
        {
            for (int j = 0; j < 15; j++)
            {
                file << maze[i][j] << endl;
                // file << maze[i][j] << " ";
                cout << maze[i][j] << " ";
            }
            // file << endl;
            cout << endl;
        }
    }
    file.close();
    return 0;
}