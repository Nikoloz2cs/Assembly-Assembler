#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest.h"
#include <fstream>
#include <string>

// compile with g++ -std=c++17 project1tests.cpp -o binary_test
// then call ./binary_test

// Function to compare two binary files
bool compareFiles(const std::string& file1, const std::string& file2) {
    std::ifstream f1(file1, std::ios::binary);
    std::ifstream f2(file2, std::ios::binary);

    if (!f1.is_open() || !f2.is_open()) {
        return false;
    }

    f1.seekg(0, std::ios::end);
    f2.seekg(0, std::ios::end);
    if (f1.tellg() != f2.tellg()) {
        return false;
    }
    f1.seekg(0, std::ios::beg);
    f2.seekg(0, std::ios::beg);

    char byte1, byte2;
    while (f1.get(byte1) && f2.get(byte2)) {
        if (byte1 != byte2) {
            return false;
        }
    }

    return true;
}

TEST_SUITE("Binary File Comparison Tests") {
    TEST_CASE("Test 1") {
        std::string test1 = "test1_inst.bin"; // our file
        std::string test1gold = "Testcases/GoldBinaries/test1inst.bin"; // gold file
    
        std::string test1s = "test1_static.bin"; // our file
        std::string test1golds = "Testcases/GoldBinaries/test1static.bin"; // gold file

        // Check if files match
        CHECK(compareFiles(test1, test1gold));
        CHECK(compareFiles(test1s, test1golds));
    }
    TEST_CASE("Test 2") {
        std::string test2 = "test2_inst.bin"; // our file
        std::string test2gold = "Testcases/GoldBinaries/test2inst.bin"; // gold file
    
        std::string test2s = "test2_static.bin"; // our file
        std::string test2golds = "Testcases/GoldBinaries/test2static.bin"; // gold file

        // Check if files match
        CHECK(compareFiles(test2, test2gold));
        CHECK(compareFiles(test2s, test2golds));
    }
    TEST_CASE("Test 3") {
        std::string test3 = "test3_inst.bin"; // our file
        std::string test3gold = "Testcases/GoldBinaries/test3inst.bin"; // gold file
    
        std::string test3s = "test3_static.bin"; // our file
        std::string test3golds = "Testcases/GoldBinaries/test3static.bin"; // gold file

        // Check if files match
        CHECK(compareFiles(test3, test3gold));
        CHECK(compareFiles(test3s, test3golds));
    }
    TEST_CASE("Test 4") {
        std::string test4 = "test4_inst.bin"; // our file
        std::string test4gold = "Testcases/GoldBinaries/test4inst.bin"; // gold file
    
        std::string test4s = "test4_static.bin"; // our file
        std::string test4golds = "Testcases/GoldBinaries/test4static.bin"; // gold file

        // Check if files match
        CHECK(compareFiles(test4, test4gold));
        CHECK(compareFiles(test4s, test4golds));
    }
    TEST_CASE("Test 5") {
        std::string test5 = "test5_inst.bin"; // our file
        std::string test5gold = "Testcases/GoldBinaries/test5inst.bin"; // gold file

        std::string test5s = "test5_static.bin"; // our file
        std::string test5golds = "Testcases/GoldBinaries/test5static.bin"; // gold file

        // Check if files match
        CHECK(compareFiles(test5, test5gold));
        CHECK(compareFiles(test5s, test5golds));
    }
    }
