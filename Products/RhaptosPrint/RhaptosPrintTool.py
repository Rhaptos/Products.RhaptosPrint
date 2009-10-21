"""
RhaptosPrintTool - tool for storage of collection print files and their status

Author: Ed Woodward
(C) 2008 Rice University

This software is subject to the provisions of the GNU Lesser General
Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
"""

from Products.CMFCore.utils import UniqueObject
from Products.CMFCore.utils import getToolByName
from Products.CMFPlone import utils
from Products.PageTemplates.PageTemplateFile import PageTemplateFile
from Globals import InitializeClass
from OFS.SimpleItem import SimpleItem
from BTrees.OOBTree import OOBTree

from interfaces.rhaptos_print import rhaptos_print

class RhaptosPrintTool(UniqueObject, SimpleItem):
    """
    Tool for storage of Print files
    """
    
    id = 'rhaptos_print'
    meta_type = 'Print Tool'
    __implements__ = (rhaptos_print)
   
    manage_options = (({'label':'Overview', 'action':'manage_overview'},
                       {'label':'Configure', 'action':'manage_configure'}
                      )+ SimpleItem.manage_options
                     )
    
    manage_overview = PageTemplateFile('zpt/explainRhaptosPrint.zpt', globals())
    manage_configure = PageTemplateFile('zpt/manage_print.zpt', globals())
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
        printFile = self.getFile(objectId, version, type)
        if not printFile:
            container = self._getContainer()
            printFile = utils._createObjectByType(self.objectType, container, id=self._createFileName(objectId, version, type) )
        try:
            printFile.update_data(data)
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
        printFile = getattr(container, self._createFileName(objectId, version, type), None)
        
        return printFile

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

InitializeClass(RhaptosPrintTool)
