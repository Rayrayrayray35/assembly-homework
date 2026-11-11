#include <stdio.h>

/* 递归定义: F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2)
 * 用 unsigned long (Turbo C 3.0 下 32 位) 保存结果,
 * 最大只能算到 F(47)=2971215073, n 更大时溢出.
 * 这里用朴素双递归, 目的是观察 C 编译器生成的递归栈帧. */
unsigned long fib(unsigned n)
{
    if (n < 2)
        return n;
    return fib(n - 1) + fib(n - 2);
}

int main(void)
{
    unsigned n;

    printf("n (1-40): ");
    if (scanf("%u", &n) != 1)
        return 1;
    printf("F(%u) = %lu\n", n, fib(n));
    return 0;
}
