#!/bin/sh

COL_PATH=$1

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

EXIT_STATUS=0

declare -x FOP_OPTS=-Xmx14000M # FOP Needs a lot of memory (4+Gb for Elementary Algebra)
DOCBOOK=$COL_PATH/collection.dbk
DOCBOOK2=$COL_PATH/collection.cleaned.dbk
UNALIGNED=$COL_PATH/collection.fo
FO=collection.aligned.fo
PDF=collection.pdf

XSLTPROC="xsltproc --param cnx.output.fop 1"
FOP="sh $ROOT/fop/fop -c $ROOT/lib/fop.xconf"

# XSL files
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
DOCBOOK2FO_XSL=$ROOT/xsl/dbk2fo.xsl
ALIGN_XSL=$ROOT/xsl/fo-align-math.xsl


$XSLTPROC --xinclude -o $DOCBOOK2 $DOCBOOK_CLEANUP_XSL $DOCBOOK
EXIT_STATUS=$EXIT_STATUS || $?

time $XSLTPROC -o $UNALIGNED $DOCBOOK2FO_XSL $DOCBOOK2
EXIT_STATUS=$EXIT_STATUS || $?

$XSLTPROC -o $COL_PATH/$FO $ALIGN_XSL $UNALIGNED
EXIT_STATUS=$EXIT_STATUS || $?

# Change to the collection dir so the relative paths to images work
cd $COL_PATH
time $FOP $FO $PDF
EXIT_STATUS=$EXIT_STATUS || $?

cd $ROOT

exit $EXIT_STATUS
