Prerequisites:

 * Install Java
 * Download Apache FOP (0.95+) from http://xmlgraphics.apache.org/fop/download.html#binary
 * Download the Docbook XSL-ns (1.75.2+) from http://sourceforge.net/projects/docbook/files/ (Remember to get the xsl-ns one!)
                            (http://sourceforge.net/projects/docbook/files/docbook-xsl-ns/1.75.2/docbook-xsl-ns-1.75.2.zip/download)
 * Download the Docbook RelaxNG schema (4.3+) from http://docbook.org/rng/


Download a collection zip from http://cnx.org . Examples:
 * Collaborative Statistics: http://cnx.org/content/col10522/1.36/complete
 * Elementary Algebra: http://cnx.org/content/col10614/1.3/complete
 * Music Theory : http://cnx.org/content/col10363/1.3/complete

We'll need to unzip these into the correct directories:
 * Unzip the Docbook XSL file into "docbook-xsl" (./docbook-xsl/fo/docbook.xsl should exist)
 * Unzip Apache FOP into "fop" (./fop/build should exist)
 * Unzip the collection zip into the project root (./col*/collection.xml should exist)



Now, we'll need to install/configure some fonts for Apache FOP (mostly the Math fonts).

Install the STIXGeneral and STIXSize1 fonts from the fonts directory into your OS
  (getting this right is a pain. see the tests dir to make sure FOP and Batik can find the fonts)
In Linux:
$ mkdir ~/.fonts
$ cp fonts/stix/*.ttf ~/.fonts


Note: fop needs to know about the STIX fonts, so lib/fop.xconf is customized


Then, there are a couple of files that need patching:
docbook-xsl/fo/graphics.xsl will need submitted-patches/inline-svg.diff


We're ready to do some converting!

To generate an epub file, you will need (due to a bug in docbook) to run the following line:
$ echo 'cnx.output "html"' >> params.txt


First, we need to convert the collection and modules into individual docbook files:
Run the following line (where $COLLECTION_DIR is the directory you unzipped the collection):
  ./scripts/collection2dbk.sh $COLLECTION_DIR

For details on the output, check out the accompanying txt file.

You may need to massage the collection.dbk file. Here are some pointers.
You won't know the file is broken until the final stage of PDF generation.
 * xi:include elements must be children of db:preface, db:chapter, db:appendix, etc. They can't exist directly under db:book
 * db:appendix cannot contain db:chapter elements. Either change them to db:section or make multiple db:appendix


Now, we can do the most time-consuming parts: generate the XSL-FO file and finally the PDF.

Aside: You can customize the docbook2fo step by creating a params.txt file in the current directory and having space-separated params which are defined in http://docbook.sourceforge.net/release/xsl/current/doc/fo/index.html 

Run the following script (It will take a while. If you want, you can remove all exercises by adding <xsl:template match="c:exercise"/> to ./xsl/cnxml-clean.xsl)
  ./scripts/collectiondbk2pdf.sh $COLLECTION_DIR

Done! Now you should have a PDF!
