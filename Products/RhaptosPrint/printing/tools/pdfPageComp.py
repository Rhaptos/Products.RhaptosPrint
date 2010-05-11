#!/usr/bin/env python2.4
"""
Takes a file containing a list of object IDs as arg.
For each object ID, reads PDFs on the paths
  test/<objectId>/<objectId>.pdf
  ctrl/<objectId>/<objectId>.pdf
and compares the extractText() strings for each page, outputting the 
strings to files on the paths
  test_pages/<objectId>-<pageIdx>
  ctrl_pages/<objectId>-<pageIdx>
for examination with diff or meld.
If page counts between two PDFs of the same ID differ, or if a PDF is 
missing, error messages are written to stderr.
"""

import sys
import os
import re
from pyPdf import PdfFileReader
import pdb

CTRLPATH = 'ctrl'
TESTPATH = 'test'
CTRLPAGESPATH = 'ctrl_pages'
TESTPAGESPATH = 'test_pages'

objectIdFile = open(sys.argv[1])
for objectId in [objectId.strip() for objectId in objectIdFile.readlines()]:
    if not os.path.exists(os.path.join(CTRLPATH, objectId, "%s.pdf" % objectId)):
        sys.stderr.write("%s.pdf is missing!\n" % objectId)
        continue
    print "%s -------------------------" % objectId
    ctrlPdf = PdfFileReader(open(os.path.join(CTRLPATH, "%s" % objectId, "%s.pdf" % objectId)))
    testPdf = PdfFileReader(open(os.path.join(TESTPATH, "%s" % objectId, "%s.pdf" % objectId)))
    i = 0
    ctrlPdfPageCt = len(ctrlPdf.pages)
    testPdfPageCt = len(testPdf.pages)
    if ctrlPdfPageCt <= testPdfPageCt:
        pageCount = ctrlPdfPageCt
        if ctrlPdfPageCt < testPdfPageCt:
            sys.stderr.write("test has %d more pages than ctrl in %s\n" % (testPdfPageCt - ctrlPdfPageCt, objectId))
    elif ctrlPdfPageCt > testPdfPageCt:
        pageCount = testPdfPageCt
        sys.stderr.write("ctrl has %d more pages than test in %s\n" % (ctrlPdfPageCt - testPdfPageCt, objectId))
    while i < pageCount:
        ctrlPage = ctrlPdf.pages[i].extractText()
        testPage = testPdf.pages[i].extractText()
        if ctrlPage != testPage:
            ctrlPageFile = open(os.path.join(CTRLPAGESPATH, "%s-%02d" % (objectId, i)), 'w')
            ctrlPageFile.write(ctrlPage.encode('utf-8'))
            testPageFile = open(os.path.join(TESTPAGESPATH, "%s-%02d" % (objectId, i)), 'w')
            testPageFile.write(testPage.encode('utf-8'))
            ctrlPageFile.close()
            testPageFile.close()
        i += 1

