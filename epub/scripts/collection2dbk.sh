#!/bin/sh

COL_PATH=$1

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

COLLXML=$COL_PATH/collection.xml
DOCBOOK=$COL_PATH/collection.dbk

XSLTPROC="xsltproc --nonet"
COLLXML2DOCBOOK_XSL=$ROOT/xsl/collxml2dbk.xsl
MODULE2DOCBOOK=$ROOT/scripts/module2dbk.sh


# Load up the custom params to xsltproc:
if [ -s params.txt ]; then
    echo "Using custom params in params.txt for xsltproc."
    # cat params.txt
    OLD_IFS=$IFS
    IFS="
"
    XSLTPROC_ARGS=""
    for ARG in `cat params.txt`; do
      XSLTPROC_ARGS="$XSLTPROC_ARGS --param $ARG"
    done
    IFS=$OLD_IFS
    XSLTPROC="$XSLTPROC $XSLTPROC_ARGS"
fi



# If the docbook for the collection doesn't exist yet, create it
if [ ! -e $DOCBOOK ]; 
then 
  $XSLTPROC -o $DOCBOOK $COLLXML2DOCBOOK_XSL $COLLXML
fi

# For each module, generate a docbook file
for MODULE in `ls $COL_PATH`
do
  if [ -d $COL_PATH/$MODULE ];
  then
    bash $MODULE2DOCBOOK $COL_PATH $MODULE
  fi
done
