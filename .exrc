set autoindent        " handy for email and programming
                      " so that I don't have to look up from my work
set modeline         " reduces the confusion factor immeasurably
                      " and explanations. i can figure it out, thank you.
"set number            " precede each line with a number so i can easily do
                      " stuff like- :77,87!fmt to format a block of text
set remap             " hm. don't recall, but I know I like it.  ;-)
set report=1          " *always* show me changes that commands make
set ruler             " more confusion reduction. what line/column i'm on.
set scroll=15         " got stuck in by default somewhere, so i left it.

set showcmd          " not portable across all kinds of vi
set showmatch         " match parens and braces. good for programming.
set showmode          " portable method to show the current mode on bottom line
set shiftwidth=4      " i like minimal indentation. see tabstops (ts), too.
set tabstop=4         " this should be the same as the next line. not always.
set ts=4              " only indent 2 spaces. see shiftwidth (sw) above.
set directory=/tmp    " where to put temporary files. good for most systems
map #2 :set number
map #3 :set nonumber
map #5 o   #-------------------------------------------------------------------------#
map #6 A----------
map #7 o<!--#include file="header.shtml" -->
map #8 o<!--#include file="footer.html" -->
map #9 :1,$s/
