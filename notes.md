

### Primary Components

1. PrimFind/Preview/load
2. PrimBufs
   - primbuftabs
   - quick-remote-nav
     - inter-buffer (switch them remotely)
     - inner-buffer (scroll it up/down, /, ?, maximize/equalize, etc.)
   - inter-tab moving
   - better window distinction (bg-color [needs un-hardcoding], statusline, ...)
3. PrimContext: omni automatic contextual help in a specialized buffer
   - (Project-root/submodule aware)

   - Current-project
   - Current-file
   - Current-function/module
     - Sig
     - variables defined in head of function / all function for quick
       reference...
   - Current-word

   - Current-word-level
   - Definitions
   - Implementations
   - Callgraph- call this function
   - Callgraph- called by this function
   - Files that include this file
   - Better status-line
     - The git state of the file - included in statusline highlighting
     - 
4. PrimProj:       
   - Project/current-function/module/etc.- highlighting the current
     - TOC for each file
   - Good path compaction- '/bl../hey/there.html'
     - Likelihood of compaction decreases the closer to the end/base-filename
     - Compaction more likely on repeated common-suffixes/prefixes
     - Compaction more likely for whole path-part-parts (path-parts split on
       dots then underscores then dashes)
     - Ideally show which files are already loaded into the overall vim session
       (or look "globally" by just looking for the swapfiles)
     - Git-aware also
     - 


### Scratch

Set up primfind so that as it continues to find results etc the buffer keeps
updating. Method:
  - set buffer to modified & writeable
  - set autosave w/ tight interval
  - override the autocmd for writing the buffer
  - nop the actual write, but use the opportunity to modify the buffer -
    be sure not to listen to the write autocmd for a bit (if possible).
  - be sure that currently selected line remains selected if possible (based on
    some sort of ID?)
  - also, ideally, update the status bar with some kind of status indicator
    and/or spinner (-\|/...)

Probably better to set up the "trigger"-generating buffer separately from the
one actually being modified...



