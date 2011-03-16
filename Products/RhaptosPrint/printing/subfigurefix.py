#!/usr/bin/env python

"""Read a LaTeX file, and for any figures that have subfigures, restrict their size so that they
will all fit on the same page.

We really should be doing this earlier, and hopefully will at a later date.
  Resize images in CNXML in subfigures (which may be oriented horizontally) where necessary.
  
  Author: J. Cameron Cooper
  (C) 2008-2009 Rice University
  
  This software is subject to the provisions of the GNU Lesser General
  Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
"""
import sys
import os
import re
from getopt import getopt
from cStringIO import StringIO
from PIL import Image

figStartExp =  re.compile(r'\\begin\s*\{\s*figure\s*\}')  # \begin{figure}   (with optional whitespace for robustness)
figEndExp =    re.compile(r'\\end\s*\{\s*figure\s*\}')    # \end{figure}
subfigureExp = re.compile(r'\\subfigure\[.*\]')           # \subfigure[]
imgMatchExp =  re.compile(r'\\includegraphics(?:\[(?P<args>.*?)\])?{(?P<url>.*?/*(?P<file>[^/]*))}\s\%\s(?P<comments>.*)')
                        # \includegraphics[width=X.XXin,height=Y.YYin]{col100XX.imgs/m10XXX_img.eps} % m10XXX,img.png,width,height
                        # findall returns (args, path, file, comments)

imgArgsWidthExp =  re.compile(r'width=\d*.\d*in')  # target args section of includegraphics
imgArgsHeightExp =  re.compile(r'height=\d*.\d*in')

# Constants: see also imagefix (TODO!)
DPI = 72.0  # a float to avoid integer math
ASSUMED_MARGIN_VERTICAL = 0.5
ASSUMED_MARGIN_HORIZONTAL = 0.5
HORIZONTAL_FORCE_NO_FLOW = 2

verbose = 1

latexQuoteMap = {}

## TODO: stolen from imagefix
def debug(*args):
    if verbose:
        for x in args:
            print >> sys.stderr, x,
    print >> sys.stderr, ""

## TODO: stolen from imagefix
def log(*args):
    #print >> sys.stderr, "IMAGEFIX: ",
    for x in args:
        print >> sys.stderr, x,
    print >> sys.stderr, ""


## TODO: stolen from imagefix
def populateLatexQuoting(specialcharspath):
    """Read from a file containing :: separated quote/unquote mapping, and put that data in a global dict."""
    f = open(specialcharspath)
    for l in f.readlines():
        if l:
            unquoted, quoted = l.split("::")
            latexQuoteMap[quoted.strip()] = unquoted.strip()
    f.close()

def extractWidthAndHeight(paramstring):
    """Given a param string like "width=2.58536585366in,height=0.853658536585in" return a tuple
    like (2.58536585366, 0.853658536585).
    Assumes we give values in inches, and breaks otherwise so that we can corrent that assumption
    if it becomes wrong.
    """
    #print "extractWidthAndHeight('%s')" % paramstring
    LEN_WIDTH = 5 + 1
    LEN_HEIGHT = 6 + 1
    LEN_UNITS = 2
    width, height = 0, 0
    if paramstring:
        for x in paramstring.split(','):
            if not x.endswith("in"): raise Exception, "Non-inch measurement in '%s'; cannot process." % paramstring
            if x.startswith('width'): width = x[LEN_WIDTH:-LEN_UNITS]
            elif x.startswith('height'): height = x[LEN_HEIGHT:-LEN_UNITS]
        retval = float(width), float(height)
    else:
        retval = None
    return retval

