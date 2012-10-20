


 - Know which windows are from plugins / help / etc.- i.e.- distinguish between
   "user-content" vs. "meta" buffers/windows- Close vim when there are no
   user-content buffers/windows remaining.

 - Standard "home" spaces - for metainformation (i.e., targets / positions. So
   manpages would have a specific space etc.)

 - Different highlighting for different kinds of buffers/windows



Buffers + Filetypes + Mode
Windows
Tab-Pages

Tab-Page-rules/templates


Ideally taglist _combined_ with nerdtree _combined_ with ctrl-p++ _combined_
with juggler

Ideally also git aware

- - - - -



Heuristics-based fuzzy-find

- probably map to ? when in normal windows/buffers, and / when in the panel
  buffer.

- simply start w/ forward-slash to indicate regex
- look for nerdtree (etc.) root possibly as root dir
- some sort of pagination
- by default, lowercase indicates case-insensitive, upper indicates search for
  upper.
- juggler-like selection for left hand, nav list w/ right. except doesn't have
  'a' used for the currently open buffer- that's a waste of keyspace.
- highlight matches in project "tree"
- ideally specially highlighted panel
- ideally a window that doesn't allow vim to load another buffer into it
- shortcut that matches using the word under the cursor, which gives higher
  weight to tag & text match-scores than usual.

- [n-points] to past selections given the same pattern with the same or related
  root-directory (ala browser autocomplete, with counts / exp. moving average
  so that it can slowly change) - only if something is typed- so otherwise if
  nothing is typed it acts a lot like juggler- working w/ current buffers.
- [3-points] to files already in a buffer
- [n-points] based on match's similarity to actual typed line (string distance-
  use matched text for tag + plaintext matches below) - possibly weighted so
  that when the match is a prefix or suffix it fairs better than fuzzy-mixes.
- [1-point]  to most recently modified (actually EWMA)
- [1-point]  to most recently accessed (actually EWMA)
- [m-points] give weight to files that have fuzzy-matches against tags
- [m-points] to files that have plain-text fuzzy-matches
- [2-points] to files that are in the repo, not ignored
- [1-point]  to files that are in the repo
- [1-point]  to files that are in the repo and that are dirty

- points for a file that is closest to project root
- points for a file that is closest to current working directory
- points for a file that is closest to file in current buffer

(from :help help)
			- A match with same case is much better than a match
			  with different case.
			- A match that starts after a non-alphanumeric
			  character is better than a match in the middle of a
			  word.
			- A match at or near the beginning of the tag is
			  better than a match further on.
			- The more alphanumeric characters match, the better.
			- The shorter the length of the match, the better.


- man-page entries (apropos)



- filename match-score
- file relevancy score
  (could do more, like make .[ch] files more relevant if currently in a c/h file, etc.)
- tag match-score
- plain-text match-score



- show it as reference
- load into current window
- reveal existing or load into best target window (oldest-used that's not sticky)
(so, in all, it can be treated as a dynamic optimization problem)


- Locality persistence (so the eye finds it quickly after knowing where it is)
- Dimensional fit - enough lines of context and lines wide enough to not wrap
  as much as possible
- 



* Constant git/project-status panel
* Hints panel- context-sensitive:
  - manpage if applicable
  - function signature / autocomplete stuff if applicable
  - definition / implementation if applicable

  - mark a panel as "sticky"- causes subsequent "target" to split it instead of
    buffering over it (esp. for help/man pages etc.) - needs to be visually
    clear that it is sticky
