#!/bin/sh

# 1st arg is the path to the collection
# 2nd arg is the epub zip file
# 3rd arg is the path to the dbk2___.xsl file ("epub" for epub generation, and "html" for the html zip)

WORKING_DIR=$1
EPUB_FILE=$2
DBK_TO_HTML_XSL=$3

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

EXIT_STATUS=0

# If the user did not supply a custom stylesheet, use the default one
if [ ".$DBK_TO_HTML_XSL" = "." ]; then
  DBK_TO_HTML_XSL=$ROOT/xsl/dbk2epub.xsl
fi

if [ -s $WORKING_DIR/index.cnxml ]; then 
  DBK_FILE=$WORKING_DIR/index.dbk
  MODULE=`basename $WORKING_DIR`;
  bash $ROOT/scripts/module2dbk.sh $WORKING_DIR $MODULE
  EXIT_STATUS=$EXIT_STATUS || $?

elif [ -s $WORKING_DIR/collection.xml ]; then
  DBK_FILE=$WORKING_DIR/collection.dbk
  bash $ROOT/scripts/collection2dbk.sh $WORKING_DIR
  EXIT_STATUS=$EXIT_STATUS || $?
  
else
  echo "ERROR: The first argument does not point to a directory containing a 'index.cnxml' or 'collection.xml' file" 1>&2
  exit 1
fi

$ROOT/docbook-xsl/epub/bin/dbtoepub --stylesheet $DBK_TO_HTML_XSL -c $ROOT/static/content.css -d $DBK_FILE -o $EPUB_FILE
EXIT_STATUS=$EXIT_STATUS || $?

exit $EXIT_STATUS
