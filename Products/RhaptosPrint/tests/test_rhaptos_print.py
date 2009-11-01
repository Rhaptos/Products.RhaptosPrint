#------------------------------------------------------------------------------#
#   test_rhaptos_print.py                                                      #
#                                                                              #
#       Authors:                                                               #
#       Rajiv Bakulesh Shah <raj@enfoldsystems.com>                            #
#                                                                              #
#           Copyright (c) 2009, Enfold Systems, Inc.                           #
#           All rights reserved.                                               #
#                                                                              #
#               This software is licensed under the Terms and Conditions       #
#               contained within the "LICENSE.txt" file that accompanied       #
#               this software.  Any inquiries concerning the scope or          #
#               enforceability of the license should be addressed to:          #
#                                                                              #
#                   Enfold Systems, Inc.                                       #
#                   4617 Montrose Blvd., Suite C215                            #
#                   Houston, Texas 77006 USA                                   #
#                   p. +1 713.942.2377 | f. +1 832.201.8856                    #
#                   www.enfoldsystems.com                                      #
#                   info@enfoldsystems.com                                     #
#------------------------------------------------------------------------------#
"""Unit tests.
$Id: $
"""


from Products.RhaptosTest import config
import Products.RhaptosPrint
config.products_to_load_zcml = [('configure.zcml', Products.RhaptosPrint),]
config.products_to_install = ['RhaptosPrint']
config.extension_profiles = ['Products.RhaptosPrint:default']

from Products.CMFCore.utils import getToolByName
from Products.RhaptosTest import base


class TestRhaptosPrint(base.RhaptosTestCase):

    def afterSetUp(self):
        self.print_tool = getToolByName(self.portal, 'rhaptos_print')

    def beforeTearDown(self):
        pass

    def test_rhaptos_print_tool(self):
        self.assertEqual(1, 1)

    def test_rhaptos_print_tool_get_file(self):
        f = self.print_tool.getFile('nonexist-id', 'nonexist-ver', 'pdf')
        self.assertEqual(f, None)
        f = self.print_tool.getFile('nonexist-id', 'nonexist-ver', 'zip')
        self.assertEqual(f, None)

    def test_rhaptos_print_tool_get_status(self):
        stat = self.print_tool.getStatus('nonexist-id', 'nonexist-ver', 'pdf')
        self.assertEqual(stat, None)
        stat = self.print_tool.getFile('nonexist-id', 'nonexist-ver', 'zip')
        self.assertEqual(stat, None)


def test_suite():
    from unittest import TestSuite, makeSuite
    suite = TestSuite()
    suite.addTest(makeSuite(TestRhaptosPrint))
    return suite
