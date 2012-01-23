#!/bin/bash

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd`

LOG=$ROOT/all-collections.log
DEST=/home/schatz/public_html/cnx.pdfgen/epub

[ -s $LOG ] && mv $LOG $LOG.old

# Generate the tests epub
(bash $ROOT/scripts/module2epub.sh $ROOT/tests "" $DEST/tests.epub.zip 2>&1) >> $LOG
mv $DEST/tests.epub.zip $DEST/tests.epub


for F in `cd _collections; find -name "col*_latest.zip" | sort -r`
do
  FNAME=`basename $F`
  LEN=`expr length $F`
  LEN=$((LEN - 4))
  FPATH=${F:0:$LEN}
  DEST_NAME=$DEST/$FPATH

  TEMPDIR=`mktemp -d epubgen-$FNAME-XX`

  # Some zip files have multiple copies of the same file. Send it "A" for All
  echo "A" | unzip -q -d $TEMPDIR _collections/$F
  DIR=`ls $TEMPDIR`
  DIR=$TEMPDIR/$DIR

  # Notify users on the website that something is regenerating an epub
  touch $DEST/$FNAME.regenerating

  (bash $ROOT/scripts/module2epub.sh $DIR "" $DEST_NAME.epub.zip 2>&1) >> $LOG
  rm -rf $TEMPDIR

  mv $DEST_NAME.epub.zip $DEST_NAME.epub

  # Clear the flag
  rm $DEST/$FNAME.regenerating
done

