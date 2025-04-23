// Simple c program to add two integers that you can compile to assembly language using gcc
// 
// 1. Create Assembly Language 'filename.s' extension on the command line as follows:
//      -> gcc add_integers.c -S
//
// 2. Next Create an Object File  (.o) as follows:
//      -> gcc -c add_integers.s -o add_integers.o
//
// 3. Next Create an executable file from the object file (.o) using the linker as follows
//      -> gcc add_integers.o -o add_integers
//
// 4. You can also compile and link straight to an executible using follows
//      -> gcc add_integers.c -o add_integers

#include <stdio.h>

int main() {

    int a = 69;
    int b = 31;
    int c;
    c = a + b;

    printf("a + b = ");
    printf("%d", c);

    return 0;
}