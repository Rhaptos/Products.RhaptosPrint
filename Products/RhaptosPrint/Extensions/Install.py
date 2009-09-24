from Products.CMFCore.utils import getToolByName
from StringIO import StringIO
import string

def install(self):
    
    # Add the tool
    out = StringIO()
    urltool = getToolByName(self, 'portal_url')
    portal = urltool.getPortalObject();
    try:
        portal.manage_delObjects('Print Tool')
        out.write("Removed old print tool\n")
    except:
        pass  # we don't care if it fails
    portal.manage_addProduct['RhaptosPrint'].manage_addTool('Print Tool', None)
    
    out.write("Adding Print Tool\n")

    return out.getvalue()