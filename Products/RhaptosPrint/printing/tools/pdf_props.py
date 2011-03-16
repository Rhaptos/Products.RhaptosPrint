#!/usr/bin/env python

## Takes one argument: a directory to start walking, looking for 
## directories whose names match the pattern for module or collection IDs.  
## The idea is that startDir will be a directory containing module or 
## collection directories in which PDFs were built.
## Runs pdfinfo on the PDFs it finds in those directories.
## Outputs a tab-separated line:
##   objId	pdf_status	pagecount	filesize
## I load the output of this script into RDBMS tables to analyze the results 
## of PDF builds.  For AOD 1.5rc1, I loaded the results of global 
## builds with both the code in production and the new code, and used SQL to 
## create analyses of page count and file size changes, as well as changes in 
## the bare status ('good', 'bad', 'ugly').  I want to put all this in a 
## single script that takes the two directories for comparison as arguments, 
## loads the results into DB tables, and outputs a report with the comparison.
## If the '-m' option is given, the program pays attention only 
## directories and PDFs in the form of module IDs (r'm\d+'); if the 
## '-c' option is given, the program pays attention only to 
## directories and PDFs in the form of collection IDs (r''); if 
## neither or both are given, the program pays attention to both 
## module and collection IDs.

import sys
import re
import os
import os.path
import getopt

(opts, argz) = getopt.getopt(sys.argv[1:], 'mc')
opts = map(lambda opt: opt[0], opts)

if '-m' in opts and '-c' in opts or ('-m' not in opts and '-c' not in opts):
    objId_regex = re.compile(r'^(?P<objId>(col|m)\d+)$')
elif '-m' in opts:
    objId_regex = re.compile(r'^(?P<objId>m\d+)$')
elif '-c' in opts:
    objId_regex = re.compile(r'^(?P<objId>col\d+)$')


def splitFields(s):
    ret = s.split(':')
    if len(ret)>1:
        return (ret[0].strip(), ret[1].strip())
    else:
        return ret
if argz:
    startDir = argz[0]
else:
    startDir = '.'

# Walk, looking for directories matching 
# We assume that we should look for a PDF in a directory whose whole 
# name matches the form of a collection ID.
for (dpath, dnames, fnames) in os.walk(startDir):
    dpathList = os.path.split(dpath)
    m = objId_regex.match(dpathList[-1])
    # If the directory matches the pattern for collection IDs
    if m:
        objId = m.group('objId')
        pdfname = ''.join([objId, '.pdf'])
        pdfpath = os.path.join(dpath, pdfname)
        # Is there a PDF here?
        if os.path.isfile(pdfpath):
            pdfin, pdfout, pdferr = os.popen3('pdfinfo %s' % pdfpath)
            pdfout_data = pdfout.read()
            pdferr_data = pdferr.read()
            if len(pdfout_data):
                pdfdict = {}
                pdfdict.update(map(splitFields, 
                  pdfout_data.strip().split('\n')))
                print "%s\t%s\t%s\t%s" % (objId, 'good', pdfdict['Pages'], 
                  pdfdict['File size'].split(' ')[0])
            else:
                print "%s\t%s\t%s\t%s" % (objId, 'bad', 0, 0)
            pdfin.close() ; pdfout.close() ; pdferr.close()
        # If there isn't a PDF
        else:
            print "%s\t%s\t%s\t%s" % (objId, 'ugly', 0, 0)