def resizeSubfigures(figuredata, orientation):
    """Given a list of strings being LaTeX lines defining a figure with subfigures,
    extract information about the figures and, if necessary, resize so that the
    subfigure will stack all on a page.
    Return a string (with newlines) suitable for writing directly into the output file.
    """
    orientation = orientation.strip().lower()
    debug('resizeSubfigures, orientation=', orientation)

    vertical = orientation == 'vertical'

    ## extract data from TeX
    images = []
    linenum = -1
    for line in figuredata:
        linenum += 1
        imgs = imgMatchExp.findall(line)
        if imgs:
            img = imgs[0]
            #debug(img)
            data = {}
            data['linenum'] = linenum
            data['changed'] = 0
            data['dimensions'] = extractWidthAndHeight(img[0])
            data['path'] = img[1]
            data['file'] = img[2]
            commentinfo = img[3].split(';')
            data['screenfile'] = commentinfo[1]
            #data['module'] = commentinfo[0]
            #data['screenheight'] = commentinfo[2]
            #data['screenwidth'] = commentinfo[3]
            max_wide = float(commentinfo[4])
            max_high = float(commentinfo[5])
            images.append(data)

    ## get images sizes from image inspection, if necessary
    for imgdata in images:
        if not imgdata['dimensions']:
            # we must introspect the image
            debug("-----", imgdata['path'], "has no size; introspecting")
            try:
                im = Image.open(imgdata['path'])
                x, y = im.size
                dpi = float(im.info.get('dpi', [None])[0] or DPI)
                wide = x / dpi
                high = y / dpi

                debug(im.format, "image size:", im.size)
                debug("est. real inches wide x high: %.2f x %.2f" % (wide, high))
                #headerinfo = im.info
                #if headerinfo.has_key('exif'): del headerinfo['exif']
                #debug(im.info)

                imgdata['dimensions'] = (wide, high)
            except IOError, e:
                log("Specified image load error:", e)

    ## make sure we have image data, and don't calculate with 0s, etc.
    allvalid = True
    for imgdata in images:
        debug(imgdata)
        if not imgdata['dimensions'] :
            allvalid = False
            log("broken image: %s; cannot resize subfigure" % imgdata['path'])

    ## attend to the dimension calculation and scaling
    if allvalid:
        if vertical:   # this is the easiest flow, and usually the most problematic
            image_height_sum = 0  # inches
            other_height_sum = 0
            for imgdata in images:
                image_height_sum += imgdata['dimensions'][1]
                other_height_sum += ASSUMED_MARGIN_VERTICAL
            debug("total height:", image_height_sum+other_height_sum)

            excess = image_height_sum + other_height_sum - max_high
            if excess > 0:
                scale = (image_height_sum - excess) / image_height_sum
                debug("image too big by", excess, "scaling by", scale)
                for imgdata in images:
                    x, y = imgdata['dimensions']
                    imgdata['dimensions'] = x * scale, y * scale
                    imgdata['changed'] = 1
                    debug("scaling to %.2f, %.2f" % (imgdata['dimensions'][0], imgdata['dimensions'][1]))
        else:  # horizontal
            # this is pretty tricky since it can flow;
            # one thing we can do is force low-number horizontal to the same row
            # otherwise, we give up (for now)
            # TODO: fairly repetitive; refactor somehow?
            if len(images) <= HORIZONTAL_FORCE_NO_FLOW:
                image_width_sum = 0  # inches
                other_width_sum = 0
                for imgdata in images:
                    image_width_sum += imgdata['dimensions'][0]
                    other_width_sum += ASSUMED_MARGIN_HORIZONTAL
                debug("total width:", image_width_sum+other_width_sum)

                excess = image_width_sum + other_width_sum - max_wide
                if excess > 0:
                    scale = (image_width_sum - excess) / image_width_sum
                    debug("image too big by", excess, "scaling by", scale)
                    for imgdata in images:
                        x, y = imgdata['dimensions']
                        imgdata['dimensions'] = x * scale, y * scale
                        imgdata['changed'] = 1
                        debug("scaling to %.2f, %.2f" % (imgdata['dimensions'][0], imgdata['dimensions'][1]))

    ## apply changes made to our data structure to the TeX
    for imgdata in images:
        if imgdata['changed'] and imgdata['dimensions']:
            line = figuredata[imgdata['linenum']]
            newline = imgArgsWidthExp.sub("width=%sin" % imgdata['dimensions'][0], line, count=1)
            newline = imgArgsHeightExp.sub("height=%sin" % imgdata['dimensions'][1], newline, count=1)
            #print "---", line
            #print ">>", imgdata['dimensions']
            #print "+++", newline
            figuredata[imgdata['linenum']] = newline

    return "".join(figuredata)

def main(infile, outfile, subdir):
    """Operate on LaTeX file 'infile'; resize images in subfigures to fit on same page; output to 'outfile'.
    Images live in 'subdir'.
    """
    figurecount = 0
    figureorient = None
    lines = infile.readlines()
    figbuffer = None
    for line in lines:
        ## starting a figure
        begins = figStartExp.findall(line)
        if begins:
            #debug("entering figure")
            #debug(line.rstrip())
            figurecount += 1
            figureorient = line.split('%')[1].split(',')[0]  # intentional fail if no comment for orientation
            figbuffer = StringIO()
            subfigcount = 0

        ## for each line
        if figurecount == 1:
            # inside figure; collect lines in a buffer for later analysis
            #print ".",
            figbuffer.write(line)
            subfigures = subfigureExp.findall(line)
            if subfigures:
                subfigcount += 1
                #print
                #print line
        elif figurecount == 0:
            # not in figure; just write to output
            outfile.write(line)
        else:
            # unbalanced; should not happen
            raise Exception, "imbalanced figure tags"

        ## exiting a figure
        ends = figEndExp.findall(line)
        if ends:
            #debug(" subfigures:", subfigcount)
            figbuffer.seek(0)
            figuredata = figbuffer.readlines()
            figbuffer.close()
            if subfigcount:
                print
                try:
                    figuredata = resizeSubfigures(figuredata, figureorient)
                except Exception, e:
                    figuredata = "".join(figuredata)
                    debug(str(e))   # figuredata does not change if we fail
            else:
                figuredata = "".join(figuredata)
            outfile.write(figuredata)
            #debug("exiting figure")
            #debug()
            figurecount -= 1


## command-line handler/driver

# Parse commandline args
opts, params = getopt(sys.argv[1:], 'vd:p:')


for pair in opts:
    if (pair[0] == '-v'):
        verbose = 1
    elif (pair[0] == '-d'):
        subdir = pair[1]
    elif (pair[0] == '-p'):
        printingdir = pair[1]

if len(params) > 1:
    print "Usage: imagefix [-v] [-d imagessubdir] [-p printingdir] FILE"
    sys.exit()
elif len(params) == 1:
    debug("Reading from file %s" % params[0])
    infile = open(params[0], 'r')
else:
    infile = sys.stdin
outfile = sys.stdout
#outfile = open('/tmp/tex', 'w')

# Populate dictionary of LaTeX quoting, so we can reverse it (for image names)
if not printingdir: raise Exception("Must supply path to 'printing' directory through -p")
populateLatexQuoting(os.path.join(printingdir, "latex", "latexspecialchars"))

main(infile, outfile, subdir)

# Now that we're done, close the files
infile.close()
outfile.close()
