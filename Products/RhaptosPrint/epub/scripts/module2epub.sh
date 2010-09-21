#!/bin/sh

# 1st arg is the path to the collection
# 2nd arg is the epub zip file
# 3rd arg is the path to the dbk2___.xsl file ("epub" for epub generation, and "html" for the html zip)
# 4th arg is optional and if non-empty signifies that we do not need to recreate the dbk files 

WORKING_DIR=$1
EPUB_FILE=$2
CONTENT_ID_AND_VERSION=$3
DBK_TO_HTML_XSL=$4

SKIP_DBK_GENERATION=""

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT/.."; pwd) # .. since we live in scripts/

RUBY=$(which ruby)

EXIT_STATUS=0

# If the user did not supply a custom stylesheet, use the default one
if [ ".$DBK_TO_HTML_XSL" = "." ]; then
  DBK_TO_HTML_XSL=$ROOT/xsl/dbk2epub.xsl
fi

if [ -s $WORKING_DIR/index.cnxml ]; then 
  DBK_FILE=$WORKING_DIR/index.dbk
  MODULE=$CONTENT_ID_AND_VERSION
  MODULE=${MODULE%%_*}
  
  if [ ".$SKIP_DBK_GENERATION" == "." ]; then
    bash $ROOT/scripts/module2dbk.sh $WORKING_DIR $MODULE
    EXIT_STATUS=$EXIT_STATUS || $?

    # Generate a cover image for the book version of the module
    bash $ROOT/scripts/dbk2cover.sh $DBK_FILE
    EXIT_STATUS=$EXIT_STATUS || $?
  fi

elif [ -s $WORKING_DIR/collection.xml ]; then
  DBK_FILE=$WORKING_DIR/collection.dbk
  
  if [ ".$SKIP_DBK_GENERATION" == "." ]; then
    bash $ROOT/scripts/collection2dbk.sh $WORKING_DIR
    EXIT_STATUS=$EXIT_STATUS || $?
  fi
  
else
  echo "ERROR: The first argument does not point to a directory containing a 'index.cnxml' or 'collection.xml' file" 1>&2
  exit 1
fi

$RUBY $ROOT/docbook-xsl/epub/bin/dbtoepub --stylesheet $DBK_TO_HTML_XSL -c $ROOT/static/content.css -d $DBK_FILE -o $EPUB_FILE
EXIT_STATUS=$EXIT_STATUS || $?

exit $EXIT_STATUS
