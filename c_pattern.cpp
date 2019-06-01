#include <iostream>
#include <fstream>
#include <cstdlib>
#include <ctime>
#include <queue>
#include <string>

using namespace std;

#define START_POINT_INDEX 16
#define TERMINAL_POINT_INDEX 208

enum
{
    NONE,
    UP,
    LEFT,
    DOWN,
    RIGHT
};

int main()
{
    ifstream in_maze_file;
    ofstream out_x_file;
    ofstream out_y_file;
    in_maze_file.open("input.txt");
    out_x_file.open("out_x.txt");
    out_y_file.open("out_y.txt");
    bool dead = false;
    bool maze[225] = {false};
    bool maze_back[225] = {false};
    int maze_back_direction[225] = {NONE};
    for (int i = 0; i < 225; i++)
    {
        in_maze_file >> maze[i];
    }
    for (int i = 0; i < 225; i++)
    {
        cout << maze[i] << " ";
        if (i % 15 == 14)
        {
            cout << endl;
        }
    }
    if (maze[START_POINT_INDEX] == true || maze[TERMINAL_POINT_INDEX] == true)
    {
        dead = true;
        cout << "maze[1][1] or maze[14][14] is a wall, start point doesn't exist" << endl;
    }
    if (dead == false)
    {
        int position = 0;
        queue<int> bfs_queue;
        bfs_queue.push(START_POINT_INDEX);
        maze[START_POINT_INDEX] = true;
        maze_back[START_POINT_INDEX] = true;
        // maze[TERMINAL_POINT_INDEX] = true;
        // maze_back[TERMINAL_POINT_INDEX] = true;
        while (1)
        {
            if (bfs_queue.size() == 0)
            {
                dead = true;
                cout << "can't find terminal point" << endl;
                break;
            }
            position = bfs_queue.front();
            bfs_queue.pop();
            cout << "now at [" << position / 15 << "][" << position % 15 << "], position at " << position << endl;
            // if (position - 15 == TERMINAL_POINT_INDEX || position - 1 == TERMINAL_POINT_INDEX || position + 15 == TERMINAL_POINT_INDEX || position + 1 == TERMINAL_POINT_INDEX)
            // {
            //     position = TERMINAL_POINT_INDEX;
            //     queue<int> empty;
            //     bfs_queue.swap(empty);
            //     break;
            // }
            if (position == TERMINAL_POINT_INDEX)
            {
                queue<int> empty;
                bfs_queue.swap(empty);
                cout << "found the terminal point!" << endl;
                break;
            }
            if (!maze[position - 15])
            {
                bfs_queue.push(position - 15);
                maze[position - 15] = true;
                maze_back[position - 15] = true;
                maze_back_direction[position - 15] = UP;
            }
            if (!maze[position - 1])
            {
                bfs_queue.push(position - 1);
                maze[position - 1] = true;
                maze_back[position - 1] = true;
                maze_back_direction[position - 1] = LEFT;
            }
            if (!maze[position + 15])
            {
                bfs_queue.push(position + 15);
                maze[position + 15] = true;
                maze_back[position + 15] = true;
                maze_back_direction[position + 15] = DOWN;
            }
            if (!maze[position + 1])
            {
                bfs_queue.push(position + 1);
                maze[position + 1] = true;
                maze_back[position + 1] = true;
                maze_back_direction[position + 1] = RIGHT;
            }
        }
        if (position == TERMINAL_POINT_INDEX)
        {
            for (int i = 0; i < 225; i++)
            {
                cout << maze_back[i] << " ";
                if (i % 15 == 14)
                {
                    cout << endl;
                }
            }
            // back
            cout << "going back" << endl;
            dead = false;
            int count = 0;
            bfs_queue.push(TERMINAL_POINT_INDEX);
            maze_back[START_POINT_INDEX] = false;
            maze_back[TERMINAL_POINT_INDEX] = false;
            while (position != START_POINT_INDEX)
            {
                switch (maze_back_direction[position])
                {
                case UP:
                    position = position + 15;
                    break;
                case LEFT:
                    position = position + 1;
                    break;
                case DOWN:
                    position = position - 15;
                    break;
                case RIGHT:
                    position = position - 1;
                    break;
                default:
                    break;
                }
                bfs_queue.push(position);
                count++;
            }
            cout << "counter : " << count << endl;
            out_x_file << count << endl;
            out_y_file << count << endl;
            cout << "path from terminal point :" << endl;
            while (!bfs_queue.empty())
            {
                position = bfs_queue.front();
                bfs_queue.pop();
                out_x_file << position % 15 << endl;
                out_y_file << position / 15 << endl;
                cout << "now at [" << position / 15 << "][" << position % 15 << "], position at " << position << endl;
            }
            // while (1)
            // {
            //     if (bfs_queue.size() == 0)
            //     {
            //         dead = true;
            //         cout << "can't go back to start point" << endl; // shouldn't happen
            //         break;
            //     }
            //     position = bfs_queue.front();
            //     bfs_queue.pop();
            //     count++;
            //     cout << "now at [" << position / 15 << "][" << position % 15 << "], position at " << position << endl;
            //     out_x_file << position % 15 << endl;
            //     out_y_file << position / 15 << endl;
            //     if (position - 15 == START_POINT_INDEX || position - 1 == START_POINT_INDEX || position + 15 == START_POINT_INDEX || position + 1 == START_POINT_INDEX)
            //     {
            //         position = START_POINT_INDEX;
            //         cout << "now at [" << position / 15 << "][" << position % 15 << "], position at " << position << endl;
            //         out_x_file << position % 15 << endl;
            //         out_y_file << position / 15 << endl;
            //         cout << "found the start point! counter : " << count << endl;
            //         break;
            //     }
            //     if (maze_back[position - 15])
            //     {
            //         bfs_queue.push(position - 15);
            //         maze_back[position - 15] = false;
            //     }
            //     if (maze_back[position - 1])
            //     {
            //         bfs_queue.push(position - 1);
            //         maze_back[position - 1] = false;
            //     }
            //     if (maze_back[position + 15])
            //     {
            //         bfs_queue.push(position + 15);
            //         maze_back[position + 15] = false;
            //     }
            //     if (maze_back[position + 1])
            //     {
            //         bfs_queue.push(position + 1);
            //         maze_back[position + 1] = false;
            //     }
            // }
        }
    }
    in_maze_file.close();
    out_x_file.close();
    out_y_file.close();
    return 0;
}