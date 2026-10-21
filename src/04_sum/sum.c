#include <stdio.h>

/* 求 1+2+...+100, 输出结果 5050 */
int main(void)
{
    int i;
    int sum = 0;                 /* 累加和, 用 16 位 int(结果 5050 超过 255) */

    for (i = 1; i <= 100; i++)   /* i = 1,2,...,100 */
        sum += i;                /* sum = sum + i */

    printf("%d\n", sum);         /* 输出 5050 */
    return 0;
}
