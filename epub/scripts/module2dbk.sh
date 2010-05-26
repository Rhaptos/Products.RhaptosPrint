#!/bin/sh

WORKING_DIR=$1
ID=$2

echo "LOG: INFO: ------------ Working on $ID ------------"

# If XSLTPROC_ARGS is set (by say a hadoop job) then pass those through

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

SCHEMA=$ROOT/docbook-rng/docbook.rng
SAXON="java -jar $ROOT/lib/saxon9he.jar"
JING="java -jar $ROOT/lib/jing-20081028.jar"
# we use --xinclude because the XSLT attempts to load inline svg files
XSLTPROC="xsltproc --xinclude --stringparam cnx.module.id $ID $XSLTPROC_ARGS"
CONVERT="convert "

#Temporary files
CNXML=$WORKING_DIR/index.cnxml
CNXML1=$WORKING_DIR/_cnxml1.xml
CNXML2=$WORKING_DIR/_cnxml2.xml
CNXML3=$WORKING_DIR/_cnxml3.xml
CNXML4=$WORKING_DIR/_cnxml4.xml
DOCBOOK=$WORKING_DIR/index.dbk # Important. Used in collxml2docbook xinclude
DOCBOOK1=$WORKING_DIR/_index1.dbk
DOCBOOK2=$WORKING_DIR/_index2.dbk
DOCBOOK_SVG=$WORKING_DIR/_index.svg.dbk
SVG2PNG_FILES_LIST=$WORKING_DIR/_svg2png-list.txt
VALID=$WORKING_DIR/_valid.dbk

#XSLT files
CLEANUP_XSL=$ROOT/xsl/cnxml-clean.xsl
CLEANUP2_XSL=$ROOT/xsl/cnxml-clean-math.xsl
SIMPLIFY_MATHML_XSL=$ROOT/xsl/cnxml-clean-math-simplify.xsl
CNXML2DOCBOOK_XSL=$ROOT/xsl/cnxml2dbk.xsl
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean.xsl
DOCBOOK_VALIDATION_XSL=$ROOT/xsl/dbk-clean-for-validation.xsl
MATH2SVG_XSL=$ROOT/xslt2/math2svg-in-docbook.xsl
SVG2PNG_FILES_XSL=$ROOT/xsl/dbk-svg2png.xsl

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


# Just some code to filter what gets re-converted so all modules don't have to.
#GREP_FOUND=`grep "newline" $CNXML`
#if [ ".$GREP_FOUND" == "." ]; then exit 0; fi

# First check that the XML file is well-formed
#XMLVALIDATE="xmllint --nonet --noout --valid --relaxng /Users/schatz/Documents/workspace/cnxml-schema/cnxml.rng"
XMLVALIDATE="xmllint"
#$XMLVALIDATE $CNXML 2> /dev/null
#if [ $? -ne 0 ]; then exit 0; fi

# Skip validation by just replacing all entities with &amp;
#sed -i "" 's/&[a-zA-Z][a-zA-Z]*/\&amp/g' $CNXML
($XMLVALIDATE --nonet --noout $CNXML 2>&1) > $WORKING_DIR/__err.txt
if [ -s $WORKING_DIR/__err.txt ]; then 

  # Try again, but load the DTD this time (and replace the cnxml file)
  echo "Failed without DTD. Trying with DTD" 1>&2
  cat $WORKING_DIR/__err.txt
  CNXML_NEW=$CNXML.new.xml
  ($XMLVALIDATE --loaddtd --noent --dropdtd --output $CNXML_NEW $CNXML 2>&1) > $WORKING_DIR/__err.txt
  if [ -s $WORKING_DIR/__err.txt ]; then 
    echo "Invalid cnxml doc" 1>&2
      exit 1
  fi
  mv $CNXML_NEW $CNXML
fi
#rm $WORKING_DIR/__err.txt



$XSLTPROC -o $CNXML1 $CLEANUP_XSL $CNXML
EXIT_STATUS=$EXIT_STATUS || $?

$XSLTPROC -o $CNXML2 $CLEANUP2_XSL $CNXML1
EXIT_STATUS=$EXIT_STATUS || $?
# Have to run the cleanup twice because we remove empty mml:mo,
# then remove mml:munder with only 1 child.
# See m21903
$XSLTPROC -o $CNXML3 $CLEANUP2_XSL $CNXML2
EXIT_STATUS=$EXIT_STATUS || $?

# Convert "simple" MathML to cnxml
$XSLTPROC -o $CNXML4 $SIMPLIFY_MATHML_XSL $CNXML3
EXIT_STATUS=$EXIT_STATUS || $?

# Convert to docbook
$XSLTPROC -o $DOCBOOK1 $CNXML2DOCBOOK_XSL $CNXML4
EXIT_STATUS=$EXIT_STATUS || $?

# Convert MathML to SVG
$SAXON -s:$DOCBOOK1 -xsl:$MATH2SVG_XSL -o:$DOCBOOK2
# If there is an error, just use the original file
MATH2SVG_ERROR=$?
EXIT_STATUS=$EXIT_STATUS || $?ATH2SVG_ERROR

if [ $MATH2SVG_ERROR -ne 0 ]; then mv $DOCBOOK1 $DOCBOOK2; fi
#if [ $MATH2SVG_ERROR -eq 0 ]; then 
#  rm $CNXML1
#  rm $CNXML2
#  rm $CNXML3
#  rm $DOCBOOK1
#fi

$XSLTPROC -o $DOCBOOK_SVG $DOCBOOK_CLEANUP_XSL $DOCBOOK2
EXIT_STATUS=$EXIT_STATUS || $?
#if [ $MATH2SVG_ERROR -eq 0 ]; then 
#  rm $DOCBOOK2
#fi

# Create a list of files to convert from svg to png
$XSLTPROC -o $DOCBOOK $SVG2PNG_FILES_XSL $DOCBOOK_SVG 2> $SVG2PNG_FILES_LIST
EXIT_STATUS=$EXIT_STATUS || $?

# Convert the files
for ID in `cat $SVG2PNG_FILES_LIST`
do
  if [ -s $WORKING_DIR/$ID.png ]; then
    echo "LOG: INFO: Converting-SVG $ID to PNG skipping!"
  else
    echo "LOG: INFO: Converting-SVG $ID to PNG"
    # For Macs, use inkscape
    if [ -e /Applications/Inkscape.app/Contents/Resources/bin/inkscape ]; then
      (/Applications/Inkscape.app/Contents/Resources/bin/inkscape $WORKING_DIR/$ID.svg --export-png=$WORKING_DIR/$ID.png 2>&1) > $WORKING_DIR/__err.txt
      EXIT_STATUS=$EXIT_STATUS || $?
    else
      $CONVERT $WORKING_DIR/$ID.svg $WORKING_DIR/$ID.png
      EXIT_STATUS=$EXIT_STATUS || $?
    fi
  fi 
done


echo "LOG: INFO: Skipping Docbook Validation. Remove next line to enable"
exit $EXIT_STATUS

# Create a file to validate against
$XSLTPROC -o $VALID $DOCBOOK_VALIDATION_XSL $DOCBOOK
EXIT_STATUS=$EXIT_STATUS || $?

# Validate
$JING $SCHEMA $VALID # 1>&2 # send validation errors to stderr
RET=$?
if [ $RET -eq 0 ]; then rm $VALID; fi
if [ $RET -eq 0 ]; then echo "BUG: Validation Errors" 1>&2 ; fi

exit $EXIT_STATUS || $RET
