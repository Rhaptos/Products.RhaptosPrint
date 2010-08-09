#!/bin/sh

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in hadoop/

PATH_TO_PDFGEN=$ROOT/../cnx.pdfgen

# Done this way so we don't jar up collections that may be lingering in the project
jar -cf cnx.pdfgen.jar \
  -C $PATH_TO_PDFGEN docbook-rng \
  -C $PATH_TO_PDFGEN docbook-xsl \
  -C $PATH_TO_PDFGEN lib \
  -C $PATH_TO_PDFGEN scripts \
  -C $PATH_TO_PDFGEN xsl \
  -C $PATH_TO_PDFGEN xslt2 \

# Skip fop stuff for now.
#  -C $PATH_TO_PDFGEN fonts \
#  -C $PATH_TO_PDFGEN fop \
