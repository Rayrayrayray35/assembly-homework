#include <stdio.h>

/* 与 FIB.ASM 完全相同的算法: 递归 + 记忆化 + 十进制大数.
 * 每个数用 24 个字节保存 24 位十进制数字, memo[n][0] 是最低位.
 * F(100) = 354224848179261915075 (21 位), 24 位足够. */
#define MAXN 100
#define DIG  24

static unsigned char memo[MAXN + 1][DIG];
static unsigned char done[MAXN + 1];

static void fib(int n)
{
    int i;
    unsigned t;
    unsigned carry = 0;

    if (done[n])
        return;                        /* 记忆化: 算过就直接返回 */
    if (n < 2) {                       /* F(0)=0, F(1)=1      */
        memo[n][0] = (unsigned char)n;
        done[n] = 1;
        return;
    }

    fib(n - 1);                        /* 递归                 */
    fib(n - 2);

    for (i = 0; i < DIG; i++) {        /* 逐位相加, 满 10 进 1 */
        t = (unsigned)memo[n - 1][i] + memo[n - 2][i] + carry;
        memo[n][i] = (unsigned char)(t % 10);
        carry = t / 10;
    }
    done[n] = 1;
}

int main(void)
{
    int n, i;

    printf("n (1-100): ");
    if (scanf("%d", &n) != 1)
        return 1;
    if (n < 1 || n > MAXN) {
        printf("n must be 1..100\n");
        return 1;
    }

    fib(n);

    i = DIG - 1;                        /* 跳过前导零           */
    while (i > 0 && memo[n][i] == 0)
        i--;
    for (; i >= 0; i--)
        putchar('0' + memo[n][i]);
    putchar('\n');
    return 0;
}
