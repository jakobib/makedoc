# makedoc

**makedoc** ist a git repository containing Makefiles and templates to create
papers and presentations from source files in [Pandoc Markdown]. The current 
version can be found at <https://github.com/jakobib/makedoc>. Feel free to 
[comment](https://github.com/jakobib/makedoc), reuse, fork, and modify!

makedoc is accompanied by [**makespec**](https://github.com/jakobib/makespec),
a similar tool to create specifications (makedoc and makespec may later be
merged).

[Pandoc Markdown]: http://johnmacfarlane.net/pandoc/demo/example9/pandocs-markdown.html

# Usage

## First steps

1.  Create a directory for your publication (possibly as git repository).

        mkdir example
        cd example
        git init

2.  Check out this module in a subdirectory called 'make' (possibly as git submodule):

        git submodule add https://github.com/jakobib/makespec.git

3.  Create a `Makefile` that at least contains `include make/Makefile`.

4.  Optionally create the file `metadata.ini` with title, abstract,
    keywords. This will be passed to templates.

## Commands

`make foo.html` creates HTML from a markdown file `foo.md`. Use
`make -B foo.html` to force creation.

`make normalize` normalizes all `.md` files in the current directory. A
backup is created with file extension `.md.bak`.

`make clean` removes all backup files and build artifacts.
