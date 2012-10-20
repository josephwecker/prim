

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

Need to "quick-view" another tab while in insert mode- and remain in insert
mode- just a quick glance- with most recent quick-glance tab remembered for
even quicker glances- for when referencing a big source file a bunch.


Fill quickfix or location buffer with all instances of a tag in project so they
can all be renamed etc.

Potentially try again to get syntastic working correctly

Omnicomplete working, of course...

#### PrimFind

tag refreshing
  - when file has been changed, quick cpp pass on file to make sure syntax is
    good2go. if good, run ctags/cscope on it real quick. If not good to go,
    indicate in status-line (or something)

Less weight to anything in a path-part that starts with a dot

stack-exchange
  - possibly normalize votes by time? (would possibly not make sense because
    each one would be an s-curve?)

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
