#include <iostream>
#include <fstream>
#include <cstdlib>
#include <ctime>

using namespace std;
//#define SEED 88
#define PATTERN_NUM 100

int main()
{
    ofstream file;
    file.open("input.txt");
    srand(time(NULL));
    for (int k = 0; k < PATTERN_NUM; k++)
    {
        bool maze[225] = {false};
        //srand(SEED);
        for (int i = 0; i < 15; i++)
        {
            for (int j = 0; j < 15; j++)
            {
                if (i == 0 || i == 14 || j == 0 || j == 14)
                {
                    maze[15 * i + j] = true;
                }
                else
                {
                    maze[15 * i + j] = rand() % 2;
                }
                cout << maze[15 * i + j] << " ";
                file << maze[15 * i + j] << endl;
            }
            cout << endl;
        }
    }
    file.close();
    return 0;
}