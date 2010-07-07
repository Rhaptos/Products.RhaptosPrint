#!/bin/sh

COL_PATH=$1

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

declare -x FOP_OPTS=-Xmx14000M # FOP Needs a lot of memory (4+Gb for Elementary Algebra)
DOCBOOK=$COL_PATH/collection.dbk
DOCBOOK2=$COL_PATH/collection.cleaned.dbk
UNALIGNED=$COL_PATH/collection.fo
FO=collection.aligned.fo
PDF=collection.pdf

XSLTPROC="xsltproc"
FOP="sh $ROOT/fop/fop -c $ROOT/lib/fop.xconf"

# XSL files
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
DOCBOOK2FO_XSL=$ROOT/xsl/dbk2fo.xsl
ALIGN_XSL=$ROOT/xsl/fo-align-math.xsl


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

$XSLTPROC --xinclude -o $DOCBOOK2 $DOCBOOK_CLEANUP_XSL $DOCBOOK

time $XSLTPROC -o $UNALIGNED $DOCBOOK2FO_XSL $DOCBOOK2

$XSLTPROC -o $COL_PATH/$FO $ALIGN_XSL $UNALIGNED

# Change to the collection dir so the relative paths to images work
cd $COL_PATH
time $FOP $FO $PDF
cd $ROOT
