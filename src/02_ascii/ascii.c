#include <stdio.h>

/* 打印 ASCII 表中的小写字母 a..z，每行 13 个 */
int main(void)
{
    int  row, col;      /* 行、列计数 */
    char c = 'a';       /* 当前要输出的字符 */

    for (row = 0; row < 2; row++) {          /* 共 2 行 */
        for (col = 0; col < 13; col++) {     /* 每行 13 个 */
            putchar(c);                      /* 输出一个字符 */
            c++;                             /* 指向下一个字符 */
        }
        putchar('\n');                       /* 每行结束换行 */
    }
    return 0;
}
