# from lxml import etree; import module2dbk; print module2dbk.xsl_transform(etree.parse('tests/simplemath/index.cnxml'), [])

import sys
import os
import Image
from StringIO import StringIO
from tempfile import mkstemp

from lxml import etree
import urllib2
import subprocess
import pkg_resources

PKG_DIR = ''

INKSCAPE_BIN = '/Applications/Inkscape.app/Contents/Resources/bin/inkscape'
if not os.path.isfile(INKSCAPE_BIN):
  INKSCAPE_BIN = 'inkscape'

SAXON_PATH = pkg_resources.resource_filename(PKG_DIR + 'lib', 'saxon9he.jar')
MATH2SVG_PATH = pkg_resources.resource_filename(PKG_DIR + 'xslt2', 'math2svg-in-docbook.xsl')

# http://lxml.de/xpathxslt.html
def makeXsl(filename):
  """ Helper that creates a XSLT stylesheet """
  path = pkg_resources.resource_filename(PKG_DIR + "xsl", filename)
  #print "Loading resource: %s" % path
  xml = etree.parse(path)#etree.XML(path)
  return etree.XSLT(xml)

CLEANUP_XSL = makeXsl('cnxml-clean.xsl')
CLEANUP2_XSL = makeXsl('cnxml-clean-math.xsl')
SIMPLIFY_MATHML_XSL = makeXsl('cnxml-clean-math-simplify.xsl')
ANNOTATE_IMAGES_XSL = makeXsl('annotate-images.xsl')
CNXML_TO_DOCBOOK_XSL = makeXsl('cnxml2dbk.xsl')
DOCBOOK_CLEANUP_XSL = makeXsl('dbk-clean.xsl')
DOCBOOK_VALIDATION_XSL = makeXsl('dbk-clean-for-validation.xsl')
SVG2PNG_FILES_XSL = makeXsl('dbk-svg2png.xsl')
DOCBOOK_BOOK_XSL = makeXsl('moduledbk2book.xsl')

NAMESPACES = {
  'mml':'http://www.w3.org/1998/Math/MathML',
  'db' :'http://docbook.org/ns/docbook',
  'svg':'http://www.w3.org/2000/svg'}

MATH_XPATH = etree.XPath('//mml:math', namespaces=NAMESPACES)
DOCBOOK_SVG_XPATH = etree.XPath('//db:imagedata[svg:svg]', namespaces=NAMESPACES)
DOCBOOK_IMAGE_XPATH = etree.XPath('//db:imagedata[@fileref]', namespaces=NAMESPACES)


def transform(xslDoc, xmlDoc):
  """ Performs an XSLT transform and parses the <xsl:message /> text """
  ret = xslDoc(xmlDoc)
  for entry in xslDoc.error_log:
    # TODO: Log the errors (and convert JSON to python) instead of just printing
    print entry
  return ret

# Use pmml2svg to convert MathML to inline SVG
def mathml2svg(xml):
  formularList = MATH_XPATH(xml)
  if len(formularList) > 0:
    
    # Take XML from stdin and output to stdout
    # -s:$DOCBOOK1 -xsl:$MATH2SVG_PATH -o:$DOCBOOK2
    strCmd = ['java','-jar', SAXON_PATH, '-s:-', '-xsl:%s' % MATH2SVG_PATH]

    # run the program with subprocess and pipe the input and output to variables
    p = subprocess.Popen(strCmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    # set STDIN and STDOUT and wait untill the program finishes
    stdOut, strErr = p.communicate(etree.tostring(xml))

    #xml = etree.fromstring(stdOut, recover=True) # @xml:id is set to '' so we need a lax parser
    parser = etree.XMLParser(recover=True)
    xml = etree.parse(StringIO(stdOut), parser)
  return xml, strErr

# From http://stackoverflow.com/questions/2932408/
def svg2png(svgStr):
  _, pngPath = mkstemp(suffix='.png')
  # Can't just use stdout because Inkscape outputs text to stdout _and_ stderr
  strCmd = [INKSCAPE_BIN, '--without-gui', '-f', '/dev/stdin', '--export-png=%s' % pngPath]
  p = subprocess.Popen(strCmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
  strOut, strError = p.communicate(svgStr)
  pngFile = open(pngPath)
  pngData = pngFile.read()
  pngFile.close()
  return pngData

# Main method. Doing all steps for the Google Docs to CNXML transformation
def convert(cnxml, filesDict):
  """ Convert a cnxml file (and dictionary of filename:bytes) to a Docbook file and dict of filename:bytes) """

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
  dbk2, err = mathml2svg(dbk1)

  # If there is an error, just use the original file
  if err and len(err) > 0:
    dbk2 = dbk1
    print err

  # TODO: parse the XML and xpath/annotate it as we go.
  for image in enumerate(DOCBOOK_IMAGE_XPATH(dbk2)):
    filename = image.get('fileref')
    # Exception thrown if image doesn't exist
    bytes = filesDict[filename]
    try:
      im = Image.open(bytes)
      image.set('_actual-width', im.size[0])
      image.set('_actual-height', im.size[1])
      print '<image name="%s" width="%d" height="%d"/>' % (f, im.size[0], im.size[1])
    except IOError:
      pass

  dbkSvg = transform(DOCBOOK_CLEANUP_XSL, dbk2)

  # Convert SVG elements to PNG files
  # (this mutates the document)
  for position, image in enumerate(DOCBOOK_SVG_XPATH(dbkSvg)):
    # TODO add the generated file to the edited files dictionary
    strImageName = "gd-%04d.png" % (position + 1)
    svg = etree.SubElement(image, "svg")
    svgStr = etree.tostring(svg)
    pngStr = svg2png(svgStr)
    newFiles[strImageName] = pngStr
    image.set('fileref', strImageName)

  # Clean up the image attributes
  dbkIncluded = transform(SVG2PNG_FILES_XSL, dbkSvg)

  # Create a standalone db:book file for the module
  dbkStandalone = transform(DOCBOOK_BOOK_XSL, dbkIncluded)

  newFiles['index.standalone.dbk'] = etree.tostring(dbkStandalone)

  return etree.tostring(dbkIncluded), newFiles
