#!/bin/sh

WORKING_DIR=$1
ID=$2

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

COLLXML=$WORKING_DIR/collection.xml
DOCBOOK=$WORKING_DIR/collection.dbk

XSLTPROC="xsltproc"
COLLXML2DOCBOOK_XSL=$ROOT/xsl/collxml2dbk.xsl
MODULE2DOCBOOK=$ROOT/scripts/module2dbk.sh

EXIT_STATUS=0

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

echo "LOG: INFO: ------------ Starting on $WORKING_DIR --------------"

# Create the Docbook for the collection
$XSLTPROC -o $DOCBOOK $COLLXML2DOCBOOK_XSL $COLLXML
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