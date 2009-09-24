try:
    from Interface import Interface
except ImportError:
    from Interface import Base as Interface

class rhaptos_print(Interface):
    """
    Provides an interface for a tool that stores module PDF and ZIP files
    """
    
    def setFile(self, objectId, version, type, data): 
        """Store persistently the given 'data', a string [or file-ish object].
        'objectId', 'version' are those values from the content
        'type' is as file extension; expected to be 'pdf' or 'zip'
        """

    def getFile(self, objectId, version, type): 
        """Retrieve stored data from previous 'setFile'
        'objectId', 'version' are those values from the content
        'type' is as file extension; expected to be 'pdf' or 'zip'
        Return a string [or file-ish object], or None if no data can be found.
        """

    def setStatus(self, objectId, version, type, status): 
        """Set a certain status about stored data as specified by 'objectId', 'version', 'type'.
        'objectId', 'version' are those values from the content
        'type' is as file extension; expected to be 'pdf' or 'zip'
        'status' is one of a choice of several strings (probably the set in !RhaptosCollection.config.PROCESS_MODES);
         or perhaps we allow free-form.
        """

    def getStatus(self, objectId, version, type): 
        """Retrieve status for a particular object as specified by 'objectId', 'version', 'type'.
        'objectId', 'version' are those values from the content
        'type' is as file extension; expected to be 'pdf' or 'zip'
        Return 'status', one of a choice of several strings (probably the set in !RhaptosCollection.config.PROCESS_MODES),
         or maybe just whatever was set.
        """
