#include <stdio.h>

/* 输出 9×9 乘法表：外层 9..1，内层 1..i */
int main(void)
{
    int i, j;

    printf("The 9mul9 table:\n");
    for (i = 9; i >= 1; i--) {
        for (j = 1; j <= i; j++) {
            printf("%d*%d=%d", i, j, i * j);
            if (j < i) {
                putchar(' ');
            }
        }
        putchar('\n');
    }
    return 0;
}
