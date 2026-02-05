#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

int main(int argc, char* argv[]) {
  int n = 1;
  int* p;
  p = &n;
  int m = *p;
  printf("%p\n", p);
  printf("%p\n", &n);
  printf("%p\n", &m);
  printf("%p\n", &p);
  printf("%l\n", sizeof(n));
  return EXIT_SUCCESS;
}
