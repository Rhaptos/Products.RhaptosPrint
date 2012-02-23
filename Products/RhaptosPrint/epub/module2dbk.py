# from lxml import etree; import module2dbk; print module2dbk.xsl_transform(etree.parse('tests/simplemath/index.cnxml'), [])

import sys
import os
import Image
from StringIO import StringIO
import subprocess

from lxml import etree
import urllib2
import util

#try:
#    import json
#except ImportError:
#    import simplejson as json

DEBUG = 'DEBUG' in os.environ

SAXON_PATH = util.resource_filename('lib', 'saxon9he.jar')
MATH2SVG_PATH = util.resource_filename('xslt2', 'math2svg-in-docbook.xsl')

DOCBOOK_BOOK_XSL = util.makeXsl('moduledbk2book.xsl')

MATH_XPATH = etree.XPath('//mml:math', namespaces=util.NAMESPACES)
DOCBOOK_SVG_XPATH = etree.XPath('//db:imagedata[svg:svg]', namespaces=util.NAMESPACES)
DOCBOOK_IMAGE_XPATH = etree.XPath('//db:imagedata[@fileref]', namespaces=util.NAMESPACES)

# -----------------------------
# Transform Structure:
#
# Every transform takes in 3 arguments:
# - xml doc
# - dictionary of files (string name, string bytes)
# - optional dictionary of parameters (string, string)
#
# Every transform returns:
# - xml doc
# - dictionary of new files
# - A list of log messages
#

def extractLog(entries):
  """ Takes in an etree.xsl.error_log and returns a list of dicts (JSON) """
  log = []
  for entry in entries:
    # Entries are of the form:
    # {'level':'ERROR','id':'id1234','msg':'Descriptive message'}
    text = entry.message
    if DEBUG and text:
      print >> sys.stderr, text.encode('utf-8')
    #try:
    #    dict = json.loads(text)
    #    errors.append(dict)
    #except ValueError:
    log.append({
      u'level':u'CRITICAL',
      u'id'   :u'(none)',
      u'msg'  :unicode(text) })

def makeTransform(file):
  xsl = util.makeXsl(file)
  def t(xml, files, **params):
    xml = xsl(xml, **params)
    errors = extractLog(xsl.error_log)
    return xml, {}, errors
  return t    

# Main method. Doing all steps for the Google Docs to CNXML transformation
def convert(moduleId, xml, filesDict, collParams, svg2png=True, math2svg=True):
  """ Convert a cnxml file (and dictionary of filename:bytes) to a Docbook file and dict of filename:bytes) """

  #if 'index.included.dbk' in filesDict:
  #  print >> sys.stderr, "LOG: Using already converted dbk file!"
  #  return (filesDict['index.included.dbk'], {})
  #print >> sys.stderr, "LOG: Working on Module %s" % moduleId
  # params are XPaths so strings need to be quoted
  params = {'cnx.module.id': "'%s'" % moduleId, 'cnx.svg.chunk': 'false'}
  params.update(collParams)

  # Use pmml2svg to convert MathML to inline SVG
  def mathml2svg(xml, files, **params):
    if math2svg:
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
  
        if DEBUG and strErr:
          print >> sys.stderr, strErr.encode('utf-8')
    return xml, {}, [] # xml, newFiles, log messages

  newFiles = {}
  
  def imageAnnotate(xml, **params):
    # TODO: parse the XML and xpath/annotate it as we go.
    for image in DOCBOOK_IMAGE_XPATH(xml):
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
    return xml, {}, [] # xml, newFiles, log messages

  # Convert SVG elements to PNG files
  # (this mutates the document)
  def svg2pngTransform(xml, files, **params):
    newFiles2 = {}
    if svg2png:
      for position, image in enumerate(DOCBOOK_SVG_XPATH(xml)):
        print >> sys.stderr, 'LOG: Converting SVG to PNG'
        # TODO add the generated file to the edited files dictionary
        strImageName = "gd-%04d.png" % (position + 1)
        svg = etree.SubElement(image, "svg")
        svgStr = etree.tostring(svg)
        pngStr = util.svg2png(svgStr)
        newFiles2[strImageName] = pngStr
        image.set('fileref', strImageName)
    return xml, newFiles2, [] # xml, newFiles, log messages

  PIPELINE = [
    makeTransform('cnxml-clean.xsl'),
    makeTransform('cnxml-clean-math.xsl'),
    # Have to run the cleanup twice because we remove empty mml:mo,
    # then remove mml:munder with only 1 child.
    # See m21903
    makeTransform('cnxml-clean-math.xsl'),
    makeTransform('cnxml-clean-math-simplify.xsl'),   # Convert "simple" MathML to cnxml
    makeTransform('cnxml2dbk.xsl'),   # Convert to docbook
    mathml2svg,
    # imageAnnotate, # This is no longer used
    makeTransform('dbk-clean.xsl'),
    svg2pngTransform,
    makeTransform('dbk-svg2png.xsl'), # Clean up the image attributes
#    dbk2xhtml,
  ]

  passNum = 1
  for transform in PIPELINE:
    if DEBUG:
      print >> sys.stderr, "LOG: Starting pass %d" % passNum
      # open('temp-%s-%d.xml' % (moduleId, passNum),'w').write(etree.tostring(xml))
      passNum += 1
    xml, newFiles2, errors = transform(xml, filesDict, **params)
    newFiles.update(newFiles2)

  # Create a standalone db:book file for the module
  dbkStandalone = DOCBOOK_BOOK_XSL(xml)
  newFiles['index.standalone.dbk'] = etree.tostring(dbkStandalone)
  
  return etree.tostring(xml), newFiles
