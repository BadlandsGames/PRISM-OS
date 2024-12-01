#include <iostream>
#include <memory>
#include <atomic>
#include <chrono>
#include <stdexcept>
#include <thread>
#include <array>
#include <libxml/HTMLparser.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
using namespace std;

string exec_cmd(const char* cmd) {
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

int monitor_getWidth() {
    string result = exec_cmd("xrandr | grep '*' | awk '{print $1}'");
    string::size_type x_pos = result.find('x');
    if (x_pos != string::npos) {
        string width_str = result.substr(0, x_pos);
        return stoi(width_str);
    } else {
        throw runtime_error("Failed to parse resolution width.");
    }
}

int monitor_getHeight() {
    string result = exec_cmd("xrandr | grep '*' | awk '{print $1}'"); 
    string::size_type x_pos = result.find('x');
    if (x_pos != string::npos) {
        string height_str = result.substr(x_pos + 1);
        return stoi(height_str);
    } else {
        throw runtime_error("Failed to parse resolution height.");
    }
}