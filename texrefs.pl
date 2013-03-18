#!/usr/bin/perl

# Pandoc Markdown lack support of references to figures and tables
# There are several limited hacks. This is one of them:
#
#     ![caption\label{figure-3}](imagefile)
#
#     ... figure 3 ...
#
# Any ocurrence of "figure X" or "table Y" is replaced by a LaTeX reference:
# 
#     figure \ref{figure-3}

$/ = undef;
my $markdown = <>;
$markdown =~ s{(figure|table)(\s+)(\d+)}{"$1$2\\ref{".lc($1)."-$3}"}mgeis;
print $markdown;
