#!/bin/sh

WORKING_DIR=$1
ID=$2

SKIP_MODULE_CONVERSION=0

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

EXIT_STATUS=0

COLLXML=$WORKING_DIR/collection.xml
PARAMS=$WORKING_DIR/_params.txt
DOCBOOK=$WORKING_DIR/_collection1.dbk
DOCBOOK2=$WORKING_DIR/_collection2.normalized.dbk
DOCBOOK3=$WORKING_DIR/_collection3.dbk
DBK_FILE=$WORKING_DIR/collection.dbk

XSLTPROC="xsltproc"
COLLXML_PARAMS=$ROOT/xsl/collxml-params.xsl
COLLXML2DOCBOOK_XSL=$ROOT/xsl/collxml2dbk.xsl

DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
DOCBOOK_NORMALIZE_PATHS_XSL=$ROOT/xsl/dbk2epub-normalize-paths.xsl
DOCBOOK_NORMALIZE_GLOSSARY_XSL=$ROOT/xsl/dbk-clean-whole-remove-duplicate-glossentry.xsl

MODULE2DOCBOOK=$ROOT/scripts/module2dbk.sh

# remove all the temp files first so we don't accidentally use old ones
[ -s $DOCBOOK2 ] && rm $DOCBOOK2
[ -s $DOCBOOK3 ] && rm $DOCBOOK3
[ -s $DBK_FILE ] && rm $DBK_FILE


echo "LOG: INFO: ------------ Starting on $WORKING_DIR --------------"

# Pull out the custom params (mostly math-related) stored inside the collxml 
$XSLTPROC -o $PARAMS $COLLXML_PARAMS $COLLXML
EXIT_STATUS=$EXIT_STATUS || $?

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

# Convert to Docbook
$XSLTPROC -o $DOCBOOK $COLLXML2DOCBOOK_XSL $COLLXML
EXIT_STATUS=$EXIT_STATUS || $?



# For each module, generate a docbook file
if [ "$SKIP_MODULE_CONVERSION" = "0" ]; then
  for MODULE in `ls $WORKING_DIR`
  do
    if [ -d $WORKING_DIR/$MODULE ];
    then
      bash $MODULE2DOCBOOK $WORKING_DIR/$MODULE $MODULE $ID
      EXIT_STATUS=$EXIT_STATUS || $?
    fi
  done
else
  echo "LOG: INFO: Skipping module conversion"
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
bash $ROOT/scripts/dbk2cover.sh $DBK_FILE


exit $EXIT_STATUS
