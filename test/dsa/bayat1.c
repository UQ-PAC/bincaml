int *x, *y, **z, **p, *q;
int main(int c) {
  int a, b;
  if (c) {
    x = &a;
    z = &x;
  } else {
    y = &b;
    z = &y;
  }
  p = &q;
}
