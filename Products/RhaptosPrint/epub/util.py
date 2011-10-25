import os
import pkg_resources
from lxml import etree
from tempfile import mkstemp
import subprocess

INKSCAPE_BIN = '/Applications/Inkscape.app/Contents/Resources/bin/inkscape'
if not os.path.isfile(INKSCAPE_BIN):
  INKSCAPE_BIN = 'inkscape'


PKG_DIR = ''

# http://lxml.de/xpathxslt.html
def makeXsl(filename):
  """ Helper that creates a XSLT stylesheet """
  path = pkg_resources.resource_filename(PKG_DIR + "xsl", filename)
  #print "Loading resource: %s" % path
  xml = etree.parse(path)
  return etree.XSLT(xml)

COLLXML_PARAMS = makeXsl('collxml-params.xsl')
COLLXML2DOCBOOK_XSL = makeXsl('collxml2dbk.xsl')

DOCBOOK_CLEANUP_XSL = makeXsl('dbk-clean-whole.xsl')
DOCBOOK_NORMALIZE_PATHS_XSL = makeXsl('dbk2epub-normalize-paths.xsl')
DOCBOOK_NORMALIZE_GLOSSARY_XSL = makeXsl('dbk-clean-whole-remove-duplicate-glossentry.xsl')



NAMESPACES = {
  'c'  :'http://cnx.rice.edu/cnxml',
  'svg':'http://www.w3.org/2000/svg',
  'mml':'http://www.w3.org/1998/Math/MathML',
  'db' :'http://docbook.org/ns/docbook',
  'xi' :'http://www.w3.org/2001/XInclude',
  'col':'http://cnx.rice.edu/collxml'}


# For SVG Cover image
DBK2SVG_COVER_XSL = makeXsl('dbk2svg-cover.xsl')
COLLECTION_COVER_PREFIX='_collection_cover'


# From http://stackoverflow.com/questions/2932408/
def svg2png(svgStr):
  fd, pngPath = mkstemp(suffix='.png')
  # Can't just use stdout because Inkscape outputs text to stdout _and_ stderr
  strCmd = [INKSCAPE_BIN, '--without-gui', '-f', '/dev/stdin', '--export-png=%s' % pngPath]
  p = subprocess.Popen(strCmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, close_fds=True)
  strOut, strError = p.communicate(svgStr)
  pngFile = open(pngPath)
  pngData = pngFile.read()
  pngFile.close()
  os.close(fd)
  os.remove(pngPath)
  return pngData

def dbk2cover(dbk, filesDict):
  newFiles = {}
  if ('%s.png' % COLLECTION_COVER_PREFIX) in filesDict:
    return filesDict['%s.png' % COLLECTION_COVER_PREFIX], newFiles
  
  if ('%s.svg' % COLLECTION_COVER_PREFIX) in filesDict:
    svgStr = filesDict['%s.svg' % COLLECTION_COVER_PREFIX]
  else:
    svg = transform(DBK2SVG_COVER_XSL, dbk)
    svgStr = etree.tostring(svg)
  
  newFiles['cover.svg'] = svgStr
  
  png = svg2png(svgStr)
  return png, newFiles

def transform(xslDoc, xmlDoc):
  """ Performs an XSLT transform and parses the <xsl:message /> text """
  ret = xslDoc(xmlDoc)
  for entry in xslDoc.error_log:
    # TODO: Log the errors (and convert JSON to python) instead of just printing
    print entry
  return ret
