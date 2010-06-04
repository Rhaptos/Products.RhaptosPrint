#!/bin/sh

# 1st arg is the path to the collection
# 2nd arg (optional) is the module name
# 3rd arg is the epub zip file
COL_PATH=$1
EPUB_FILE=$3

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/


XSLTPROC="xsltproc"

# Load up the custom params to xsltproc:
if [ -s $ROOT/params.txt ]; then
    #echo "Using custom params in params.txt for xsltproc."
    # cat $ROOT/params.txt
    OLD_IFS=$IFS
    IFS="
"
    XSLTPROC_ARGS=""
    for ARG in `cat $ROOT/params.txt`; do
      XSLTPROC_ARGS="$XSLTPROC_ARGS --param $ARG"
    done
    IFS=$OLD_IFS
    XSLTPROC="$XSLTPROC $XSLTPROC_ARGS"
fi


# XSL files
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
DOCBOOK_NORMALIZE_PATHS_XSL=$ROOT/xsl/dbk2epub-normalize-paths.xsl
DOCBOOK_NORMALIZE_GLOSSARY_XSL=$ROOT/xsl/dbk-clean-whole-remove-duplicate-glossentry.xsl

if [ ".$2" != "." ]; then 
  MODULE=$2;
  bash $ROOT/scripts/module2dbk.sh $COL_PATH $MODULE
  DBK_FILE=$COL_PATH/index.dbk
else
  MODULES=`ls $COL_PATH`
  bash $ROOT/scripts/collection2dbk.sh $COL_PATH
  
  # Clean up image paths
  DOCBOOK=$COL_PATH/collection.dbk
  DOCBOOK2=$COL_PATH/_collection.normalized.dbk
  DOCBOOK3=$COL_PATH/_collection3.dbk
  DBK_FILE=$COL_PATH/collection.cleaned.dbk
  $XSLTPROC --xinclude -o $DOCBOOK2 $DOCBOOK_NORMALIZE_PATHS_XSL $DOCBOOK
  $XSLTPROC -o $DOCBOOK3 $DOCBOOK_CLEANUP_XSL $DOCBOOK2
  $XSLTPROC -o $DBK_FILE $DOCBOOK_NORMALIZE_GLOSSARY_XSL $DOCBOOK3
fi

$ROOT/docbook-xsl/epub/bin/dbtoepub --stylesheet $ROOT/xsl/dbk2epub.xsl -c $ROOT/content.css -d $DBK_FILE -o $EPUB_FILE
