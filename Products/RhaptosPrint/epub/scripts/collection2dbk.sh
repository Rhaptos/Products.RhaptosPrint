#!/bin/sh

WORKING_DIR=$1
ID=$2

SKIP_MODULE_CONVERSION=0

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

EXIT_STATUS=0

COLLXML=$WORKING_DIR/collection.xml
PARAMS=$WORKING_DIR/_params.txt
COLLXML_DERIVED_PRE=$WORKING_DIR/_collection.derived.pre.xml
COLLXML_DERIVED_POST=$WORKING_DIR/_collection.derived.post.xml
DOCBOOK=$WORKING_DIR/_collection1.dbk
DOCBOOK2=$WORKING_DIR/_collection2.normalized.dbk
DOCBOOK3=$WORKING_DIR/_collection3.dbk
DBK_FILE=$WORKING_DIR/collection.dbk

XSLTPROC="xsltproc"
COLLXML_PARAMS=$ROOT/xsl/collxml-params.xsl
COLLXML_INCLUDE_DERIVED_FROM_XSL=$ROOT/xsl/collxml-derived-from.xsl
COLLXML_INCLUDE_DERIVED_FROM_CLEANUP_XSL=$ROOT/xsl/collxml-derived-from-cleanup.xsl
COLLXML2DOCBOOK_XSL=$ROOT/xsl/collxml2dbk.xsl

DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
DOCBOOK_NORMALIZE_PATHS_XSL=$ROOT/xsl/dbk2epub-normalize-paths.xsl
DOCBOOK_NORMALIZE_GLOSSARY_XSL=$ROOT/xsl/dbk-clean-whole-remove-duplicate-glossentry.xsl
DBK2SVG_COVER_XSL=$ROOT/xsl/dbk2svg-cover.xsl

MODULE2DOCBOOK=$ROOT/scripts/module2dbk.sh

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


echo "LOG: INFO: ------------ Starting on $WORKING_DIR --------------"
$XSLTPROC -o $PARAMS $COLLXML_PARAMS $COLLXML

# Load up the custom params to xsltproc:
if [ -s $PARAMS ]; then
    #echo "Using custom params in params.txt for xsltproc."
    # cat $PARAMS
    OLD_IFS=$IFS
    IFS="
"
    XSLTPROC_ARGS=""
    for ARG in `cat $PARAMS`; do
      if [ ".$ARG" != "." ]; then
        XSLTPROC_ARGS="$XSLTPROC_ARGS --param $ARG"
      fi
    done
    IFS=$OLD_IFS
    XSLTPROC="$XSLTPROC $XSLTPROC_ARGS"
fi

# If the collection has a md:derived-from, include it
$XSLTPROC -o $COLLXML_DERIVED_PRE $COLLXML_INCLUDE_DERIVED_FROM_XSL $COLLXML
EXIT_STATUS=$EXIT_STATUS || $?

# Clean up the md:derived-from
$XSLTPROC --xinclude -o $COLLXML_DERIVED_POST $COLLXML_INCLUDE_DERIVED_FROM_CLEANUP_XSL $COLLXML_DERIVED_PRE
EXIT_STATUS=$EXIT_STATUS || $?

# Clean up the md:derived-from
$XSLTPROC -o $DOCBOOK $COLLXML2DOCBOOK_XSL $COLLXML_DERIVED_POST
EXIT_STATUS=$EXIT_STATUS || $?



# For each module, generate a docbook file
if [ "$SKIP_MODULE_CONVERSION" = "0" ]; then
  for MODULE in `ls $WORKING_DIR`
  do
    if [ -d $WORKING_DIR/$MODULE ];
    then
      bash $MODULE2DOCBOOK $WORKING_DIR/$MODULE $MODULE
      EXIT_STATUS=$EXIT_STATUS || $?
    fi
  done
fi


# Combine into a single large file
# and clean up image paths
$XSLTPROC --xinclude -o $DOCBOOK2 $DOCBOOK_NORMALIZE_PATHS_XSL $DOCBOOK
EXIT_STATUS=$EXIT_STATUS || $?

$XSLTPROC -o $DOCBOOK3 $DOCBOOK_CLEANUP_XSL $DOCBOOK2
EXIT_STATUS=$EXIT_STATUS || $?

$XSLTPROC -o $DBK_FILE $DOCBOOK_NORMALIZE_GLOSSARY_XSL $DOCBOOK3
EXIT_STATUS=$EXIT_STATUS || $?

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
    EXIT_STATUS=$EXIT_STATUS || $?
  fi
fi


exit $EXIT_STATUS