These are scripts to run the PDF generation on a hadoop cluster ( http://hadoop.apache.org ).
Specifically, we use the hadoop streaming API.
I run them on all modules in the repository to find out exactly how many things aren't implemented yet (from error messages)
and then prioritize what to implement.

The scripts can be run locally without hadoop using the following command line.
You will need a directory ($COL_PATH) with the following structure (same as a complete zip):
  [module-id]/index.cnxml

To test this out locally (without hadoop):
{{{
ls $COL_PATH | xargs -L 1 bash ./hadoop/util-aggregate-stderr.sh bash ./scripts/module2docbook.sh $COL_PATH
}}}


The error messages that are generated can be aggregated by creating a params.txt in the current directory
and placing the following lines in it (these are parameters to the logging xslt):
{{{
cnx.log.onlyaggregate yes
}}}


To run them on hadoop, one will need to run the create-cnx.pdfgen.jar.sh file first. 