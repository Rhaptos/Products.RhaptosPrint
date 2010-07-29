#!/bin/bash

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
CNXML_UPGRADED=$WORKING_DIR/index_auto_upgrade.cnxml
CNXML1=$WORKING_DIR/_cnxml1.xml
CNXML2=$WORKING_DIR/_cnxml2.xml
CNXML3=$WORKING_DIR/_cnxml3.xml
CNXML4=$WORKING_DIR/_cnxml4.xml
CNXML5=$WORKING_DIR/_cnxml5.xml
CNXML6=$WORKING_DIR/_cnxml6.xml
DERIVED_PRE=$WORKING_DIR/_cnxml7.derived.pre.xml
DERIVED_POST=$WORKING_DIR/_cnxml7.derived.post.xml
DOCBOOK_INCLUDED=$WORKING_DIR/index.included.dbk # Important. Used in collxml2docbook xinclude
DOCBOOK=$WORKING_DIR/index.dbk # Important. Used in module2epub
DOCBOOK1=$WORKING_DIR/_index1.dbk
DOCBOOK2=$WORKING_DIR/_index2.dbk
DOCBOOK_SVG=$WORKING_DIR/_index.svg.dbk
SVG2PNG_FILES_LIST=$WORKING_DIR/_svg2png-list.txt
VALID=$WORKING_DIR/_valid.dbk
# Custom collection-level params (how to convert content mathml)
PARAMS=$WORKING_DIR/../_params.txt

#XSLT files
UPGRADE_FIVE_XSL=$ROOT/xsl/upgrade-cnxml05to06.xsl
UPGRADE_SIX_XSL=$ROOT/xsl/upgrade-cnxml06to07.xsl
CLEANUP_XSL=$ROOT/xsl/cnxml-clean.xsl
CLEANUP2_XSL=$ROOT/xsl/cnxml-clean-math.xsl
SIMPLIFY_MATHML_XSL=$ROOT/xsl/cnxml-clean-math-simplify.xsl
CNXML2DOCBOOK_XSL=$ROOT/xsl/cnxml2dbk.xsl
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean.xsl
DOCBOOK_VALIDATION_XSL=$ROOT/xsl/dbk-clean-for-validation.xsl
MATH2SVG_XSL=$ROOT/xslt2/math2svg-in-docbook.xsl
SVG2PNG_FILES_XSL=$ROOT/xsl/dbk-svg2png.xsl
DOCBOOK_BOOK_XSL=$ROOT/xsl/moduledbk2book.xsl
INCLUDE_DERIVED_FROM_XSL=$ROOT/xsl/collxml-derived-from.xsl
INCLUDE_DERIVED_FROM_CLEANUP_XSL=$ROOT/xsl/collxml-derived-from-cleanup.xsl

EXIT_STATUS=0

# remove all the temp files first so we don't accidentally use old ones
[ -s $CNXML1 ] && rm $CNXML1
[ -s $CNXML2 ] && rm $CNXML2
[ -s $CNXML3 ] && rm $CNXML3
[ -s $CNXML4 ] && rm $CNXML4
[ -s $CNXML5 ] && rm $CNXML5
[ -s $CNXML6 ] && rm $CNXML6
[ -s $DERIVED_PRE ] && rm $DERIVED_PRE
[ -s $DERIVED_POST ] && rm $DERIVED_POST
[ -s $DOCBOOK_INCLUDED ] && rm $DOCBOOK_INCLUDED
[ -s $DOCBOOK ] && rm $DOCBOOK
[ -s $DOCBOOK1 ] && rm $DOCBOOK1
[ -s $DOCBOOK2 ] && rm $DOCBOOK2
[ -s $DOCBOOK_SVG ] && rm $DOCBOOK_SVG
[ -s $SVG2PNG_FILES_LIST ] && rm $SVG2PNG_FILES_LIST

# Load up the custom collection params to xsltproc:
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
    echo "LOG: ERROR: Invalid cnxml doc" 1>&2
    cat $WORKING_DIR/__err.txt 1>&2
      exit 1
  fi
  mv $CNXML_NEW $CNXML
fi
#rm $WORKING_DIR/__err.txt


if [ -s $CNXML_UPGRADED ]; then
  cp $CNXML_UPGRADED $CNXML2
else
  echo "LOG: DEBUG: index_auto_upgraded.cnxml not found! Upgrading index.cnxml" 1>&2
  if [ ! -s $CNXML ]; then
    echo "LOG: ERROR: index.cnxml not found! Cannot convert" 1>&2
    exit 1
  fi

  echo "LOG: DEBUG: Upgrading 0.5 to 0.6" 1>&2
  # Upgrade from 0.5 to 0.6
  $XSLTPROC -o $CNXML1 $UPGRADE_FIVE_XSL $CNXML
  if [ $? != 0 ]; then
    cp $CNXML $CNXML1
  fi

  echo "LOG: DEBUG: Upgrading 0.5 to 0.6" 1>&2
  # Upgrade from 0.6 to 0.7
  $XSLTPROC -o $CNXML2 $UPGRADE_SIX_XSL $CNXML1
  if [ $? != 0 ]; then
    cp $CNXML1 $CNXML2
  fi
