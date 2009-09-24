from Products.RhaptosSite.tests.RhaptosTestCase import RhaptosTestCase
from CMFTestCase import CMFTestCase
import os
import sys

if __name__ == '__main__':
    execfile(os.path.join(sys.path[0], 'framework.py'))

from Testing import ZopeTestCase


ZopeTestCase.installProduct('RhaptosPrint')

class TestRhaptosPrintTool(RhaptosTestCase):
    
    def afterSetUp(self):
        RhaptosTestCase.afterSetUp(self)
        
        self.content = self.portal.content
        self.printTool = self.content.rhaptos_print
        self.sampleFile = open('/home/ew2/temp/samplePDF', 'r')
        self.sampleFileData = sampleFile.read()
        self.testStatus = 'failed'
    
    def testGetFile(self):
        printFile = self.printTool.getFile('m1000', '1.1', 'pdf')
        assertEqual(len(printFile), len(self.sampleFileData))
        
        
    def testSetFile(self):
        self.printTool.setFile('m1000', '1.1', 'pdf', self.sampleFileData)
        
    def testGetStatus(self):
        status = self.printTool.getStatus('m1000', '1.1', 'pdf')
        assertEqual(status, testStatus)
        
    def testSetStatus(self):
        self.printTool.setStatus('m1000', '1.1', 'pdf', 'failed')
        
if __name__ == '__main__':
    framework()
else:
    import unittest
    def test_suite():
        suite = unittest.TestSuite()
        suite.addTest(unittest.makeSuite(TestRhaptosPrintTool))
        return suite