#!/bin/sh

PATH=/usr/local/bin:/usr/bin:/bin
PRINT_DIR=/opt/printing
PRINT_MAKEFILE=course_print.mak.local
PRINT_MAKEPATH=${PRINT_DIR}/${PRINT_MAKEFILE}
REPOS_HOST='localhost:8080'
START_DIR=`/bin/pwd`
START_TIME=`date`
MASTER_LOG=${START_DIR}/print.log

echo "We started at $START_TIME"
for collId in $@; do
  mkdir $collId
  cd $collId
  cp $PRINT_MAKEPATH Makefile
#   wget -O ${collId}.rdf "http://${REPOS_HOST}/content/${collId}/latest/?format=rdf" >> ${START_DIR}/wget.log 2>&1
#   make -f $PRINT_MAKEFILE ${collId}.tex1 1>./make.log 2>&1 &
  make ${collId}.pdf 1>./make.log 2>&1
  T=`date`
#   echo "We finished ${collId}.tex1 at $T" >> $MASTER_LOG
#   echo "We finished ${collId}.tex1 at $T"
  echo "We finished ${collId}.pdf at $T" >> $MASTER_LOG
  echo "We finished ${collId}.pdf at $T"
  cd $START_DIR
done

# for collId in $@; do
#   cd $collId
#   make -f $PRINT_MAKEFILE ${collId}.pdf 1>>./make.log 2>&1
#   T=`date`
#   echo "We finished ${collId}.pdf (or not) at $T" >> $MASTER_LOG
#   echo "We finished ${collId}.pdf (or not) at $T"
#   cd $START_DIR
# done

FINISH_TIME=`date`
echo "We started at $START_TIME" >> $MASTER_LOG
echo "We started at $START_TIME"
echo "We finished at $FINISH_TIME" >> $MASTER_LOG
echo "We finished at $FINISH_TIME"
