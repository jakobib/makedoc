This is a sample paper that shows how to use makedoc.

# Introduction

This paper is written in Pandoc Markdown by John MacFarlane [-@MacFarlane2013]
and managed with makedoc [@Voss2013].

# In a nutshell

To manage a paper with makedoc:

* create a `Makefile` that
    * points to the markdown source file and a bibliography (optional)
    * specifies title, author and other metadata
* link to makedoc

One can then create the paper version in HTML, PDF and other formats.

    make paper.html
    make paper.pdf

The best practice is to manage the paper source file in a git repository and
link to makedoc as submodule.

# References
