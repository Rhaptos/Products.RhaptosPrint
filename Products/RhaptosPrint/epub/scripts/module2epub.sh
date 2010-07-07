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
DBK2SVG_COVER_XSL=$ROOT/xsl/dbk2svg-cover.xsl

CONVERT=convert

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
  COVER_PREFIX=cover
  COVER_SVG=$COL_PATH/_$COVER_PREFIX.svg
  COVER_PNG=$COL_PATH/$COVER_PREFIX.png
  
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
  COVER_PNG_FILES=`find $COL_PATH -name $COVER_PREFIX.??g | sort -r`
  if [ "$COVER_PNG_FILES." == "." ]; then
    echo "LOG: DEBUG: Creating cover page"
    $XSLTPROC -o $COVER_SVG $DBK2SVG_COVER_XSL $DBK_FILE
    EXIT_STATUS=$EXIT_STATUS || $?
    
    if [ -s $COVER_SVG ]; then
      echo "LOG: DEBUG: Converting SVG Cover Page to PNG"
      # For Macs, use inkscape
      if [ -e /Applications/Inkscape.app/Contents/Resources/bin/inkscape ]; then
        (/Applications/Inkscape.app/Contents/Resources/bin/inkscape $COVER_SVG --export-png=$COVER_PNG 2>&1) > $COL_PATH/__err.txt
        EXIT_STATUS=$EXIT_STATUS || $?
      else
        $CONVERT $COVER_SVG $COVER_PNG
        EXIT_STATUS=$EXIT_STATUS || $?
      fi
    else
      # Print saner error messages.
      echo "LOG: ERROR: Converting Cover page: SVG file not found"
      EXIT_STATUS=$EXIT_STATUS || 1
    fi
  else
    echo "LOG: DEBUG: Converting existing cover image"
    COVER_FILES_SVG=`find $COL_PATH -name $COVER_PREFIX.svg | sort -r`
    COVER_FILES_PNG=`find $COL_PATH -name $COVER_PREFIX.png | sort -r`
    if [ "$COVER_FILES_SVG." != "." ]; then
      echo "LOG: DEBUG: Converting existing cover SVG named ${COVER_FILES_SVG[0]}"
      # For Macs, use inkscape
      if [ -e /Applications/Inkscape.app/Contents/Resources/bin/inkscape ]; then
        (/Applications/Inkscape.app/Contents/Resources/bin/inkscape ${COVER_FILES_SVG[0]} --export-png=$COVER_PNG 2>&1) > $COL_PATH/__err.txt
        EXIT_STATUS=$EXIT_STATUS || $?
      else
        $CONVERT ${COVER_FILES_SVG[0]} $COVER_PNG
        EXIT_STATUS=$EXIT_STATUS || $?
      fi
    else
      echo "LOG: DEBUG: Converting existing cover PNG named ${COVER_FILES_PNG[0]}"
      cp $COVER_FILES_PNG $COVER_PNG
    fi
  fi
fi

$ROOT/docbook-xsl/epub/bin/dbtoepub --stylesheet $ROOT/xsl/dbk2epub.xsl -c $ROOT/content.css -d $DBK_FILE -o $EPUB_FILE
