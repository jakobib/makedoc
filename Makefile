## parts from makespec

# path of this file
MAKEDOC = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifeq ($(words $(MAKEFILE_LIST)),1)
	NAME	= makedoc
	GITHUB	= https://github.com/jakobib/makedoc/
	SOURCE	= README.md
	TITLE	= Creating documents with makedoc
	AUTHOR	= Jakob Voß
endif

include $(MAKEDOC)/executables.make
include $(MAKEDOC)/configuration.make

########################################################################

COMBINED = $(NAME)-tmp.md

.SUFFIXES:
.SUFFIXES: .md .html .pdf .tmp
.PHONY: info clean

KEYWORDS := $(shell perl -ne '/keywords\s*=(.*)/ && print $$1' metadata.ini 2>/dev/null)

# combine metadata as arguments to templates (FIXME: escaping)
V_METADATA=-V abstract:'$(ABSTRACT)' -V keywords:'$(KEYWORDS)'

# which template to use
TEMPLATE=default

# create HTML paper
HTML_CSS      = $(MAKEDOC)/templates/$(TEMPLATE).css
HTML_TEMPLATE = $(MAKEDOC)/templates/$(TEMPLATE).html

SLIDES_PDF_TEMPLATE = $(MAKEDOC)/templates/$(TEMPLATE)-slides.tex
V_SLIDES_PDF=

info:
	@echo NAME='$(NAME)'
	@echo GITHUB='$(GITHUB)'
	@echo SOURCE='$(SOURCE)'
	@echo TITLE='$(TITLE)'
	@echo AUTHOR='$(AUTHOR)'

html: $(NAME).html

$(NAME).md: $(SOURCE)
	@cp $< $@ 

%.html: %.tmp
	@$(PANDOC) -N $< -o $@ --template $(HTML_TEMPLATE) --css $(HTML_CSS) $(V_METADATA)\
		--smart $(BIBARGS) -t html5
	@echo created $@

%.odt: %.tmp
	@$(PANDOC) -N $< -o $@ $(V_METADATA)\
		--smart $(BIBARGS) -t odt
	@echo created $@

%.tmp: %.md
	@echo "% $(TITLE)" > $@
	@echo "% $(AUTHOR)" >> $@
	@echo "% $(DATE)" >> $@
	@echo "" >> $@
	@cat $< >> $@
	# TODO: replace document variables

slides.pdf: slides.tmp
	@$(PANDOC) $< --slide-level 2 $(TOC) -t beamer -o tmp.tex --template $(SLIDES_PDF_TEMPLATE) \
		$(V_METADATA) $(V_SLIDES_PDF) $(BIBARGS) $(BIBLATEX)
	@perl -p -i -e 's/^\\caption{}//' tmp.tex
	@$(XELATEX) tmp.tex > /dev/null
	@$(XELATEX) tmp.tex > /dev/null
	@mv tmp.pdf $@
#	@rm -f tmp.*

slides.html: slides.tmp
	@$(PANDOC) -t slidy --self-contained -s $< -o $@ $(BIBARGS)

paper.tex: paper.tmp
	@$(PANDOC) -t latex -o paper.tex $< \
		--template $(MAKEDOC)/templates/paper.tex --smart -V "mainfont=DejaVu Serif" \
		$(BIBARGS) $(BIBLATEX)

paper.pdf: paper.tex
	@rm -f *.aux *.log *.out *.bbl *.blg *.bcf
	@$(XELATEX) --halt-on-error paper.tex > /dev/null
	@$(BIBER) paper
	@$(XELATEX) --halt-on-error paper.tex > /dev/null

handout.pdf: handout.tmp
	@$(PANDOC) -o $@ $< $(BIBARGS)

clean:
	@rm -f *.tex *.aux *.log *.out *.bbl *.blg *.bcf *.run.xml *.bak tmp.* *.tmp

TMP := normalize.tmp

normalize: *.md
	@for f in `ls *.md`; do \
		$(PANDOC) --normalize -t markdown $$f > $(TMP); \
		if `diff $$f $(TMP) > /dev/null`; then \
			rm $(TMP); \
		else \
			cp -f "$$f" "$$f.bak"; \
			mv $(TMP) "$$f"; \
			echo "$$f - normalized"; \
		fi \
	done 
