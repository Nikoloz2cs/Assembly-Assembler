#ifndef __PROJECT1_CPP__
#define __PROJECT1_CPP__

#include "project1.h"
#include <vector>
#include <list>
#include <list>
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
    // Prepare output files
    std::ofstream inst_outfile, static_outfile;
    static_outfile.open(argv[argc - 2], std::ios::binary);
    inst_outfile.open(argv[argc - 1], std::ios::binary);
    std::vector<std::string> instructions;

    // Filled during p1
    std::list<std::string> static_memory_raw_lines; // { raw strings for static_memory }
    std::vector<int> static_memory; // { value in decimal }
    std::unordered_map<std::string, int> static_memory_labels; // { "label_name" : byte address for static memory labels }
    std::unordered_map<std::string, int> inst_labels; // { "label_name" : line number for instruction labels }
    std::vector<int> file_start_idx; // { iterators to the beginning of each file }

    /**
     * Phase 1:
     * Read all instructions, clean them of comments and whitespace DONE
     * TODO: Determine the numbers for all static memory labels
     * (measured in bytes starting at 0)
     * TODO: Determine the line numbers of all instruction line labels
     * (measured in instructions) starting at 0
    */

    int line_no = 0;
    int instruction_idx = 0;
    LineType line_type;
    bool skip = false; // to skip pushing within static memory parts
    
    // For each input file:
    file_start_idx.push_back(0);
    for (int i = 1; i < argc - 2; i++) {
        std::ifstream infile(argv[i]); //  open the input file for reading
        if (!infile) { // if file can't be opened, need to let the user know
            std::cerr << "Error: could not open file: " << argv[i] << std::endl;
            exit(1);
        }
        
        file_start_idx.push_back(instruction_idx);

        std::string str;
        while (getline(infile, str)){ // Read a line from the file
            str = clean(str); // remove comments, leading and trailing whitespace
            if (str == "") { // Ignore empty lines
                continue;
            }

            if (skip == true) { // skip all static memory parts
                static_memory_raw_lines.push_back(str);
                std::string dir_type = split(str, ". ")[0];
                if ((i == 1 && dir_type == "globl") || (i != 1 && dir_type == "text")) { // stop skipping
                    skip = false;
                }
                continue;
            }
            instruction_idx++;

            // std::cout << "instruction: " << str << std::endl;
            
            // process each line depending on its line type (instruction, label, directive)
            line_type = determine_line_type(str);

            if (line_type == LineType::INSTRUCTION){
                instructions.push_back(str);
                line_no += determine_line_no(split(str, " ")[0]);
                std::cout << line_no << " " << str << std::endl;
            }
            else if (line_type == LineType::LABEL) {
                inst_labels[split(str, ":")[0]] = line_no;
            }
            else { // when line_type == LineType::DIRECTIVE
                std::string dir_type = split(str, ".")[0];
                if (dir_type == "data") {
                    static_memory_raw_lines.push_back(str);
                    skip = true;
                }
            }
        }
        infile.close();
    }
    
    // store data in str_labels dictionary

    // iterators for directives
    std::list<std::string>::iterator data_dir;
    std::list<std::string>::iterator text_dir;

    int static_address = 0; // address in static memory in bytes starting at 0 (increment of 4 bytes)

    std::cout << std::endl << "All static memory lines----------" << std::endl;
    for (int i = 1; i < argc - 2; i++) {
        // for each file, find the region that has the static memory data
        data_dir = std::find(static_memory_raw_lines.begin(), static_memory_raw_lines.end(), ".data");
        text_dir = std::find(static_memory_raw_lines.begin(), static_memory_raw_lines.end(), ".text");
        
        // store data in static_memory vector
        for (auto static_iter = std::next(data_dir, 1); static_iter != text_dir; static_iter++) {
            std::cout << *static_iter << std::endl;
            std::vector<std::string> static_mem_terms = split(*static_iter, " :");
            // static_mem_terms: { label, directive (.word, .asciiz, etc), data to store, ... }
            static_memory_labels[static_mem_terms[0]] = static_address;

            if (static_mem_terms[1] == ".word") { // if the directive is ".word"
                // iterate through elements to store
                for (auto term_iter = static_mem_terms.begin() + 2; term_iter != static_mem_terms.end(); term_iter++){
                    std::string term = *term_iter;
        
                    if (isdigit(term[0])) { // if the term is numerical data, NOT label
                        static_memory.push_back(std::stoi(*term_iter));
                    }
                    else { // if the term is label
                        static_memory.push_back(4 * inst_labels[term]); // push it in bytes (e.g. Line 7 would be 28)
                    }
                    static_address += 4;
                }
            }

            else if (static_mem_terms[1] == ".asciiz") { // if the directive is ".asciiz" (null-terminating string)
                std::string static_mem_string = split(*static_iter, "\"")[1]; // this gives the first term after ", which is the string to be stored

                // iterate through characters in the string
                for (char c : static_mem_string) {
                    static_memory.push_back((int) c);
                }
                static_memory.push_back(char('\n'));
            }
        }

        // erase all lines that are already processed
        if (i == 1) {
            static_memory_raw_lines.erase(data_dir, std::next(text_dir, 2)); // erase through .data to .globl for the first instruction file
        }
        else {
            static_memory_raw_lines.erase(data_dir, std::next(text_dir, 1)); // erase through .data to .text
        }
    }


    // from here, only pure instructions are left in the vector instructions


    // print all instructions
    std::cout << "\nAll Instruction lines----------" << std::endl;
    for (std::string inst : instructions) {
        std::cout << inst << std::endl;
    }

    // print all elements in the vector
    std::cout << "\nAll Elements in static_memory----------" << std::endl;
    for (int data : static_memory) {
        std::cout << data << std::endl;
    }

    // print all elements in the dictionary static_memory_labels
    std::unordered_map<std::string, int>::iterator itr;
    std::cout << "\nAll Elements in static_memory_labels----------" << std::endl;;
    for (itr = static_memory_labels.begin(); itr != static_memory_labels.end(); itr++) {
        std::cout << itr->first << " " << itr->second << std::endl;
    }

    

    /** Phase 2
     * Process all static memory, output to static memory file
     */
    // std::cout << "first element in static_mem "  << static_memory[0] << std::endl;
    for (int static_mem_code : static_memory) {
        // std::cout << "in static the first line is: " << static_mem_code << std::endl;
        write_binary(static_mem_code, static_outfile);
    }



    /** Phase 3
     * Process all instructions, output to instruction memory file
     */

    // creates counter to keep track of line number, begins at 0
    int line_Count = 0;


    for(std::string inst : instructions) {
        std::vector<std::string> terms = split(inst, WHITESPACE+",()");
        std::string inst_type = terms[0];

        // R_type instructions
        // add 
        if (inst_type == "add") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 32);
            write_binary(result,inst_outfile);
        }
        // sub 
        else if (inst_type == "sub") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 34);
            write_binary(result, inst_outfile);
        }
        // mult
        else if (inst_type == "mult") {
            int result = encode_Rtype(0, registers[terms[1]], registers[terms[2]], 0, 0, 24);
            write_binary(result, inst_outfile);
        }
        // div
        else if (inst_type == "div") {
            int result = encode_Rtype(0, registers[terms[1]], registers[terms[2]], 0, 0, 26);
            write_binary(result, inst_outfile);
        }
        // mflo
        else if (inst_type == "mflo") {
            int result = encode_Rtype(0, 0, 0, registers[terms[1]], 0, 18);
            write_binary(result, inst_outfile);
        }
        // mfhi
        else if (inst_type == "mfhi") {
            int result = encode_Rtype(0, 0, 0, registers[terms[1]], 0, 16);
            write_binary(result, inst_outfile);
        }
        // slt
        else if (inst_type == "slt") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42);
            write_binary(result, inst_outfile);
        }
        // sll
        else if (inst_type == "sll") {
            // to find shamt, converts string of num to shift to dec
            int result = encode_Rtype(0, 0, registers[terms[2]], registers[terms[1]], std::stoi(terms[3]), 0);
            write_binary(result, inst_outfile);
        }
        // srl
        else if (inst_type == "srl") {
            // to find dec, converts string of num to shift to dec
            int result = encode_Rtype(0, 0, registers[terms[2]], registers[terms[1]], std::stoi(terms[3]), 2);
            write_binary(result, inst_outfile);
        }
        // jr
        else if (inst_type == "jr") {
            int result = encode_Rtype(0, registers[terms[1]], 0, registers[terms[2]], 0, 8);
            write_binary(result, inst_outfile);
        }
        // jalr
        else if (inst_type == "jalr") {
            // Checks if second register is provided:
            if (terms.size() > 2) {
                int result = encode_Rtype(0, registers[terms[1]], 0, registers[terms[2]], 0, 9);
                write_binary(result, inst_outfile);
            }
            // only 1 register
            else {
                int result = encode_Rtype(0, registers[terms[1]], 0, 31, 0, 9);
                write_binary(result, inst_outfile);
            }
        }
        // syscall (as specified)
        else if (inst_type == "syscall") {
            int result = encode_Rtype(0, 0, 0, 26, 0, 12);
            write_binary(result, inst_outfile);
        }

        // Other Real MIPS Instructions (STARS)
        // and
        else if (inst_type == "and") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 36);
            write_binary(result, inst_outfile);
        }
        // or
        else if (inst_type == "or") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 37);
            write_binary(result, inst_outfile);
        }
        // nor
        else if (inst_type == "nor") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 39);
            write_binary(result, inst_outfile);
        }
        // xor
        else if (inst_type == "xor") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 38);
            write_binary(result, inst_outfile);
        }

        // I_type instructions
        // addi
        else if (inst_type == "addi") {
            // to find dec to add, converts string term to dec
            int result = encode_Itype(8, registers[terms[2]], registers[terms[1]], std::stoi(terms[3]));
            write_binary(result, inst_outfile);
        }
        // lw
        else if (inst_type == "lw") {
            int result = encode_Itype(35, registers[terms[3]], registers[terms[1]], std::stoi(terms[2]));
            write_binary(result, inst_outfile);
        }
        // sw
        else if (inst_type == "sw") {
            int result = encode_Itype(43, registers[terms[3]], registers[terms[1]], std::stoi(terms[2]));
            write_binary(result, inst_outfile);
        }
        // bne
        else if (inst_type == "bne") {
            // Finds offset (label - current line number -1)
            int label_ind = inst_labels[terms[3]];
            int offset = label_ind - line_Count - 1;

            int result = encode_Itype(5, registers[terms[1]], registers[terms[2]], offset);
            write_binary(result, inst_outfile);
        }
        // beq
        else if (inst_type == "beq") {
            // Finds offset (label - current line number -1)
            int label_ind = inst_labels[terms[3]];
            int offset = label_ind - line_Count - 1;

            int result = encode_Itype(4, registers[terms[1]], registers[terms[2]], offset);
            write_binary(result, inst_outfile);
        }
        // la (as specified)
        else if (inst_type == "la") {
            // find adress of static memory label from static_memory_labels:
            int label_address = static_memory_labels[terms[2]];
            int result = encode_Itype(8, 0, registers[terms[1]], label_address);
            write_binary(result, inst_outfile);
        }
        // andi
        else if (inst_type == "andi") {
            int result = encode_Itype(12, registers[terms[2]], registers[terms[1]], std::stoi(terms[3]));
            write_binary(result, inst_outfile);
        }
        // ori
        else if (inst_type == "ori") {
            int result = encode_Itype(13, registers[terms[2]], registers[terms[1]], std::stoi(terms[3]));
            write_binary(result, inst_outfile);
        }
        // xori
        else if (inst_type == "xori") {
            int result = encode_Itype(14, registers[terms[2]], registers[terms[1]], std::stoi(terms[3]));
            write_binary(result, inst_outfile);
        }
        // lui
        else if (inst_type == "lui")
        {
            int result = encode_Itype(15, 0, registers[terms[1]], std::stoi(terms[2]));
            write_binary(result, inst_outfile);
        }

        // J_Type Instructions
        // j
        else if (inst_type == "j") {
            int label_ind = inst_labels[terms[1]];
            int result = encode_Jtype(2, label_ind);
            write_binary(result, inst_outfile);
        }
        // jal
        else if (inst_type == "jal") {
            int label_ind = inst_labels[terms[1]];
            int result = encode_Jtype(3, label_ind);
            write_binary(result, inst_outfile);
        }
        // PSEUDO INSTRUCTIONS
        // move: add
        else if (inst_type == "move") {
            int result = encode_Rtype(0, registers[terms[2]], 0, registers[terms[1]], 0, 32);
            write_binary(result,inst_outfile);
        }
        // li: addi
        else if (inst_type == "li") {
            int result = encode_Itype(8, registers["$zero"], registers[terms[1]], std::stoi(terms[3]));
            write_binary(result, inst_outfile);
        }
        // sge
        else if (inst_type == "sge") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42);
            write_binary(result, inst_outfile);

            result = encode_Itype(14, registers[terms[1]], registers[terms[1]], 0xFFFFFFFF);
            write_binary(result, inst_outfile);
        }
        // sgt (slt in disguise)
        else if (inst_type == "sgt") {
            int result = encode_Rtype(0, registers[terms[3]], registers[terms[2]], registers[terms[1]], 0, 42);
            write_binary(result, inst_outfile);
        }
        // sle
        else if (inst_type == "sle") {
            int result = encode_Rtype(0, registers[terms[3]], registers[terms[2]], registers[terms[1]], 0, 42);
            write_binary(result, inst_outfile);
        }
        // seq
        else if (inst_type == "seq") {
            int result = encode_Rtype(0, registers[terms[3]], registers[terms[2]], registers[terms[1]], 0, 42);
            write_binary(result, inst_outfile);

            result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers["$at"], 0, 42);
            write_binary(result, inst_outfile);
        }
        // sne
        else if (inst_type == "sne") {
            int result = encode_Rtype(0, registers[terms[3]], registers[terms[2]], registers[terms[1]], 0, 42);
            write_binary(result, inst_outfile);

            result = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers["$at"], 0, 42);
            write_binary(result, inst_outfile);
            
            result = encode_Rtype(0, registers[terms[1]], registers["$at"], registers[terms[1]], 0, 37);
            write_binary(result, inst_outfile);
        }

        // bge: slt -> beq 
        else if (inst_type == "bge") { 
            int result_slt = encode_Rtype(0, registers[terms[1]], registers[terms[2]], 1, 0, 42); 
            write_binary(result_slt, inst_outfile);

            int label_ind = inst_labels[terms[3]];
            int offset = label_ind - line_Count - 1;

            int result_beq = encode_Itype(4, 1, 0, offset);
            write_binary(result_beq, inst_outfile);
        }
        // bgt: slt -> bne
        else if (inst_type == "bgt") {
            int result_slt = encode_Rtype(0, registers[terms[2]], registers[terms[1]], 1, 0, 42); 
            write_binary(result_slt, inst_outfile);
            
            int label_ind = inst_labels[terms[3]];
            int offset = label_ind - line_Count - 1;

            int result_bne = encode_Itype(5, 1, 0, offset);
            write_binary(result_bne, inst_outfile);
        }
        // ble: slt -> beq 
        else if (inst_type == "ble") {
            int result_slt = encode_Rtype(0, registers[terms[2]], registers[terms[1]], 1, 0, 42); 
            write_binary(result_slt, inst_outfile);
            
            int label_ind = inst_labels[terms[3]];
            int offset = label_ind - line_Count - 1;

            int result_beq = encode_Itype(4, 1, 0, offset);
            write_binary(result_beq, inst_outfile);
        }
        // blt: slt -> bne
        else if (inst_type == "blt") {
            int result_slt = encode_Rtype(0, registers[terms[1]], registers[terms[2]], 1, 0, 42); 
            write_binary(result_slt, inst_outfile);
            
            int label_ind = inst_labels[terms[3]];
            int offset = label_ind - line_Count - 1;

            int result_bne = encode_Itype(5, 1, 0, offset);
            write_binary(result_bne, inst_outfile);
        }
        // abs
        else if  (inst_type == "abs") {
            int result = encode_Rtype(0, 0, registers[terms[2]], registers[terms[1]], 1, 0);
            write_binary(result, inst_outfile);

            result = encode_Rtype(0, 0, registers[terms[2]], registers[terms[1]], 1, 2);
            write_binary(result, inst_outfile);
        }
        // Iterates to next line (for relative addressing)
        line_Count++;
    }
}

#endif