#!/usr/bin/env python
"""
  Replace characters in stdin byte-stream, using mapping from 
  first arg file.
  
  Author: Brent Hendricks
  (C) 2002-2007 Rice University
  
  This software is subject to the provisions of the GNU Lesser General
  Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
"""
import sys


def parseLine(line):
    line = line.rstrip()
    return line.split("::")

# Check for number of arguments
if len(sys.argv) != 2:
    print "Usage: replace <changesfile> "
    sys.exit(-1)


f = open(sys.argv[1])
changes = map(parseLine, f.readlines())
f.close()

input = sys.stdin.read()

for change in changes:
    input = input.replace(change[0], change[1])


sys.stdout.write(input)


    
