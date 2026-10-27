#include <stdlib.h>

int* func1(int* in) {
  *in = 1;
  return in;
}

int* func2(int* in) {
  free(in);
  in = (int*)malloc(sizeof(int));
  *in = 2;
  return in;
}

int caller(int X) {
  int* (*fp)(int*) = (X > 1) ? func1 : func2;
  int* p = (int*)malloc(sizeof(int));
  int* q = fp(p);
  return *q;
}

int main(void) {
  return 0;
}
