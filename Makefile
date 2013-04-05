.SUFFIXES:
.SUFFIXES: .md .html .pdf

# load metadata from files (TODO: use Config::INI)
TITLE    := $(shell perl -ne '/title\s*=\s*(.*)/ && print $$1' metadata.ini 2>/dev/null)
AUTHOR   := $(shell perl -ne '/author\s*=(.*)/ && print $$1' metadata.ini 2>/dev/null)
DATE     := $(shell perl -ne '/date\s*=(.*)/ && print $$1' metadata.ini 2>/dev/null)
ABSTRACT := $(shell perl -ne '/abstract\s*=(.*)/ && print $$1' metadata.ini 2>/dev/null)
KEYWORDS := $(shell perl -ne '/keywords\s*=(.*)/ && print $$1' metadata.ini 2>/dev/null)
NAME     :=

MAKEDOC=makedoc

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
	@pandoc -N tmp.md -o $@ --template $(HTML_TEMPLATE) --css $(HTML_CSS) $(V_METADATA)
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
	@mv tmp.pdf slides.pdf
#	@rm -f tmp.*

clean:
	@rm -f *.aux *.log *.out *.bbl *.blg *.bak tmp.*

TMP := normalize.tmp

status:
	@ls *.md

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
