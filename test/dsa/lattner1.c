#include <stdlib.h>

struct list {
  struct list* Next;
  int* Data;
};

struct list* createnode(int* Data) {
  struct list* New = malloc(sizeof(struct list));
  New->Data = Data;
  return New;
}

void splitclone (struct list* L, struct list** R1, struct list** R2) {
  if (L == 0) { *R1 = *R2 = 0; return; }
  if (*L->Data & 1) {
    *R1 = createnode(L->Data);
    splitclone(L->Next, &(*R1)->Next, R2);
  } else {
    *R2 = createnode(L->Data);
    splitclone(L->Next, R1, &(*R2)->Next);
  }
}

void processlist(struct list* L) {
  struct list *A, *B, *tmp;

  splitclone(L, &A, &B);
  while (A) { tmp = A->Next; free(A); A = tmp; }
  while (B) { tmp = B->Next; free(B); B = tmp; }
}

int main(void) {
  return 0;
}
