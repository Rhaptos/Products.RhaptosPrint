#!/bin/sh

# 1st arg is the path to the collection
# 2nd arg (optional) is the module name
# 3rd arg is the epub zip file
WORKING_DIR=$1
EPUB_FILE=$2
DBK_TO_HTML_XSL=$3

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

# If the user did not supply a custom stylesheet, use the default one
if [ ".$DBK_TO_HTML_XSL" = "." ]; then
  DBK_TO_HTML_XSL=$ROOT/xsl/dbk2epub.xsl
fi

if [ -s $WORKING_DIR/index.cnxml ]; then 
  MODULE=`basename $WORKING_DIR`;
  bash $ROOT/scripts/module2dbk.sh $WORKING_DIR $MODULE
  DBK_FILE=$WORKING_DIR/index.dbk

elif [ -s $WORKING_DIR/collection.xml ]; then
  bash $ROOT/scripts/collection2dbk.sh $WORKING_DIR
  DBK_FILE=$WORKING_DIR/collection.dbk
  
else
  echo "ERROR: The first argument does not point to a directory containing a 'index.cnxml' or 'collection.xml' file" 1>&2
  exit 1
fi

$ROOT/docbook-xsl/epub/bin/dbtoepub --stylesheet $DBK_TO_HTML_XSL -c $ROOT/static/content.css -d $DBK_FILE -o $EPUB_FILE
