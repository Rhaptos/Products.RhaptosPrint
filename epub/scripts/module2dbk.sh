#!/bin/sh

COL_PATH=$1
MOD_NAME=$2
MOD_PATH=$COL_PATH/$MOD_NAME

echo "Working on $MOD_NAME"

# If XSLTPROC_ARGS is set (by say a hadoop job) then pass those through

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

SCHEMA=$ROOT/docbook-rng/docbook.rng
SAXON="java -jar $ROOT/lib/saxon9he.jar"
JING="java -jar $ROOT/lib/jing-20081028.jar"
# we use --xinclude because the XSLT attempts to load inline svg files
XSLTPROC="xsltproc --nonet --xinclude --stringparam cnx.module.id $MOD_NAME $XSLTPROC_ARGS"
CONVERT="convert "

#Temporary files
CNXML=$MOD_PATH/index.cnxml
CNXML1=$MOD_PATH/_cnxml1.xml
CNXML2=$MOD_PATH/_cnxml2.xml
CNXML3=$MOD_PATH/_cnxml3.xml
CNXML4=$MOD_PATH/_cnxml4.xml
DOCBOOK=$MOD_PATH/index.dbk # Important. Used in collxml2docbook xinclude
DOCBOOK1=$MOD_PATH/_index1.dbk
DOCBOOK2=$MOD_PATH/_index2.dbk
DOCBOOK_SVG=$MOD_PATH/_index.svg.dbk
SVG2PNG_FILES_LIST=$MOD_PATH/_svg2png-list.txt
VALID=$MOD_PATH/_valid.dbk

#XSLT files
CLEANUP_XSL=$ROOT/xsl/cnxml-clean.xsl
CLEANUP2_XSL=$ROOT/xsl/cnxml-clean-math.xsl
SIMPLIFY_MATHML_XSL=$ROOT/xsl/cnxml-clean-math-simplify.xsl
CNXML2DOCBOOK_XSL=$ROOT/xsl/cnxml2dbk.xsl
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean.xsl
DOCBOOK_VALIDATION_XSL=$ROOT/xsl/dbk-clean-for-validation.xsl
MATH2SVG_XSL=$ROOT/xslt2/math2svg-in-docbook.xsl
SVG2PNG_FILES_XSL=$ROOT/xsl/dbk-svg2png.xsl


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
($XMLVALIDATE --nonet --noout $CNXML 2>&1) > $MOD_PATH/__err.txt
if [ -s $MOD_PATH/__err.txt ]; then 

  # Try again, but load the DTD this time (and replace the cnxml file)
  echo "Failed without DTD. Trying with DTD" 1>&2
  cat $MOD_PATH/__err.txt
  CNXML_NEW=$CNXML.new.xml
  ($XMLVALIDATE --loaddtd --noent --dropdtd --output $CNXML_NEW $CNXML 2>&1) > $MOD_PATH/__err.txt
  if [ -s $MOD_PATH/__err.txt ]; then 
    echo "Invalid cnxml doc" 1>&2
      exit 1
  fi
  mv $CNXML_NEW $CNXML
fi
#rm $MOD_PATH/__err.txt



$XSLTPROC -o $CNXML1 $CLEANUP_XSL $CNXML
$XSLTPROC -o $CNXML2 $CLEANUP2_XSL $CNXML1
# Have to run the cleanup twice because we remove empty mml:mo,
# then remove mml:munder with only 1 child.
# See m21903
$XSLTPROC -o $CNXML3 $CLEANUP2_XSL $CNXML2

# Convert "simple" MathML to cnxml
$XSLTPROC -o $CNXML4 $SIMPLIFY_MATHML_XSL $CNXML3

# Convert to docbook
$XSLTPROC -o $DOCBOOK1 $CNXML2DOCBOOK_XSL $CNXML4

# Convert MathML to SVG
$SAXON -s:$DOCBOOK1 -xsl:$MATH2SVG_XSL -o:$DOCBOOK2
# If there is an error, just use the original file
MATH2SVG_ERROR=$?
if [ $MATH2SVG_ERROR -ne 0 ]; then mv $DOCBOOK1 $DOCBOOK2; fi
#if [ $MATH2SVG_ERROR -eq 0 ]; then 
#  rm $CNXML1
#  rm $CNXML2
#  rm $CNXML3
#  rm $DOCBOOK1
#fi

$XSLTPROC -o $DOCBOOK_SVG $DOCBOOK_CLEANUP_XSL $DOCBOOK2
#if [ $MATH2SVG_ERROR -eq 0 ]; then 
#  rm $DOCBOOK2
#fi

# Create a list of files to convert from svg to png
$XSLTPROC -o $DOCBOOK $SVG2PNG_FILES_XSL $DOCBOOK_SVG 2> $SVG2PNG_FILES_LIST

# Convert the files
for ID in `cat $SVG2PNG_FILES_LIST`
do
  if [ -s $MOD_PATH/$ID.png ]; then
    echo "Converting-SVG $ID to PNG skipping!"
  else
    echo "Converting-SVG $ID to PNG"
    $CONVERT $MOD_PATH/$ID.svg $MOD_PATH/$ID.png
    (/Applications/Inkscape.app/Contents/Resources/bin/inkscape $MOD_PATH/$ID.svg --export-png=$MOD_PATH/$ID.png 2>&1) > $MOD_PATH/__err.txt
  fi 
done


echo "Skipping Docbook Validation. Remove next line to enable"
exit $MATH2SVG_ERROR

# Create a file to validate against
$XSLTPROC -o $VALID $DOCBOOK_VALIDATION_XSL $DOCBOOK

# Validate
$JING $SCHEMA $VALID # 1>&2 # send validation errors to stderr
RET=$?
if [ $RET -eq 0 ]; then rm $VALID; fi
if [ $RET -eq 0 ]; then echo "BUG: Validation Errors" 1>&2 ; fi

exit $MATH2SVG_ERROR || $RET
