#
# Makefile to control collection PDF generation.
# 
# Author: Brent Hendricks and Chuck Bearden
# (C) 2005-2009 Rice University
# 
# This software is subject to the provisions of the GNU Lesser General
# Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
#
PYTHON = /usr/bin/python
PRINT_DIR = /opt/printing
HOST = http://localhost:8080
COLLECTION_VERSION = latest
PROJECT_NAME = The Enterprise Rhaptos Project
PROJECT_SHORT_NAME = Rhaptos


.SECONDARY: 

clear: clean
	rm *.rdf
	rm -r *.imgs

clean:
	rm *.aux *.bbl *.bib *.blg *.log *.mth *.pdf *.sym *.tex *.tex1 *.tex2 *.tex3 *.tmp1 *.tmp2 *.tmp3 *.tmp4 *.zip

%.pdf: %.tex %.bib
	-pdflatex --interaction batchmode -shell-escape $<
	-bibtex $*
	-pdflatex --interaction batchmode -shell-escape $<
	pdflatex --interaction batchmode -shell-escape $<

%.zip: %.tex %.bib
	echo "#!/bin/sh" > build-pdf.sh
	echo "pdflatex --interaction batchmode -shell-escape $<" >> build-pdf.sh
	echo "bibtex $*" >> build-pdf.sh
	echo "pdflatex --interaction batchmode -shell-escape $<" >> build-pdf.sh
	echo "pdflatex --interaction batchmode -shell-escape $<" >> build-pdf.sh
	chmod 775 build-pdf.sh
	zip $@ $^ $*.imgs/* build-pdf.sh

%.tex: %.tex3
	$(PYTHON) $(PRINT_DIR)/subfigurefix.py -d $*.imgs -p $(PRINT_DIR) $< > $@; 

%.tex3: %.tex2
	if test -f $*.width; then \
	    $(PYTHON) $(PRINT_DIR)/imagefix -d $*.imgs -s tex -p $(PRINT_DIR) -w $*.width $< > $@; \
	else  \
	    $(PYTHON) $(PRINT_DIR)/imagefix -d $*.imgs -s tex -p $(PRINT_DIR) $< > $@; \
	fi

%.tex2: %.tex1
	$(PYTHON) $(PRINT_DIR)/replace.py $(PRINT_DIR)/latex/unicodechanges < $< > $@

%.tex1: %.mth
	xsltproc -o $@ --stringparam debug-mode '0' --stringparam 'CNX_DISPLAY_HOSTNAME' $(HOST)  --stringparam PROJECT_NAME '$(PROJECT_NAME)' --stringparam PROJECT_SHORT_NAME '$(PROJECT_SHORT_NAME)' $(PRINT_DIR)/latex/tolatex.xsl $< 

%.mth: %.sym
	xsltproc -o $@ $(PRINT_DIR)/latex/mathml.xsl $< 

%.sym: %.tmp4
	$(PYTHON) $(PRINT_DIR)/replace.py $(PRINT_DIR)/latex/latexspecialchars < $< > $@

%.tmp4: %.tmp3
	xsltproc -o $@ $(PRINT_DIR)/common/numbering.xsl $< 

%.tmp3: %.tmp2
	xsltproc -o $@ $(PRINT_DIR)/common/solutions.xsl $<

%.tmp2: %.tmp1
	xsltproc -o $@ $(PRINT_DIR)/common/getreferenced.xsl $< 

%.bib: %.tmp1
	touch $@
	xsltproc -o $@ $(PRINT_DIR)/latex/bibtexml2bibtex.xsl $< 
	cp $@ index.bib

%.tmp1: %.rdf
	xsltproc --nodtdattr -o $@ $(PRINT_DIR)/common/assemble.xsl $< 

%.rdf:
	wget -O $@ $(HOST)/content/$*/$(COLLECTION_VERSION)?format=rdf