fuzzy file search priority (possibly also for inner text + tags):
  - cwd
  - cwd children (careful of cycles)
  - some env path variable(s)?
  - (files w/ same "family" of filetype [e.g., *.h/*.c...] as current "main" buffer)
  - sibling directories
  - parent directories- esp. within project
  - if inside-project fails to do anything meaningful, try whereis + locate
  - finally, a "find" from root directory may be appropriate if the user -really- really wants something





A kind of grep that instead of just -A/B/C for context lines, actually shows
language-context- like module/function/relevant-path-forks (if-statements) etc.
== tiny-context

project
  |- subdir
     |- source file
        |- [class]
           |- function/method/module
              |- local variables (?)
                 |- code-path branch


Another thing- kind of a mini-find-results for the word under the character-
but more informative:
 - "blah" is:
   - local variable name in such-and-such file
   - name of a struct defined here...
   - global variable in this other ...
(can at least be minimally based on the syntax-match and maybe even a quick
syntax-most-likely (using markov chains...))


It would be awesome to either find or create a real gdb plugin- one that uses
`sign` etc. (clewn)

It would also be awesome to either find or create a real unit-testing plugin-
including continuous integration.

Need to "quick-view" another tab while in insert mode- and remain in insert
mode- just a quick glance- with most recent quick-glance tab remembered for
even quicker glances- for when referencing a big source file a bunch.

With tag search-results, not possibly kind of a connection-graph preview
available: for example, if a variable is selected, show it's type, but also
information on other files that have used that type, examples of other
variables, etc., as well as other examples of variables w/ the same name...

Fill quickfix or location buffer with all instances of a tag in project so they
can all be renamed etc.

Potentially try again to get syntastic working correctly

Omnicomplete working, of course...


Automatically "guess" most of the main include-path, for tag search etc. etc.,
by including all subdirectories of the project that have source in them... ?
Or possibly only lazily after doing `checkpath`

#### PrimFind

* visible buffer files
* existing buffer files (by recency?)
* (retrievable) MRU/MRA files (esp accessed for read-only files)
* (retrievable) past-find/search history (better if nav within file, keeping it
  visible a while, etc., increases score to eliminate false positives)


(text similarity gives 1/2 credit for case-difference when search=upper and
res=lower. Gives even less- 1/4 credit if search=lower and res=upper)




tag refreshing
  - when file has been changed, quick cpp pass on file to make sure syntax is
    good2go. if good, run ctags/cscope on it real quick. If not good to go,
    indicate in status-line (or something)

tag sub-priority
(from help tags)
  When there are multiple matches for a tag, this priority is used:

  1. "FSC"  A full matching static tag for the current file.
  2. "F C"  A full matching global tag for the current file.
  3. "F  "  A full matching global tag for another file.
  4. "FS "  A full matching static tag for another file.
  5. " SC"  An ignore-case matching static tag for the current file.
  6. "  C"  An ignore-case matching global tag for the current file.
  7. "   "  An ignore-case matching global tag for another file.
  8. " S "  An ignore-case matching static tag for another file.



Less weight to anything in a path-part that starts with a dot

stack-exchange
  - possibly normalize votes by time? (would possibly not make sense because
    each one would be an s-curve?)

Potential plugins:
  - stack-exchange sites
  - vim.org scripts (and sources??)
  - online manpage repositories? (can't seem to find many good ones...)
  - forums- esp. some well-known ones
  - kernel mailing list
  - google
  - wikipedia
  - github
  - ruby-gem detailed info:  [like here](https://www.ruby-toolbox.com)
  - rfc, ietf, iso, w3c
  - [algorithms & data structures](http://xlinux.nist.gov/dads/) actually
  [for indexing](http://xlinux.nist.gov/dads/ui.html)
  - maybe google w/ certain site/inurl filters?

Use location list so there can be different active ones without having to use
quickfix-error-lists.

##### Preview

- specialized statusline - esp. emphasize how many matches per type - w/
- nav up/down selects different items of course
- nav left/right narrows context / filters result types


#### PrimBufs

Need to change the working directory as appropriate whenever changing tabs.
Each finds its own project-root.



    [*a*] [b] [c] [d]

    start cycling through them...
    [a] [b] [*c*] [d] ...

    stay on that one for long enough, and:
    [*c*] [a] [b] [d] ...

    or do any modifications / cursor changes etc. in normal buffer, and it will
    "cement" as well.

    track "time since last primbuf nav" in order to specify logic...

    need a quick key also to "reset" it- just want to briefly look at [c], for
    example, and then have it pop back to [a] and not change the order...


grouping... something along the lines of:

:au BufWinEnter * wincmd t | 4wincmd w | exec expand("<abuf>") . "buffer"

(where that 4 is the window where you really want it)
(will need some special processing for help files, quickfix buffers, and
preview buffers...)


Destination window:
  1. Look for any primbuf windows- if none, vsplit and wincmd to the far right
     full height, resize vert
  2. 


##### PrimContext

From help windows.txt:

:ped[it][!] [++opt] [+cmd] {file}
		Edit {file} in the preview window.  The preview window is
		opened like with |:ptag|.  The current window and cursor
		position isn't changed.  Useful example: >
			:pedit +/fputc /usr/include/stdio.h
<
							*:ps* *:psearch*
:[range]ps[earch][!] [count] [/]pattern[/]
		Works like |:ijump| but shows the found match in the preview
		window.  The preview window is opened like with |:ptag|.  The
		current window and cursor position isn't changed.  Useful
		example: >
			:psearch popen
<		Like with the |:ptag| command, you can use this to
		automatically show information about the word under the
		cursor.  This is less clever than using |:ptag|, but you don't
		need a tags file and it will also find matches in system
		include files.  Example: >
  :au! CursorHold *.[ch] nested exe "silent! psearch " . expand("<cword>")
<		Warning: This can be slow.

Example						*CursorHold-example*  >

  :au! CursorHold *.[ch] nested exe "silent! ptag " . expand("<cword>")

This will cause a ":ptag" to be executed for the keyword under the cursor,
when the cursor hasn't moved for the time set with 'updatetime'.  The "nested"
makes other autocommands be executed, so that syntax highlighting works in the
preview window.  The "silent!" avoids an error message when the tag could not
be found.  Also see |CursorHold|.  To disable this again: >

  :au! CursorHold

A nice addition is to highlight the found tag, avoid the ":ptag" when there
is no word under the cursor, and a few other things: >

  :au! CursorHold *.[ch] nested call PreviewWord()
  :func PreviewWord()
  :  if &previewwindow			" don't do this in the preview window
  :    return
  :  endif
  :  let w = expand("<cword>")		" get the word under cursor
  :  if w =~ '\a'			" if the word contains a letter
  :
  :    " Delete any existing highlight before showing another tag
  :    silent! wincmd P			" jump to preview window
  :    if &previewwindow			" if we really get there...
  :      match none			" delete existing highlight
  :      wincmd p			" back to old window
  :    endif
  :
  :    " Try displaying a matching tag for the word under the cursor
  :    try
  :       exe "ptag " . w
  :    catch
  :      return
  :    endtry
  :
  :    silent! wincmd P			" jump to preview window
  :    if &previewwindow		" if we really get there...
  :	 if has("folding")
  :	   silent! .foldopen		" don't want a closed fold
  :	 endif
  :	 call search("$", "b")		" to end of previous line
  :	 let w = substitute(w, '\\', '\\\\', "")
  :	 call search('\<\V' . w . '\>')	" position cursor on match
  :	 " Add a match highlight to the word at this position
  :      hi previewWord term=bold ctermbg=green guibg=green
  :	 exe 'match previewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
  :      wincmd p			" back to old window
  :    endif
  :  endif
  :endfun
