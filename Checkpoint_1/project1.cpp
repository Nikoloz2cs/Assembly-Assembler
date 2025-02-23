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
    std::vector<int> static_memory; // { value in decimal }
    std::unordered_map<std::string, int> static_memory_labels; // { "label_name" : byte address for static memory labels }
    std::unordered_map<std::string, int> inst_labels; // { "label_name" : line number for instruction labels }

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

    // store data in inst_labels dictionary

    auto dataDir = std::find(instructions.begin(), instructions.end(), ".data");
    auto textDir = std::find(instructions.begin(), instructions.end(), ".text");
    auto globlDir = std::find(instructions.begin(), instructions.end(), ".globl main");

    int lineNo = 0; // instruction line number starting at 0 (incremet of 0)
    auto instIter = globlDir + 1;
    while (instIter != instructions.end()) {
        if (isLabel(*instIter) == -1){ // if this instruction is NOT a label
            lineNo++;
            // std::cout << lineNo << " " << *instIter << std::endl;
            instIter++; // increase the index only when NOT a label
        }
        else { // if this instruction is a label
            inst_labels[split(*instIter, ":")[0]] = lineNo;
            instructions.erase(instIter);
        }
    }

    // print all elements in the dictionary 
    std::unordered_map<std::string, int>::iterator instLabelsItr;
    std::cout << "\nAll Elements in inst_labels: \n";
    for (instLabelsItr = inst_labels.begin(); instLabelsItr != inst_labels.end(); instLabelsItr++) {
      std::cout << instLabelsItr -> first << " " << instLabelsItr -> second << std::endl;
    }


    // store data in static_memory vector
    int staticAdress = 0; // address in static memory in bytes starting at 0 (increment of 4 bytes)
    // iterate through static memory lables
    for (auto staticIter = dataDir + 1; staticIter != textDir; staticIter++) {
        std::vector<std::string> staticMemTerms = split(*staticIter, " :");
        // staticMemTerms: { label, directive (.word, .asciiz, etc), data to store, ... }
        static_memory_labels[staticMemTerms[0]] = staticAdress;

        if (staticMemTerms[1] == ".word") { // if the directive is ".word"
            // iterate through elements to store
            for (auto termIter = staticMemTerms.begin() + 2; termIter != staticMemTerms.end(); termIter++){
                std::string term = *termIter;
    
                if ((term.length() == 1) and isdigit(term[0])) { // if the term is numerical data, NOT label // term[0] (as opposed to just term) is to convert basic_string<char> to char
                    static_memory.push_back(std::stoi(*termIter));
                }
                else { // if the term is label
                    static_memory.push_back(4 * inst_labels[term]); // push it in bytes (e.g. Line 7 would be 28)
                }
                staticAdress += 4;
            }
        }

        else if (staticMemTerms[1] == ".asciiz") { // if the directive is ".asciiz" (null-terminating string)
            std::string staticMemString = split(*staticIter, "\"")[1]; // this gives the first term after ", which is the string to be stored

            // iterate through characters in the string
            for (char c : staticMemString){
                static_memory.push_back((int) c);
            }
            static_memory.push_back(char('\n'));
        }
    }
    
    instructions.erase(dataDir, globlDir + 1); // erase through beginning to main
    
    // from here, only pure instructions are left in the vector instructions
    
    // print all instructions
    std::cout << std::endl;
    for (std::string inst : instructions) {
        std::cout << inst << std::endl;
    }

    // print all elements in the vector
    std::cout << "\nAll Elements in static_memory" << std::endl;
    for (int data : static_memory) {
        std::cout << data << std::endl;
    }

    // print all elements in the dictionary static_memory_labels
    std::unordered_map<std::string, int>::iterator itr;
    std::cout << "\nAll Elements in static_memory_labels: \n";
    for (itr = static_memory_labels.begin(); itr != static_memory_labels.end(); itr++) {
      std::cout << itr->first << " " << itr->second << std::endl;
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
