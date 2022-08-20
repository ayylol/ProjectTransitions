#!/usr/bin/python

import sys
import re

def main():
    if len(sys.argv) != 3:
        print("incorrect usage")
        print("remove_comments.py [file with comments] [new file without comments]")
        return
    i = open(sys.argv[1], "r")
    o = open(sys.argv[2], "w")
    for x in i:
        x = re.sub ("//.*", "", x)
        if not x.isspace():
            o.write(x)

if __name__ == "__main__":
    main()
