ifeq ($(NAME),)
	NAME = $(shell basename $(CURDIR))
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

# set `TOC:=` to disable table of contents in slides
TOC = --toc

