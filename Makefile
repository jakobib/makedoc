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

#######################

.SUFFIXES:
.SUFFIXES: .md .html .pdf

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
	@pandoc -N tmp.md -o $@ --template $(HTML_TEMPLATE) --css $(HTML_CSS) $(V_METADATA)\
		--smart
	@echo created $@
	@rm tmp.md

slides.pdf: slides.md
	@rm -f tmp.*
	@echo "% $(TITLE)" > tmp.md
	@echo "% $(AUTHOR)" >> tmp.md
	@echo "% $(DATE)" >> tmp.md
	@echo "" >> tmp.md
	@cat slides.md >> tmp.md
	@pandoc tmp.md --slide-level 2 --toc -t beamer -o tmp.tex --template $(SLIDES_PDF_TEMPLATE) $(V_METADATA) $(V_SLIDES_PDF)
	@perl -p -i -e 's/^\\caption{}//' tmp.tex
	@pdflatex tmp.tex > /dev/null
	@pdflatex tmp.tex > /dev/null
	@mv tmp.pdf slides.md.pdf
#	@rm -f tmp.*

paper-tmp.md: paper.md
	@echo "% $(TITLE)" > $@
	@echo "% $(AUTHOR)" >> $@
	@echo "% $(DATE)" >> $@
	@echo "" >> $@
	@cat $< >> $@

paper.tex: paper-tmp.md
	@pandoc -t latex -o paper.tex $< \
		--template $(MAKEDOC)/templates/paper.tex --smart -V "mainfont=DejaVu Serif"

paper.pdf: paper.tex
	@xelatex paper.tex > /dev/null
	@xelatex paper.tex > /dev/null

clean:
	@rm -f *.aux *.log *.out *.bbl *.blg *.bak tmp.*

TMP := normalize.tmp

normalize: *.md
	@for f in `ls *.md`; do \
		pandoc --normalize -t markdown $$f > $(TMP); \
		if `diff $$f $(TMP) > /dev/null`; then \
			rm $(TMP); \
		else \
			cp -f "$$f" "$$f.bak"; \
			mv $(TMP) "$$f"; \
			echo "$$f - normalized"; \
		fi \
	done 
