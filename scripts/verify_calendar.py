#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Verify CAL.EXE output against Python's calendar module."""
import calendar, os, sys, re

DST = "/mnt/d/myassembly/CAL8"
NAMES = ["January","February","March","April","May","June",
         "July","August","September","October","November","December"]

def zeller_wd(y, m):
    # same algorithm as CALENDAR.ASM: 0=Sunday
    yy, mm = y, m
    if mm < 3:
        mm += 12
        yy -= 1
    h = (1 + 13*(mm+1)//5 + yy + yy//4 - yy//100 + yy//400) % 7
    return (h + 6) % 7

def expected(y, m):
    wd = zeller_wd(y, m)
    days = calendar.monthrange(y, m)[1]
    lines = [str(y), NAMES[m-1], "Su Mo Tu We Th Fr Sa"]
    line = "   " * wd
    for d in range(1, days+1):
        line += "%2d" % d
        if (wd + d) % 7 == 0:
            lines.append(line)
            line = ""
        elif d < days:
            line += " "
    if line:
        lines.append(line)
    return "\n".join(lines) + "\n"

def read_out(path):
    b = open(path, "rb").read().replace(b"\x1a", b"")
    return b.decode("cp437").replace("\r\n", "\n")

def strip_asm_prompts(text):
    # first two lines are prompts (with echoed input), rest is calendar
    lines = text.split("\n")
    # find the year line: first line that is exactly 4 digits
    for i, l in enumerate(lines):
        if re.fullmatch(r"\d{4}", l.strip()):
            return "\n".join(lines[i:])
    return text

def strip_c_prompts(text):
    # C prompts may be concatenated on one line, then the year starts after ": "
    # find last occurrence of 'input month (1-12): ' and take the rest
    idx = text.rfind("input month (1-12): ")
    if idx >= 0:
        rest = text[idx+len("input month (1-12): "):]
        # rest starts with the year
        return rest
    return text

fails = []
cases = [(2026, 11, "O2611.TXT"), (1900, 1, "O1901.TXT"),
         (1900, 2, "O1902.TXT"), (2000, 2, "O2002.TXT"),
         (2024, 2, "O2402.TXT"), (2099, 12, "O9912.TXT")]
for m in range(1, 13):
    cases.append((2026, m, "O26%02d.TXT" % m))

for y, m, fn in cases:
    p = os.path.join(DST, fn)
    if not os.path.exists(p):
        fails.append("%s missing" % fn); continue
    got = strip_asm_prompts(read_out(p)).rstrip("\n") + "\n"
    exp = expected(y, m)
    if got != exp:
        fails.append("%s (%d-%d) mismatch" % (fn, y, m))
        print("---", fn, "GOT ---"); print(got)
        print("--- EXPECTED ---"); print(exp)

# C outputs
for y, m, fn in [(2026,11,"OC2611.TXT"), (1900,1,"OC1901.TXT"),
                 (2000,2,"OC2002.TXT"), (2099,12,"OC9912.TXT")]:
    p = os.path.join(DST, fn)
    if not os.path.exists(p):
        fails.append(fn + " missing"); continue
    got = strip_c_prompts(read_out(p)).rstrip("\n") + "\n"
    exp = expected(y, m)
    if got != exp:
        fails.append(fn + " (%d-%d) mismatch" % (y, m))
        print("--- C", fn, "GOT ---"); print(got)
        print("--- C EXPECTED ---"); print(exp)

# algorithm check for every month 1900-2099
bad = 0
for y in range(1900, 2100):
    for m in range(1, 13):
        py = (calendar.monthrange(y, m)[0] + 1) % 7   # 0=Sunday
        if zeller_wd(y, m) != py:
            bad += 1
            if bad < 5:
                print("ALGO MISMATCH", y, m, zeller_wd(y, m), py)

print("cases:", len(cases), "failures:", len(fails), "algo_bad:", bad)
for f in fails:
    print("FAIL:", f)
sys.exit(1 if (fails or bad) else 0)
