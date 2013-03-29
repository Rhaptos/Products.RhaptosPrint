"""
RhaptosPrintTool - tool for storage of collection print files and their status

Author: Ed Woodward
(C) 2008 Rice University

This software is subject to the provisions of the GNU Lesser General
Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
"""
import simplejson
from Products.CMFCore.utils import UniqueObject
from Products.CMFCore.utils import getToolByName
from Products.CMFPlone import utils
from Products.PageTemplates.PageTemplateFile import PageTemplateFile
from Globals import InitializeClass
from Globals import package_home
from OFS.SimpleItem import SimpleItem
from BTrees.OOBTree import OOBTree
import AccessControl

from config import GLOBALS
from interfaces import rhaptos_print
from ZODB.POSException import POSKeyError

import zLOG
def log(msg, severity=zLOG.INFO):
    zLOG.LOG("RhaptosPrintTool: ", severity, msg)

class RhaptosPrintTool(UniqueObject, SimpleItem):
    """
    Tool for storage of Print files
    """

    id = 'rhaptos_print'
    meta_type = 'Print Tool'
    __implements__ = (rhaptos_print)

    security = AccessControl.ClassSecurityInfo()

    manage_options = (({'label':'Overview', 'action':'manage_overview'},
                       {'label':'Configure Print Styles', 'action':'manage_print_style_configure'},
                       {'label':'Configure Build Mappings', 'action':'manage_build_mappings_configure'},
                       {'label':'Configure Storage', 'action':'manage_configure'},
                       {'label':'Configure Print Params', 'action':'manage_params'}
                      )+ SimpleItem.manage_options
                     )

    ManagePermission = 'View management screens'

    ##   ZMI methods
    security.declareProtected(ManagePermission, 'manage_overview')
    manage_overview = PageTemplateFile('zpt/explainRhaptosPrint.zpt', globals())

    security.declareProtected(ManagePermission, 'manage_print_style_configure')
    manage_print_style_configure = PageTemplateFile('zpt/manage_print_style_configure.zpt', globals())
    security.declareProtected(ManagePermission, 'manage_build_mappings_configure')
    manage_build_mappings_configure = PageTemplateFile('zpt/manage_build_mappings_configure.zpt', globals())

    security.declareProtected(ManagePermission, 'manage_configure')
    manage_configure = PageTemplateFile('zpt/manage_print.zpt', globals())


    security.declareProtected(ManagePermission, 'manage_params')
    manage_params = PageTemplateFile('zpt/manage_params.zpt', globals())

    DEFAULT_NAME_PATTERN = "%s-%s.%s"
    DEFAULT_OBJECT_TYPE = "File"
    DEFAULT_CONTAINER = "Large Plone Folder"
    DEFAULT_STORAGE_PATH = "/plone/pdfs"

    def __init__(self, storagePath=None, namePattern=DEFAULT_NAME_PATTERN, objType=DEFAULT_OBJECT_TYPE, containerType=DEFAULT_CONTAINER):
       """
       Parameters:
           storagePath - the location where files are stored
           namePattern - the pattern for naming saved files
           objType - the  portal_type name of the type of object to store file data
           containerType - the  portal_type name of the container to store file data objects
       """
       self.storagePath = storagePath
       self.namePattern = namePattern
       self.objectType = objType
       self.containerType = containerType
       self.print_file_status = OOBTree()  # like {}, but plays nice with persistence

    def manage_afterAdd(self, item, container):
        SimpleItem.manage_afterAdd(self, item, container)
        portal_url = getToolByName(container, 'portal_url')
        storagePath = portal_url.getPortalPath() + '/pdfs'
        self.DEFAULT_STORAGE_PATH = storagePath
        if self.storagePath is None:
            self.storagePath = storagePath
        self._print_styles = []
        self._build_mappings = []

    def setFile(self, objectId, version, type, data):
        """
        method from rhaptos_print interface.
        Adds file to container
        Parameters:
            objectId - the module or collection id
            version - the module or collection version
            type - file type: pdf or zip
            data - the print file to store
        """
        #Grab the file to update, else create a new one.
        container = self._getContainer()
        if hasattr(container, '_write_file'): # It's some flavor of localFS
            # Hey, we're a localFS folder, do it directly
            fileName = self._createFileName(objectId, version, type)
            container._write_file(data, container._getpath(fileName))

        else: # Do the plone/object dance

            printFile = self.getFile(objectId, version, type)
            if not printFile:
                container = self._getContainer()
                fileName = self._createFileName(objectId, version, type)
                printFile = utils._createObjectByType(self.objectType, container, id=fileName )
            try:
                printFile.update_data(data)
                printFile.setModificationDate()
            except AttributeError, e:
                try:
                    # with AT types we look for the primary field
                    printFile.getPrimaryField().getMutator(printFile)(data)
                except AttributeError:
                    raise AttributeError("Error creating %s: Primary field method for this type (%s) not known" % (self.objectType, self.containerType))

    def getFile(self, objectId, version, type):
        """
        method from rhaptos_print interface
        Parameters:
            objectId - the module or collection id
            version - the module or collection version
            type - file type: pdf or zip
        Returns:
            If file is cached, the pdf or zip is returned, otherwise None is returned.
        """
        container = self._getContainer()
        fileName = self._createFileName(objectId, version, type)
        printFile = getattr(container, fileName, None)

        if printFile is not None:
            try:
                # access the object to see if it really exists
                size = printFile.size()
            except TypeError:
                # it's not a method, probably an int, just use it
                size = printFile.size
            except POSKeyError:
                # not really there there, so nuke it
                size = 0
                printFile = None
                log('removing unaccessible file from the Print Tool data store, for file (%s,%s,%s)' % (objectId,version,type))
                self.destroyFile(objectId, version, type)

        return printFile

    def destroyFile(self, objectId, version, filetype):
        """
        Completely remove stored data
        Parameters:
            objectId - the module or collection id
            version - the module or collection version
            filetype - file type: pdf or zip
        """
        container = self._getContainer()
        fileName = self._createFileName(objectId, version, filetype)
        if getattr(container, fileName, None):
            container.manage_delObjects([fileName])
        if self.print_file_status.has_key(fileName):
            del self.print_file_status[fileName]

    def doesFileExist(self, objectId, version, type):
        """
        return True or False depending on if the file has been cached by PrintTool.
        """
        objFile = self.getFile(objectId, version, type)
        if objFile is not None:
            return True
        else:
            return False

    def getModificationDate(self, objectId, version, type):
        """
        return the modifcation date for the cached file.
        """
        objFile = self.getFile(objectId, version, type)
        mod_date = ''
        if objFile is not None:
            try:
                mod_date = objFile.aq_explicit.ModificationDate()
            except AttributeError:
                mod_date = str(objFile.bobobase_modification_time())

        return mod_date

    def setStatus(self, objectId, version, type, status):
        """
        method from rhaptos_print interface.  Updates status for given file type
        Parameters:
            objectId - the module or collection id
            version - the module or collection version
            type - file type: pdf or zip
            status - status of last file object generation: failed or success (or locked)
        """
        self.print_file_status[self._createFileName(objectId, version, type)] = status

    def getStatus(self, objectId, version, type):
        """
        method from rhaptos_print interface. Returns status of last file object generation for given collection/Module
        Parameters:
            objectId - the module or collection id
            version - the module or collection version
            type - file type: pdf or zip
        Returns:
            the current status (success or failed or locked) or None
        """
        status = self.print_file_status.get(self._createFileName(objectId, version, type), None)
        if status in ('failed', 'locked',):
            return status
        elif self.doesFileExist(objectId, version, type):
            return 'success'
        else:
            return status

        return self.print_file_status.get(self._createFileName(objectId, version, type), None)

    def manage_print(self, storagePath, namePattern, objectType, containerType, REQUEST=None):
        """
        Post creation configuration.  See manage_print.zpt
        If parameter has a value, use it.  Otherwise set values to defaults
        Parameters:
           storagePath - the location where files are stored
           namePattern - the pattern for naming saved files
           objType - portal_type name of the type of object to store file data
           containerType - the  portal_type name of the container to store file data objects
           REQUEST - the HTTP request object
        """
        if storagePath != '' and storagePath != None:
            self.storagePath = storagePath
        else:
            self.storagePath=DEFAULT_STORAGE_PATH
        if namePattern != '' and namePattern != None:
            self.namePattern = namePattern
        else:
            self.namePattern=DEFAULT_NAME_PATTERN
        if objectType != '' and objectType != None:
            self.objectType = objectType
        else:
            self.objType=DEFAULT_OBJECT_TYPE
        if containerType != '' and containerType != None:
            self.containerType = containerType
        else:
            self.containerType=DEFAULT_CONTAINER
        if REQUEST:
            return self.manage_configure(manage_tabs_message="RhaptosPrint updated")

    def _createFileName(self, objectId, version, type):
        """
        Creates a file name based on pattern using data passed in
        Parameters:
            objectId - the module or collection id
            version - the module or collection version
            type - file type: pdf or zip
        """
        return self.namePattern % (objectId, version, type)

    def _getContainer(self):
        """
        gets container based on storage path
        """
        container = None
        try:
            container = self.restrictedTraverse(self.storagePath)
        except AttributeError:
            container = self.restrictedTraverse('/'.join(self.storagePath.split('/')[:-1]))
            container = utils._createObjectByType(self.containerType, container, id=self.storagePath.split('/')[-1] )
        return container

    ## Print config methods, formerly of RhaptosCollection.AsyncPrint ##

    security.declareProtected(ManagePermission, 'manage_setConfig')
    def manage_setConfig(self, makefilepath, portal, host, REQUEST=None):
        """Post-creation config; see manage_config's ZPT."""
        self._makefile = makefilepath
        self._portal = portal
        self._host = host
        if REQUEST is not None:
            REQUEST.RESPONSE.redirect(self.absolute_url()+'/manage_params')

    security.declareProtected(ManagePermission, 'manage_setPrintStyling')
    def manage_setPrintStyling(self, print_styles, REQUEST=None):
        """Print styling setting's form handler."""
        styles = simplejson.loads(print_styles)
        # Simple data validation
        for style in styles:
            assert 'id' in style, style
            assert 'title' in style, style
        self._print_styles = styles
        if REQUEST is not None:
            REQUEST.RESPONSE.redirect(self.absolute_url()+'/manage_print_style_configure')

    security.declareProtected(ManagePermission, 'manage_setBuildMappings')
    def manage_setBuildMappings(self, mappings, REQUEST=None):
        """Print build mappings setting's form handler."""
        mappings = simplejson.loads(mappings)
        print_styles = [x['id'] for x in self._print_styles]
        # Simple data validation
        for print_style, build_suite in mappings:
            assert print_style in print_styles, "Invalid print-style: '%s'" % print_style
        self._build_mappings = mappings
        if REQUEST is not None:
            REQUEST.RESPONSE.redirect(self.absolute_url()+'/manage_build_mappings_configure')

    security.declareProtected(ManagePermission, 'getMakefile')
    def getMakefile(self, default=1):
        """Return makefile path; meant only for manager consumption.
         'default' if true returns a default value if the field is empty.
        """
        makefile = getattr(self, "_makefile", None)
        if default and not makefile:
            return "%s/printing/Makefile" % package_home(GLOBALS)
        return makefile

    security.declareProtected(ManagePermission, 'getEpubDir')
    def getEpubDir(self):
        """Return makefile path; meant only for manager consumption.
         'default' if true returns a default value if the field is empty.
        """
        return "%s/epub" % package_home(GLOBALS)

    security.declarePublic(ManagePermission, 'getAlternateStyles')
    def getAlternateStyles(self, json=False):
        """Returns a list of different print styles. The default is the LaTex format.
        Also, the id corresponds to a .xsl file in the getEpubDir()/xsl
        The json parameter to this function can be use to return the data as json.
        """
        result = self._print_styles
        if json:
            result = simplejson.dumps(result)
        return result

    security.declarePublic(ManagePermission, 'getBuildMappings')
    def getBuildMappings(self, json=False):
        """Returns a list of print build mappings. If the mapping doesn't exist
        you should fall back to latex as the default.
        The json parameter to this function can be use to return the data as json.
        """
        result = self._build_mappings
        if json:
            result = simplejson.dumps(result)
        return result

    security.declareProtected(ManagePermission, 'getPortalPath')
    def getPortalPath(self, default=1):
        """Return path to the Rhaptos portal; meant only for manager consumption.
         'default' if true returns a default value if the field is empty.
        """
        portal = getattr(self, "_portal", None)
        if default and not portal:
            if self.getParentNode().meta_type == 'Plone Site':
                return '/'.join(self.getParentNode().getPhysicalPath())
            else:
                return "/plone"
        return portal

    security.declareProtected(ManagePermission, 'getHost')
    def getHost(self, default=1):
        """Return host to download data from during build; meant only for manager consumption.
         'default' if true returns a default value if the field is empty.
        """
        host = getattr(self, "_host", None)
        if default and not host:
            # XXX : verify this. This is incorrect anyway.
            # Throwing errors with default values
            #port = self.absolute_url().split('/')[2].split(':')[1]
            #return "localhost:%s" % port
            host = self.absolute_url().split('/')[2]
        # PDF Generation needs the portal root, not just host to get the
        # Collection RDF
        return self.portal_url.getPortalObject().absolute_url()


InitializeClass(RhaptosPrintTool)
