# from lxml import etree; import module2dbk; print module2dbk.xsl_transform(etree.parse('tests/simplemath/index.cnxml'), [])

import sys
import os
import Image
from StringIO import StringIO
import subprocess

from lxml import etree
import urllib2
import util

SAXON_PATH = util.resource_filename('lib', 'saxon9he.jar')
MATH2SVG_PATH = util.resource_filename('xslt2', 'math2svg-in-docbook.xsl')

CLEANUP_XSL = util.makeXsl('cnxml-clean.xsl')
CLEANUP2_XSL = util.makeXsl('cnxml-clean-math.xsl')
SIMPLIFY_MATHML_XSL = util.makeXsl('cnxml-clean-math-simplify.xsl')
ANNOTATE_IMAGES_XSL = util.makeXsl('annotate-images.xsl')
CNXML_TO_DOCBOOK_XSL = util.makeXsl('cnxml2dbk.xsl')
DOCBOOK_CLEANUP_XSL = util.makeXsl('dbk-clean.xsl')
SVG2PNG_FILES_XSL = util.makeXsl('dbk-svg2png.xsl')
DOCBOOK_BOOK_XSL = util.makeXsl('moduledbk2book.xsl')


MATH_XPATH = etree.XPath('//mml:math', namespaces=util.NAMESPACES)
DOCBOOK_SVG_XPATH = etree.XPath('//db:imagedata[svg:svg]', namespaces=util.NAMESPACES)
DOCBOOK_IMAGE_XPATH = etree.XPath('//db:imagedata[@fileref]', namespaces=util.NAMESPACES)

# Use pmml2svg to convert MathML to inline SVG
def mathml2svg(xml):
  formularList = MATH_XPATH(xml)
  strErr = ''
  if len(formularList) > 0:
    
    # Take XML from stdin and output to stdout
    # -s:$DOCBOOK1 -xsl:$MATH2SVG_PATH -o:$DOCBOOK2
    strCmd = ['java','-jar', SAXON_PATH, '-s:-', '-xsl:%s' % MATH2SVG_PATH]

    # run the program with subprocess and pipe the input and output to variables
    p = subprocess.Popen(strCmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, close_fds=True)
    # set STDIN and STDOUT and wait untill the program finishes
    stdOut, strErr = p.communicate(etree.tostring(xml))

    #xml = etree.fromstring(stdOut, recover=True) # @xml:id is set to '' so we need a lax parser
    parser = etree.XMLParser(recover=True)
    xml = etree.parse(StringIO(stdOut), parser)
  return xml, strErr


# Main method. Doing all steps for the Google Docs to CNXML transformation
def convert(moduleId, cnxml, filesDict, collParams, svg2png=True, math2svg=True):
  """ Convert a cnxml file (and dictionary of filename:bytes) to a Docbook file and dict of filename:bytes) """

  #print >> sys.stderr, "LOG: Working on Module %s" % moduleId
  # params are XPaths so strings need to be quoted
  params = {'cnx.module.id': "'%s'" % moduleId, 'cnx.svg.chunk': 'false'}
  params.update(collParams)

  def transform(xslDoc, xmlDoc):
    """ Performs an XSLT transform and parses the <xsl:message /> text """
    ret = xslDoc(xmlDoc, **params)
    for entry in xslDoc.error_log:
      # TODO: Log the errors (and convert JSON to python) instead of just printing
      #print entry
      pass
    return ret

  newFiles = {}
  
  cnxml2 = transform(CLEANUP_XSL, cnxml)
  cnxml3 = transform(CLEANUP2_XSL, cnxml2)
  # Have to run the cleanup twice because we remove empty mml:mo,
  # then remove mml:munder with only 1 child.
  # See m21903
  cnxml4 = transform(CLEANUP2_XSL, cnxml3)

  # Convert "simple" MathML to cnxml
  cnxml5 = transform(SIMPLIFY_MATHML_XSL, cnxml4)

  # Convert to docbook
  dbk1 = transform(CNXML_TO_DOCBOOK_XSL, cnxml5)

  # Convert MathML to SVG
  if math2svg:
    dbk2, err = mathml2svg(dbk1)
    # If there is an error, just use the original file
    if err and len(err) > 0:
      dbk2 = dbk1
      print >> sys.stderr, err
  else:
    dbk2 = dbk1

  # TODO: parse the XML and xpath/annotate it as we go.
  for image in DOCBOOK_IMAGE_XPATH(dbk2):
    filename = image.get('fileref')
    # Exception thrown if image doesn't exist
    try:
      bytes = filesDict[filename]
      im = Image.open(StringIO(bytes))
      image.set('_actual-width', str(im.size[0]))
      image.set('_actual-height', str(im.size[1]))
    except IOError:
      pass
    except KeyError:
      #print >> sys.stderr, 'LOG: Image missing %s' % filename
      pass

  dbkSvg = transform(DOCBOOK_CLEANUP_XSL, dbk2)

  # Convert SVG elements to PNG files
  # (this mutates the document)
  if svg2png:
    for position, image in enumerate(DOCBOOK_SVG_XPATH(dbkSvg)):
      print >> sys.stderr, 'LOG: Converting SVG to PNG'
      # TODO add the generated file to the edited files dictionary
      strImageName = "gd-%04d.png" % (position + 1)
      svg = etree.SubElement(image, "svg")
      svgStr = etree.tostring(svg)
      pngStr = util.svg2png(svgStr)
      newFiles[strImageName] = pngStr
      image.set('fileref', strImageName)

  # Clean up the image attributes
  dbkIncluded = transform(SVG2PNG_FILES_XSL, dbkSvg)

  # Create a standalone db:book file for the module
  dbkStandalone = transform(DOCBOOK_BOOK_XSL, dbkIncluded)

  newFiles['index.standalone.dbk'] = etree.tostring(dbkStandalone)

  return etree.tostring(dbkIncluded), newFiles
