#ifndef __PROJECT1_CPP__
#define __PROJECT1_CPP__

#include "project1.h"
#include <vector>
#include <iterator>
#include <algorithm>
#include <string>
#include <unordered_map>
#include <iostream>
#include <sstream>
#include <fstream>

int main(int argc, char* argv[]) {
    if (argc < 4) // Checks that at least 3 arguments are given in command line
    {
        std::cerr << "Expected Usage:\n ./assemble infile1.asm infile2.asm ... infilek.asm staticmem_outfile.bin instructions_outfile.bin\n" << std::endl;
        exit(1);
    }
    //Prepare output files
    std::ofstream inst_outfile, static_outfile;
    static_outfile.open(argv[argc - 2], std::ios::binary);
    inst_outfile.open(argv[argc - 1], std::ios::binary);
    std::vector<std::string> instructions;

    // Filled during p1
    std::vector<int> static_memory; // in decimal
    std::unordered_map<std::string, int> inst_labels; // "name" : line number for instruction labels

    /**
     * Phase 1:
     * Read all instructions, clean them of comments and whitespace DONE
     * TODO: Determine the numbers for all static memory labels
     * (measured in bytes starting at 0)
     * TODO: Determine the line numbers of all instruction line labels
     * (measured in instructions) starting at 0
    */

    //For each input file:
    for (int i = 1; i < argc - 2; i++) {
        std::ifstream infile(argv[i]); //  open the input file for reading
        if (!infile) { // if file can't be opened, need to let the user know
            std::cerr << "Error: could not open file: " << argv[i] << std::endl;
            exit(1);
        }

        std::string str;
        while (getline(infile, str)){ //Read a line from the file
            str = clean(str); // remove comments, leading and trailing whitespace
            if (str == "") { //Ignore empty lines
                continue;
            }
            instructions.push_back(str); // TODO This will need to change for labels
            // std::cout << "instruction: " << str << std::endl;
        }
        infile.close();
    }

    // store data in static_memory vector
    auto dataDir = std::find(instructions.begin(), instructions.end(), ".data");
    auto textDir = std::find(instructions.begin(), instructions.end(), ".text");
    auto globlDir = std::find(instructions.begin(), instructions.end(), ".globl main");
    
    std::cout << std::endl;
    // iterate through static memory lables
    for (auto it = dataDir + 1; it != textDir - 1; it++) {
        std::vector<std::string> staticMemTerms = split(*it, " :");
        // staticMemTerms[0]: label
        // staticMemTerms[1]: directive (.word, .asciiz, etc)
        // staticMemTerms[3] ~: data to store
    }

    instructions.erase(dataDir, globlDir + 1); // erase through beginning to main
    
    std::cout << std::endl;
    // store data in inst_labels dictionary
    // reverse iterate instructions, find label, store {lable: line#} in the dictionary, and delete
    // line # can be found std::distance(instructions.begin(), inst)
    for (std::string inst : instructions) {
        if (isLabel(inst) != -1) {
            // std::cout << isLabel(inst) << inst << std::endl;
        }
    }
    
    /** Phase 2
     * Process all static memory, output to static memory file
     * TODO: All of this
     */

    /** Phase 3
     * Process all instructions, output to instruction memory file
     * TODO: Almost all of this, it only works for adds
     */
    for(std::string inst : instructions) {
        std::vector<std::string> terms = split(inst, WHITESPACE+",()");
        std::string inst_type = terms[0];
        if (inst_type == "add") {
            int result = encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 32);
            write_binary(result, inst_outfile);
        }
                if (inst_type == "add") {
            int result = encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 32);
            write_binary(result,inst_outfile);
        }
        //sub encoding
        else if (inst_type == "sub")
        {
            int result = encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 34);
            write_binary(result,inst_outfile);
        }
        //mult
        else if (inst_type == "mult")
        {
            int result = encode_Rtype(0,registers[terms[1]], registers[terms[2]], 0, 0, 24);
            write_binary(result,inst_outfile);
        }
        //div
        else if (inst_type == "div")
        {
            int result = encode_Rtype(0,registers[terms[1]], registers[terms[2]], 0, 0, 26);
            write_binary(result,inst_outfile);
        }
        //mflo
        else if (inst_type == "mflo")
        {
            int result = encode_Rtype(0,0, 0, registers[terms[1]], 0, 18);
            write_binary(result,inst_outfile);
        }
        //mfhi
        else if (inst_type == "mfhi")
        {
            int result = encode_Rtype(0,0, 0, registers[terms[1]], 0, 16);
            write_binary(result,inst_outfile);
        }
        //slt
        else if (inst_type == "slt")
        {
            int result = encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42);
            write_binary(result,inst_outfile);
        }
        //sll
    }
}

#endif
