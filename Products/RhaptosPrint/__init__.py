import sys
from Products.CMFCore import utils
import RhaptosPrintTool

this_module = sys.modules[ __name__ ]
tools = ( RhaptosPrintTool.RhaptosPrintTool,)

def initialize(context):
    utils.ToolInit('Print Tool',
                    tools = tools,
                    icon='tool.gif' 
                    ).initialize( context )