#include <iostream>

extern"C" int add_numbers(int a, int b);

int main() {
    int result = add_numbers(5,7);
    std::cout << "The result is: " << result << std::endl;
    return 0;
}