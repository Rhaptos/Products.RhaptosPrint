#
# Makefile to control module PDF generation.
# 
# Author: Brent Hendricks and Chuck Bearden
# (C) 2005-2009 Rice University
# 
# This software is subject to the provisions of the GNU Lesser General
# Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
#
PYTHON = /usr/bin/env python2.4
PRINT_DIR = /opt/printing
HOST = http://localhost:8080
VERSION = latest
PROJECT_NAME = The Enterprise Rhaptos Project
PROJECT_SHORT_NAME = Rhaptos


.SECONDARY: 

clear: clean
	rm *.rdf
	rm -r *.imgs
	rm *.mxt

clean:
	rm *.aux *.bbl *.bib *.blg *.log *.mth *.pdf *.sym *.tex *.tex1 *.tex2 *.tex3 *.tmp1 *.tmp2 *.tmp3 *.tmp4

%.pdf: %.tex %.bib
	-pdflatex --interaction batchmode -shell-escape $<
	-bibtex $*
	-pdflatex --interaction batchmode -shell-escape $<
	-pdflatex --interaction batchmode -shell-escape $<

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
	xsltproc -o $@ --stringparam debug-mode '0' --stringparam 'CNX_DISPLAY_HOSTNAME' $(HOST) --stringparam PROJECT_NAME '$(PROJECT_NAME)' --stringparam PROJECT_SHORT_NAME '$(PROJECT_SHORT_NAME)' $(PRINT_DIR)/latex/tolatex.xsl $< 

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

%.tmp1: %.mxt
	xsltproc -o $@ $(PRINT_DIR)/common/indent_ident.xsl $<

%.mxt:
	wget -O $@ $(HOST)/content/$*/$(VERSION)/module_export_template
