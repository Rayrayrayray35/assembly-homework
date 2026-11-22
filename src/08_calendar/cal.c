/*==============================================================
 * CAL.C -- 输出指定年份 (1900-2099) 和月份 (1-12) 的月历
 *
 * 与 CALENDAR.ASM 使用同一套算法:
 *   - Zeller 同余式求 1 日星期
 *   - 闰年规则: 4 年一闰, 100 年不闰, 400 年再闰
 *   - 每格宽 2 字符, 格间 1 个空格
 *
 * 编译: TCC -ms CAL.C
 * 反汇编: TCC -ms -S CAL.C   (生成 CAL.ASM)
 *==============================================================*/

#include <stdio.h>

static int  mdays[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
static char *mnames[12] = {
    "January", "February", "March",     "April",
    "May",     "June",     "July",      "August",
    "September","October", "November",  "December"
};

/* 闰年返回 1, 否则返回 0 */
int is_leap(int y)
{
    if (y % 4 != 0)
        return 0;
    if (y % 100 != 0)
        return 1;
    if (y % 400 == 0)
        return 1;
    return 0;
}

/* 某月天数 */
int days_in_month(int y, int m)
{
    if (m == 2 && is_leap(y))
        return 29;
    return mdays[m - 1];
}

/* Zeller: 返回 0=Sunday ... 6=Saturday */
int first_weekday(int y, int m)
{
    int h;

    if (m < 3) {
        m += 12;
        y -= 1;
    }
    h = (1 + 13 * (m + 1) / 5 + y + y / 4 - y / 100 + y / 400) % 7;
    return (h + 6) % 7;
}

/* 输出月历 */
void print_cal(int y, int m)
{
    int wd, days, d, col;

    wd   = first_weekday(y, m);
    days = days_in_month(y, m);

    printf("%d\n", y);
    printf("%s\n", mnames[m - 1]);
    printf("Su Mo Tu We Th Fr Sa\n");

    for (d = 0; d < wd; d++)
        printf("   ");

    col = wd;
    for (d = 1; d <= days; d++) {
        printf("%2d", d);
        col++;
        if (col == 7) {
            printf("\n");
            col = 0;
        } else if (d < days) {
            printf(" ");
        }
    }
    if (col != 0)
        printf("\n");
}

int main(void)
{
    int y, m;

    for (;;) {
        printf("input year (1900-2099): ");
        if (scanf("%d", &y) != 1)
            return 1;
        if (y >= 1900 && y <= 2099)
            break;
        printf("year must be 1900-2099\n");
    }

    for (;;) {
        printf("input month (1-12): ");
        if (scanf("%d", &m) != 1)
            return 1;
        if (m >= 1 && m <= 12)
            break;
        printf("month must be 1-12\n");
    }

    print_cal(y, m);
    return 0;
}
