This repository contains templates and Makefiles to build publication in
multiple formats based on a source file in Pandoc Markdown. I use this
tools for my scientific publications, talks, and documentation driven
development.

Usage
-----

Some notes to begin with

1.  Create a directory for your publication (possibly as git
    repository).
2.  Check out this module in a subdirectory called 'make' (possibly as
    git submodule).
3.  Create a `Makefile` that at least contains `include make/Makefile`.
4.  Optionally create the file `metadata.ini` with title, abstract,
    keywords. This will be passed to templates.

...

Commands
--------

`make foo.html` creates HTML from a markdown file `foo.md`. Use
`make -B foo.html` to force creation.

`make normalize` normalizes all `.md` files in the current directory. A
backup is created with file extension `.md.bak`.

`make clean` removes all backup files and build artifacts.
