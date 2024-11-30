#include <iostream>
#include <memory>
#include <stdexcept>
#include <array>
#include <libxml/HTMLparser.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
using namespace std;

int monitor_getWidth() {
    string result = exec("xrandr | grep '*' | awk '{print $1}'");
    string::size_type x_pos = result.find('x');
    if (x_pos != string::npos) {
        string width_str = result.substr(0, x_pos);
        return stoi(width_str);
    } else {
        throw runtime_error("Failed to parse resolution width.");
    }
}

int monitor_getHeight() {
    string result = exec("xrandr | grep '*' | awk '{print $1}'"); 
    string::size_type x_pos = result.find('x');
    if (x_pos != string::npos) {
        string height_str = result.substr(x_pos + 1);
        return stoi(height_str);
    } else {
        throw runtime_error("Failed to parse resolution height.");
    }
}

string exec(const char* cmd) {
    array<char, 128> buffer;
    string result;
    unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
    if(!pipe) {
        throw runtime_error("popen() failed!");
    }
    while(fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr)
    {
        result += buffer.data();
    }
    return result; 
}

string parseHTML(const char* filename) {
    LIBXML_TEST_VERSION
    htmlDocPtr doc = htmlReadFile(filename, NULL, HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING);
    if (doc == NULL) {
        cerr << "Failed to parse HTML\n";
        return "";
    }
    xmlNode* root_element = xmlDocGetRootElement(doc);
    string textContent = "";
    for (xmlNode* node = root_element; node; node = xmlNextNode(node)) {
        if (node->type == XML_TEXT_NODE) {
            textContent += (const char*)node->content;
        }
    }
    xmlCleanupParser();
    return textContent;
}

void renderText(const string& text, SDL_Renderer* renderer, TTF_Font* font) {
    SDL_Color color = {255, 255, 255};
    SDL_Surface* surface = TTF_RenderText_Blended_Wrapped(font, text.c_str(), color, 800);
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_Rect destRect = {50, 50, surface->w, surface->h};
    SDL_RenderCopy(renderer, texture, NULL, &destRect);
    SDL_FreeSurface(surface);
    SDL_DestroyTexture(texture);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <html file> <font file>\n";
        return 1;
    }
    const char* htmlFile = argv[1];
    string textContent = parseHTML(htmlFile);
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        cerr << "Failed to initialize SDL: " << SDL_GetError() << endl;
        return 1;
    }
    if (TTF_Init() == -1) {
        cerr << "Failed to initialize SDL_ttf: " << TTF_GetError() << endl;
        SDL_Quit();
        return 1;
    }
    SDL_Window* window = SDL_CreateWindow("SDL2 HTML Renderer", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_SHOWN);
    if (!window) {
        cerr << "Failed to create window: " << SDL_GetError() << endl;
        TTF_Quit();
        SDL_Quit();
        return 1;
    }
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        cerr << "Failed to create renderer: " << SDL_GetError() << endl;
        SDL_DestroyWindow(window);
        TTF_Quit();
        SDL_Quit();
        return 1;
    }
    TTF_Font* font = TTF_OpenFont(argv[2], 24);
    if (!font) {
        cerr << "Failed to load font: " << TTF_GetError() << endl;
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        TTF_Quit();
        SDL_Quit();
        return 1;
    }
    bool running = true;
    SDL_Event event;
    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                running = false;
            }
        }
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        renderText(textContent, renderer, font);
        SDL_RenderPresent(renderer);
    }
    TTF_CloseFont(font);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    TTF_Quit();
    SDL_Quit();
    return 0;
}