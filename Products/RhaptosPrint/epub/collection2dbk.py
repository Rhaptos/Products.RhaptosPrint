# from lxml import etree; import collection2dbk; print collection2dbk.convert(etree.parse('tests/collection.xml'), {'simplemath':(etree.parse('tests/simplemath/index.cnxml'), {}) })

import sys
import os
import Image
from StringIO import StringIO
from tempfile import mkstemp

from lxml import etree
import urllib2

import module2dbk
import util

COLLXML_PARAMS = util.makeXsl('collxml-params.xsl')
COLLXML2DOCBOOK_XSL = util.makeXsl('collxml2dbk.xsl')

DOCBOOK_CLEANUP_XSL = util.makeXsl('dbk-clean-whole.xsl')
DOCBOOK_NORMALIZE_PATHS_XSL = util.makeXsl('dbk2epub-normalize-paths.xsl')
DOCBOOK_NORMALIZE_GLOSSARY_XSL = util.makeXsl('dbk-clean-whole-remove-duplicate-glossentry.xsl')


XINCLUDE_XPATH = etree.XPath('//xi:include', namespaces=util.NAMESPACES)

def transform(xslDoc, xmlDoc):
  """ Performs an XSLT transform and parses the <xsl:message /> text """
  ret = xslDoc(xmlDoc)
  for entry in xslDoc.error_log:
    # TODO: Log the errors (and convert JSON to python) instead of just printing
    print entry
  return ret

# Main method. Doing all steps for the Google Docs to CNXML transformation
def convert(collxml, modulesDict):
  """ Convert a collxml file (and dictionary of module info) to a Docbook file and dict of filename:bytes) """

  newFiles = {}

  params = transform(COLLXML_PARAMS, collxml)
  print "TODO: Need to do something with collection parameters"
  dbk1 = transform(COLLXML2DOCBOOK_XSL, collxml)

  modDbkDict = {}
  for module, (cnxml, filesDict) in modulesDict.items():
    print "TODO: Send the collection parameters"
    modDbk, newFiles = module2dbk.convert(module, cnxml, filesDict)
    modDbkDict[module] = etree.parse(StringIO(modDbk)).getroot()

  # Combine into a single large file
  # Replacing Xpath xinclude magic with explicit pyhton code
  for i, module in enumerate(XINCLUDE_XPATH(dbk1)):
    # m9003/index.included.dbk
    id = module.get('href').split('/')[0]
    if id in modDbkDict:
      module.getparent().replace(module, modDbkDict[id])
    else:
      print "ERROR: Didn't find module source!!!!"
        
  # Clean up image paths
  dbk2 = transform(DOCBOOK_NORMALIZE_PATHS_XSL, dbk1)
  
  dbk3 = transform(DOCBOOK_CLEANUP_XSL, dbk2)
  dbk4 = transform(DOCBOOK_NORMALIZE_GLOSSARY_XSL, dbk3)

  # Create cover SVG and convert it to an image
  png, newFiles2 = util.dbk2cover(dbk4, filesDict)

  newFiles['cover.png'] = png

  return etree.tostring(dbk4), newFiles
