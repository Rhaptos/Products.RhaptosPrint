#!/bin/sh

# 1st arg is the path to the collection
# 2nd arg (optional) is the module name
# 3rd arg is the epub zip file
WORKING_DIR=$1
EPUB_FILE=$2
DBK_TO_HTML_XSL=$3

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/


XSLTPROC="xsltproc"


# XSL files
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
DOCBOOK_NORMALIZE_PATHS_XSL=$ROOT/xsl/dbk2epub-normalize-paths.xsl
DOCBOOK_NORMALIZE_GLOSSARY_XSL=$ROOT/xsl/dbk-clean-whole-remove-duplicate-glossentry.xsl
DBK2SVG_COVER_XSL=$ROOT/xsl/dbk2svg-cover.xsl

# If the user did not supply a custom stylesheet, use the default one
if [ ".$DBK_TO_HTML_XSL" = "." ]; then
  DBK_TO_HTML_XSL=$ROOT/xsl/dbk2epub.xsl
fi

if [ -s $WORKING_DIR/index.cnxml ]; then 
  MODULE=`basename $WORKING_DIR`;
  bash $ROOT/scripts/module2dbk.sh $WORKING_DIR $MODULE
  DBK_FILE=$WORKING_DIR/index.dbk

elif [ -s $WORKING_DIR/collection.xml ]; then
  MODULES=`ls $WORKING_DIR`
  bash $ROOT/scripts/collection2dbk.sh $WORKING_DIR
  
  # Clean up image paths
  DOCBOOK=$WORKING_DIR/collection.dbk
  DOCBOOK2=$WORKING_DIR/_collection.normalized.dbk
  DOCBOOK3=$WORKING_DIR/_collection3.dbk
  DBK_FILE=$WORKING_DIR/collection.cleaned.dbk
  COVER_PREFIX=cover
  COLLECTION_COVER_PREFIX=_collection_$COVER_PREFIX
  COVER_SVG=$WORKING_DIR/_$COVER_PREFIX.svg
  COVER_PNG=$WORKING_DIR/$COVER_PREFIX.png
  
  INKSCAPE=`which inkscape`
  if [ ".$INKSCAPE" == "." ]; then
    INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
    if [ ! -e $INKSCAPE ]; then
      echo "LOG: ERROR: Inkscape not found." 1>&2
      exit 1
    fi
  fi
  
  # remove all the temp files first so we don't accidentally use old ones
  [ -s $DOCBOOK2 ] && rm $DOCBOOK2
  [ -s $DOCBOOK3 ] && rm $DOCBOOK3
  [ -s $DBK_FILE ] && rm $DBK_FILE
  [ -s $COVER_SVG ] && rm $COVER_SVG
  [ -s $COVER_PNG ] && rm $COVER_PNG
  
  $XSLTPROC --xinclude -o $DOCBOOK2 $DOCBOOK_NORMALIZE_PATHS_XSL $DOCBOOK
  $XSLTPROC -o $DOCBOOK3 $DOCBOOK_CLEANUP_XSL $DOCBOOK2
  $XSLTPROC -o $DBK_FILE $DOCBOOK_NORMALIZE_GLOSSARY_XSL $DOCBOOK3
  
  
  # Create cover SVG and convert it to an image
  COVER_FILES=`find $WORKING_DIR -name $COLLECTION_COVER_PREFIX.??g | sort -r`
  if [ "$COVER_FILES." == "." ]; then
    echo "LOG: DEBUG: Creating cover page"
    $XSLTPROC -o $COVER_SVG $DBK2SVG_COVER_XSL $DBK_FILE
    EXIT_STATUS=$EXIT_STATUS || $?
    
    if [ -s $COVER_SVG ]; then
      echo "LOG: DEBUG: Converting SVG Cover Page to PNG"
      ($INKSCAPE $COVER_SVG --export-png=$COVER_PNG 2>&1) > $WORKING_DIR/__err.txt
      EXIT_STATUS=$EXIT_STATUS || $?
    else
      # Print saner error messages.
      echo "LOG: ERROR: Converting Cover page: SVG file not found" 1>&2
      EXIT_STATUS=$EXIT_STATUS || 1
    fi
  else
    echo "LOG: DEBUG: Converting existing cover image"
    COVER_FILES_SVG=`find $WORKING_DIR -name $COLLECTION_COVER_PREFIX.svg | sort -r`
    COVER_FILES_PNG=`find $WORKING_DIR -name $COLLECTION_COVER_PREFIX.png | sort -r`
    if [ "$COVER_FILES_SVG." != "." ]; then
      echo "LOG: DEBUG: Converting existing cover SVG named ${COVER_FILES_SVG[0]}"
      ($INKSCAPE ${COVER_FILES_SVG[0]} --export-png=$COVER_PNG 2>&1) > $WORKING_DIR/__err.txt
      EXIT_STATUS=$EXIT_STATUS || $?
    else
      echo "LOG: DEBUG: Converting existing cover PNG named ${COVER_FILES_PNG[0]}"
      cp $COVER_FILES_PNG $COVER_PNG
    fi
  fi
else
  echo "ERROR: The first argument does not point to a directory containing a 'index.cnxml' or 'collection.xml' file" 1>&2
  exit 1
fi

$ROOT/docbook-xsl/epub/bin/dbtoepub --stylesheet $DBK_TO_HTML_XSL -c $ROOT/content.css -d $DBK_FILE -o $EPUB_FILE
