#!/bin/sh

WORKING_DIR=$1
ID=$2

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

COLLXML=$WORKING_DIR/collection.xml
PARAMS=$WORKING_DIR/_params.txt
COLLXML_DERIVED_PRE=$WORKING_DIR/collection.derived.pre.xml
COLLXML_DERIVED_POST=$WORKING_DIR/collection.derived.post.xml
DOCBOOK=$WORKING_DIR/collection.dbk

XSLTPROC="xsltproc"
COLLXML_PARAMS=$ROOT/xsl/collxml-params.xsl
COLLXML_INCLUDE_DERIVED_FROM_XSL=$ROOT/xsl/collxml-derived-from.xsl
COLLXML_INCLUDE_DERIVED_FROM_CLEANUP_XSL=$ROOT/xsl/collxml-derived-from-cleanup.xsl
COLLXML2DOCBOOK_XSL=$ROOT/xsl/collxml2dbk.xsl
MODULE2DOCBOOK=$ROOT/scripts/module2dbk.sh

EXIT_STATUS=0

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

# Clean up the md:derived-from
$XSLTPROC --xinclude -o $COLLXML_DERIVED_POST $COLLXML_INCLUDE_DERIVED_FROM_CLEANUP_XSL $COLLXML_DERIVED_PRE
EXIT_STATUS=$EXIT_STATUS || $?

# Clean up the md:derived-from
$XSLTPROC -o $DOCBOOK $COLLXML2DOCBOOK_XSL $COLLXML_DERIVED_POST
EXIT_STATUS=$EXIT_STATUS || $?

# For each module, generate a docbook file
for MODULE in `ls $WORKING_DIR`
do
  if [ -d $WORKING_DIR/$MODULE ];
  then
    bash $MODULE2DOCBOOK $WORKING_DIR/$MODULE $MODULE
    EXIT_STATUS=$EXIT_STATUS || $?
  fi
done

exit $EXIT_STATUS