#! /bin/bash

# A helper script that starts up hadoop and runs the cnx2docbook conversion, 
#   aggregating errors for prioritizing.

# Note: you'll need to put a zip of all modules in beforehand (named data.jar)


HADOOP_PATH=/tmp/hadoop-0.20.1
INPUT=input.txt


SCRIPT_FILE=./hadoop/util-aggregate-stderr.sh
# Note: the mapper line assumes the script file is in the current dir
MAPPER="xargs -L 1 bash ./util-aggregate-stderr.sh bash cnx.pdfgen/scripts/module2docbook.sh ./data"

PDFGEN_JAR_FILE=./cnx.pdfgen.jar

HDFS_IN=input
HDFS_OUT=output
HDFS_PDFGEN=cnx.pdfgen.jar
HADOOP=$HADOOP_PATH/bin/hadoop

# Set the input
$HADOOP fs -rmr $HDFS_IN
$HADOOP fs -rmr $HDFS_OUT
$HADOOP fs -put $INPUT $HDFS_IN

$HADOOP fs -rmr $HDFS_PDFGEN
$HADOOP fs -put $PDFGEN_JAR_FILE $HDFS_PDFGEN

# Actually run hadoop on the modules
$HADOOP jar $HADOOP_PATH/contrib/streaming/hadoop-*-streaming.jar \
 -input $HDFS_IN -output $HDFS_OUT \
 -file $SCRIPT_FILE \
 -cacheArchive "data.jar#data" \
 -cacheArchive "$HDFS_PDFGEN#cnx.pdfgen" \
 -mapper "$MAPPER" \
 -reducer aggregate \
 -jobconf stream.map.output.field.separator="|" \
 -jobconf stream.reduce.output.field.separator="|" \
 -jobconf mapred.reduce.tasks=20 \
 -jobconf mapred.map.tasks=1000


# Spit out the results!
$HADOOP fs -cat $HDFS_OUT/part-*
