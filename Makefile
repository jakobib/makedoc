## parts from makespec

DIRNAME = $(shell basename $(CURDIR))
MAKEDOC = $(wildcard makedoc)

ifeq ($(DIRNAME),makedoc)
	ifeq ($(MAKEDOC),)
		NAME = makedoc
		GITHUB = https://github.com/jakobib/makedoc/
		SOURCE = README.md
		MAKEDOC = .
		TITLE = Creating documents with makedoc
		AUTHOR = Jakob Voß
	endif
endif

ifeq ($(NAME),)
	NAME = $(DIRNAME)
endif

ifeq ($(ABSTRACT)$(ABSTRACT_FROM),)
	ifneq ($(wildcard abstract.md),)
		ABSTRACT_FROM = abstract.md
    endif
endif

ifeq ($(ABSTRACT),)
	ifneq ($(ABSTRACT_FROM),)
		ABSTRACT := $(shell cat "$(ABSTRACT_FROM)")
	endif
endif

ifeq ($(SOURCE),)
	SOURCE = $(NAME).md
endif

ifneq ($(BIBLIOGRAPHY),)
	BIBARGS = --bibliography=$(BIBLIOGRAPHY)
	ifneq ($(CSL),)
		BIBARGS = --bibliography=$(BIBLIOGRAPHY) --csl=$(CSL)
	endif
	BIBLATEX = --biblatex
	ifneq ($(BIBSTYLE),)
		BIBLATEX = --biblatex -V bibstyle:$(BIBSTYLE)
	endif
endif
# TODO: use last section header as bibtitle

REVHASH = $(shell git log -1 --format="%H" -- $(SOURCE))
REVDATE = $(shell git log -1 --format="%ai" -- $(SOURCE))
REVSHRT = $(shell git log -1 --format="%h" -- $(SOURCE))

ifeq ($(DATE),)
	DATE = $(REVDATE)
endif

ifneq ($(GITHUB),)
	REVLINK = $(GITHUB)commit/$(REVHASH)
	GIT_ATOM_FEED = $(GITHUB)commits/master.atom
endif

COMBINED = $(NAME)-tmp.md

# set `TOC:=` to disable table of contents in slides
TOC = --toc

########################################################################

PANDOC = $(shell which pandoc)
ifeq ($(PANDOC),)
	PANDOC = $(error please install pandoc)
endif

XELATEX = $(shell which xelatex)
ifeq ($(XELATEX),)
	XELATEX = $(error please install xelatex)
endif

BIBER = $(shell which biber)
ifeq ($(BIBER),)
	BIBER = $(error please install biber)
endif

########################################################################

.SUFFIXES:
.SUFFIXES: .md .html .pdf .tmp

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

%.html: %.md
	@rm -f tmp.*
	@echo "% $(TITLE)" > tmp.md
	@echo "% $(AUTHOR)" >> tmp.md
	@echo "% $(DATE)" >> tmp.md
	@echo "" >> tmp.md
	@cat $< >> tmp.md
	@$(PANDOC) -N tmp.md -o $@ --template $(HTML_TEMPLATE) --css $(HTML_CSS) $(V_METADATA)\
		--smart $(BIBARGS) -t html5
	@echo created $@
	@rm tmp.md

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
