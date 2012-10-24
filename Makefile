.SUFFIXES:
.SUFFIXES: .md .html .pdf

# load metadata from files (TODO: YAML config file)
TITLE    := $(shell perl -ne '/title\s*=\s*(.*)/ && print $$1' metadata.ini 2>/dev/null)
AUTHOR   := $(shell perl -ne '/author\s*=(.*)/ && print $$1' metadata.ini 2>/dev/null)
ABSTRACT := $(shell perl -ne '/abstract\s*=(.*)/ && print $$1' metadata.ini 2>/dev/null)
KEYWORDS := $(shell perl -ne '/keywords\s*=(.*)/ && print $$1' metadata.ini 2>/dev/null)
NAME     :=

# combine metadata as arguments to templates (FIXME: escaping)
V_METADATA=-V abstract:'$(ABSTRACT)' -V keywords:'$(KEYWORDS)'

# which template to use
TEMPLATE=default

# create HTML
HTML_CSS      = make/templates/$(TEMPLATE).css
HTML_TEMPLATE = make/templates/$(TEMPLATE).html

%.html: %.md
	@pandoc -N $< -o $@ --template $(HTML_TEMPLATE) --css $(HTML_CSS) $(V_METADATA)
	@echo created $@

# TODO: create PDF

clean:
	@rm -f *.aux *.log *.out *.bbl *.blg *.bak

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
