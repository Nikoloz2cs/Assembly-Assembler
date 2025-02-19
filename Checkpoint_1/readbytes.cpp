//This program will read a file and output the binary in that file to the
//terminal, 32 bits at a time. It prints in binary, hex, and decimal
#include <string>
#include <iostream>
#include <fstream>
#include <bitset>
#include <iomanip>

int main(int argc, char* argv[]) {
  std::string filename = argv[argc-1];
  int buffer;
  std::ifstream file(filename, std::ios::in | std::ios::binary);
  while(file.read((char*) &buffer,sizeof(int))) {
    std::cout << std::bitset<32>(buffer) << " " << std::setfill('0') <<
std::setw(8) << std::hex << buffer << " " << std::dec << buffer << std::endl;
  }
  file.close();
  
}
