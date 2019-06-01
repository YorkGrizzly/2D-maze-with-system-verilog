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
            cout << "now at [" << position / 15 << "\t][" << position % 15 << "\t], position at " << position;
            if (position == TERMINAL_POINT_INDEX)
            {
                queue<int> empty;
                while (!bfs_queue.empty())
                {
                    bfs_queue.pop();
                }
                cout << ", found the terminal point!" << endl;
                break;
            }
            if (!maze[position + 1])
            {
                bfs_queue.push(position + 1);
                maze[position + 1] = true;
                maze_back[position + 1] = true;
                maze_back_direction[position + 1] = RIGHT;
                cout << " , right ";
            }
            if (!maze[position - 15])
            {
                bfs_queue.push(position - 15);
                maze[position - 15] = true;
                maze_back[position - 15] = true;
                maze_back_direction[position - 15] = UP;
                cout << " , up ";
            }
            if (!maze[position - 1])
            {
                bfs_queue.push(position - 1);
                maze[position - 1] = true;
                maze_back[position - 1] = true;
                maze_back_direction[position - 1] = LEFT;
                cout << " , left ";
            }
            if (!maze[position + 15])
            {
                bfs_queue.push(position + 15);
                maze[position + 15] = true;
                maze_back[position + 15] = true;
                maze_back_direction[position + 15] = DOWN;
                cout << " , down ";
            }
            cout << endl;
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
            int count = 1;
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
                    cout << "unexpection happened : maze_back_direction[" << position / 15 << "][" << position % 15 << "] has no valid value!" << endl;
                    dead = true;
                    break;
                }
                bfs_queue.push(position);
                count++;
                if (count >= 169)
                {
                    cout << "unexpection happened : can't find back to start point!" << endl;
                    dead = true;
                    break;
                }
            }
            if (!dead)
            {
                cout << "counter : " << count << endl;
                out_x_file << count << endl;
                out_y_file << count << endl;
                cout << "path from terminal point to start point :" << endl;
                while (!bfs_queue.empty())
                {
                    position = bfs_queue.front();
                    bfs_queue.pop();
                    out_x_file << position % 15 << endl;
                    out_y_file << position / 15 << endl;
                    cout << "now at [" << position / 15 << "\t][" << position % 15 << "\t], position at " << position;
                    switch (maze_back_direction[position])
                    {
                    case UP:
                        cout << ", going down" << endl;
                        break;
                    case LEFT:
                        cout << ", going right" << endl;
                        break;
                    case DOWN:
                        cout << ", going up" << endl;
                        break;
                    case RIGHT:
                        cout << ", going left" << endl;
                        break;
                    case NONE:
                        cout << ", its start point, progressing success!" << endl;
                        break;
                    default:
                        cout << "unexpection happened : maze_back_direction[" << position / 15 << "][" << position % 15 << "] has no valid value!" << endl;
                        break;
                    }
                }
            }
        }
    }
    in_maze_file.close();
    out_x_file.close();
    out_y_file.close();
    return 0;
}