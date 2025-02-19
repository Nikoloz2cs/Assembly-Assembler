#ifndef __PROJECT1_H__
#define __PROJECT1_H__

#include <math.h>
#include <string>
#include <vector>
#include <unordered_map>
#include <iostream>
#include <sstream>
#include <fstream>

/**
 * Helper Functions for String Processing
 */

const std::string WHITESPACE = " \n\r\t\f\v";
 
//Remove all whitespace from the left of the string
std::string ltrim(const std::string &s)
{
    size_t start = s.find_first_not_of(WHITESPACE);
    return (start == std::string::npos) ? "" : s.substr(start);
}
 
//Remove all whitespace from the right of the string
std::string rtrim(const std::string &s)
{
    size_t end = s.find_last_not_of(WHITESPACE);
    return (end == std::string::npos) ? "" : s.substr(0, end + 1);
}

std::vector<std::string> split(const std::string &s, const std::string &split_on) {
    std::vector<std::string> split_terms;
    int cur_pos = 0;
    while(cur_pos != std::string::npos) {
        int new_pos = s.find_first_not_of(split_on, cur_pos);
        cur_pos = s.find_first_of(split_on, new_pos);
        if(new_pos == -1 && cur_pos == -1) break;
        split_terms.push_back(s.substr(new_pos,cur_pos-new_pos));
    }
    return split_terms;
}

//Remove all comments and leading/trailing whitespace
std::string clean(const std::string &s)
{
    return rtrim(ltrim(s.substr(0,s.find('#'))));
}

/**
 * How to write raw binary to a file in C++
 */
void write_binary(int value,std::ofstream &outfile)
{
    //std::cout << std::hex << value << std::endl; //Useful for debugging
    outfile.write((char *)&value, sizeof(int));
}

/**
 * Helper methods for instruction encoding
 */


// Utility function for encoding an arithmetic "R" type function
int encode_Rtype(int opcode, int rs, int rt, int rd, int shftamt, int funccode) {
    return (opcode << 26) + (rs << 21) + (rt << 16) + (rd << 11) + (shftamt << 6) + funccode;
}
// Hint: What other instruction types need to be encoded?


/**
 * Register name map
 */
static std::unordered_map<std::string, int> registers {
  {"$zero", 0}, {"$0", 0},
  {"$at", 1}, {"$1", 1},
  {"$v0", 2}, {"$2", 2},
  {"$v1", 3}, {"$3", 3},
  {"$a0", 4}, {"$4", 4},
  {"$a1", 5}, {"$5", 5},
  {"$a2", 6}, {"$6", 6},
  {"$a3", 7}, {"$7", 7},
  {"$t0", 8}, {"$8", 8},
  {"$t1", 9}, {"$9", 9},
  {"$t2", 10}, {"$10", 10},
  {"$t3", 11}, {"$11", 11},
  {"$t4", 12}, {"$12", 12},
  {"$t5", 13}, {"$13", 13},
  {"$t6", 14}, {"$14", 14},
  {"$t7", 15}, {"$15", 15},
  {"$s0", 16}, {"$16", 16},
  {"$s1", 17}, {"$17", 17},
  {"$s2", 18}, {"$18", 18},
  {"$s3", 19}, {"$19", 19},
  {"$s4", 20}, {"$20", 20},
  {"$s5", 21}, {"$21", 21},
  {"$s6", 22}, {"$22", 22},
  {"$s7", 23}, {"$23", 23},
  {"$t8", 24}, {"$24", 24},
  {"$t9", 25}, {"$25", 25},
  {"$k0", 26}, {"$26", 26},
  {"$k1", 27}, {"$27", 27},
  {"$gp", 28}, {"$28", 28},
  {"$sp", 29}, {"$29", 29},
  {"$s8", 30}, {"$30", 30},
  {"$ra", 31}, {"$31", 31}
};


#endif