fi

$XSLTPROC -o $CNXML3 $CLEANUP_XSL $CNXML2
EXIT_STATUS=$EXIT_STATUS || $?

$XSLTPROC -o $CNXML4 $CLEANUP2_XSL $CNXML3
EXIT_STATUS=$EXIT_STATUS || $?
# Have to run the cleanup twice because we remove empty mml:mo,
# then remove mml:munder with only 1 child.
# See m21903
$XSLTPROC -o $CNXML5 $CLEANUP2_XSL $CNXML4
EXIT_STATUS=$EXIT_STATUS || $?

# Convert "simple" MathML to cnxml
$XSLTPROC -o $CNXML6 $SIMPLIFY_MATHML_XSL $CNXML5
EXIT_STATUS=$EXIT_STATUS || $?

# If the module has a md:derived-from, include it
$XSLTPROC -o $DERIVED_PRE $INCLUDE_DERIVED_FROM_XSL $CNXML6
EXIT_STATUS=$EXIT_STATUS || $?

# Clean up the md:derived-from
$XSLTPROC --xinclude -o $DERIVED_POST $INCLUDE_DERIVED_FROM_CLEANUP_XSL $DERIVED_PRE
EXIT_STATUS=$EXIT_STATUS || $?

# Convert to docbook
$XSLTPROC -o $DOCBOOK1 $CNXML2DOCBOOK_XSL $DERIVED_POST
EXIT_STATUS=$EXIT_STATUS || $?

# Convert MathML to SVG
$SAXON -s:$DOCBOOK1 -xsl:$MATH2SVG_XSL -o:$DOCBOOK2
# If there is an error, just use the original file
MATH2SVG_ERROR=$?
EXIT_STATUS=$EXIT_STATUS || $MATH2SVG_ERROR

if [ $MATH2SVG_ERROR -ne 0 ]; then mv $DOCBOOK1 $DOCBOOK2; fi
#if [ $MATH2SVG_ERROR -eq 0 ]; then 
#  rm $CNXML1
#  rm $CNXML_UPGRADED
#  rm $CNXML3
#  rm $DOCBOOK1
#fi

$XSLTPROC -o $DOCBOOK_SVG $DOCBOOK_CLEANUP_XSL $DOCBOOK2
EXIT_STATUS=$EXIT_STATUS || $?
#if [ $MATH2SVG_ERROR -eq 0 ]; then 
#  rm $DOCBOOK2
#fi

# Create a list of files to convert from svg to png
$XSLTPROC -o $DOCBOOK_INCLUDED $SVG2PNG_FILES_XSL $DOCBOOK_SVG 2> $SVG2PNG_FILES_LIST
EXIT_STATUS=$EXIT_STATUS || $?

# Create a standalone db:book file for the module
$XSLTPROC -o $DOCBOOK $DOCBOOK_BOOK_XSL $DOCBOOK_INCLUDED
EXIT_STATUS=$EXIT_STATUS || $?

# Convert the files
for ID_AND_EXT in `cat $SVG2PNG_FILES_LIST`
do
  ID=${ID_AND_EXT%%|*}
  EXT=${ID_AND_EXT#*|}
  if [ -s $WORKING_DIR/$ID.svg ]; then
      echo "LOG: DEBUG: Converting-SVG $ID to $EXT"
      # For Macs, use inkscape
      if [ -e /Applications/Inkscape.app/Contents/Resources/bin/inkscape ]; then
        # Default DPI is 90, so double it
        DPI=180
        (/Applications/Inkscape.app/Contents/Resources/bin/inkscape $WORKING_DIR/$ID.svg --export-$EXT=$WORKING_DIR/$ID.$EXT --export-dpi=180 2>&1) > $WORKING_DIR/__err.txt
        EXIT_STATUS=$EXIT_STATUS || $?
      else
        $CONVERT -density 100x100 $WORKING_DIR/$ID.svg $WORKING_DIR/$ID.$EXT
        EXIT_STATUS=$EXIT_STATUS || $?
      fi
  else
    # Print saner error messages.
    # For example, Adobe illustrator generates SVG files that are invalid XML.
    # Those parsing errors show up and are misinterpreted
    #   as SVG files that should be converted.
    echo "LOG: ERROR: Converting-SVG: SVG file not found: $ID"
    EXIT_STATUS=$EXIT_STATUS || 1
  fi
done

bash $ROOT/scripts/dbk2cover.sh $DOCBOOK

echo "LOG: DEBUG: Skipping Docbook Validation. Remove next line to enable"
exit $EXIT_STATUS

# Create a file to validate against
$XSLTPROC -o $VALID $DOCBOOK_VALIDATION_XSL $DOCBOOK
EXIT_STATUS=$EXIT_STATUS || $?

# Validate
$JING $SCHEMA $VALID # 1>&2 # send validation errors to stderr
RET=$?
if [ $RET -eq 0 ]; then rm $VALID; fi
if [ $RET -eq 0 ]; then echo "LOG: BUG: Validation Errors" 1>&2 ; fi

exit $EXIT_STATUS || $RET
