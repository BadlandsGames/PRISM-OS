#include <iostream>
#include <vector>
#include <SDL.h>
using namespace std;

int main(int argc, char** argv) {
    SDL_Init(SDL_INIT_EVERYTHING);
    int win_width = 1920;
    int win_height = 1080;
    SDL_Window* window = SDL_CreateWindow("SDL", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, win_width, win_height, SDL_WINDOW_SHOWN);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    bool running = true;
    while(running) {}
    return 0;
}