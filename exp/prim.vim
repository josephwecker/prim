" TODO (triage):
"   - 
"
"
" TODO:
"   - PrimOpenAuxCmd versions for commands that automatically split vs don't
"     (help vs man etc.?) - alternately, automatically close empty files when
"     all is done
"   - Fix ctrl-h/ctrl-l to go left/right instead, and remap ctl-j/k
"   - Mapping that just toggles between left-side windows and right-side
"     windows (i.e., "go[to/from] references)
"
"   - Aux mapping for help
"   - Aux mapping for man
"   - Aux mapping for preview (?)
"   - Aux mapping for reference file
"   - Aux mapping for auto-reference
"   - Aux mapping for quick-find (also does [and undoes] a wincmd _ temporarily)
"
"   - Equivalents, where appropriate, for item under cursor
"
"   - Set syntax for nontext so that lines after buffer are colored correctly
"     in aux (like in a blank quickfix list)
"   - Better left-margin for aux pages
"   - Better status-lines for all aux files, including highlighting
"   - Jump to existing window w/ given buffer first if it exists, before trying
"     to open another... (? low priority?)
"   - Ideally specifically mark reference windows as sticky- or maybe even
"     automatically mark as sticky for ones that have been referenced the
"     most...
"   - Autoclose when appropriate
"   - Automatic session saving for a tab
"   - Do the tab mappings
"   - ctrl-; to open new aux window w/ no contents to the right (for things
"     without a mapping yet)
"
"   - Keep manpages + help-pages grouped at the top, and everything else
"     afterward
"   - Better yet- designate a kind of 'subtabs' interface - have all manpages
"     and help pages in position 1 to the right, with the status line
"     indicating which buffers are available... with mappings to very quickly
"     alternate them while still in edit context
"
"   - Get omnicomplete working
"   - ctags / cscope integration
"
"   - Use status-line syntax highlighting (for normal files on left) to show
"     which part of the path is the current working directory / root
"   - On aux pages, keep cursor in middle- that is, scroll immediately like
"     less.
"
"   - subtabs:
"     - Figure out workflow
"       - 
"     - two lists- active (mru cycled) and historical (for 'closed' buffers etc.)
"     - possibly give them buffer 'ids' that are semi-permanent (based on a
"       hash or something).
"
"   - superfind
"     - incremental search term
"       - forward-slash anywhere indicates file preference (? maybe emergent)
"       - forward-slash at beginning indicates regex
"     - preview results
"     - possibly modify search term (maybe triggering superfind inside
"       preview-results mode brings up prev term instead of blank new one.
"     - 
"
" cluster(name position filetypes)
"
"
"	au BufWinLeave *.c mkview
"	au BufWinEnter *.c silent loadview
"   
"   - vim commands for automatically continuing + aligning CPP macro '/' eols -
"     makes sure they exist, makes sure they are at the correct column- keeps
"     going until full dedent
"
"   - Summary window- not quite like tags- more like a table of contents for
"     the code. Tags but in file-defined order and only implementation ones...
"     Use as well as children of a file-node in the project tree.
"     Also, ideally, have it automatically show where you are...
"     Possibly make it syntax based so it works w/ things like markdown files
"     as well...
"


function! prim#e(msg)
  echohl ErrorMsg| echon a:msg| echohl none
endfunction
if exists("g:prim_loaded") | finish | endif
if &compatible             | call prim#e("Can't run prim in vi-compatible mode") | finish | endif
let g:prim_loaded = "true"

"------------------------------------------------------------------------------

function! SetCurrBackground(color)
  if exists("b:custom_bg_set")
    return
  else
    let bn=bufnr('')
    execute "hi! FTBG_" . bn "guibg=" . a:color
    execute "sign define FTBGS_" . bn "linehl=FTBG_" . bn
    let n=1
    while n <= line('$')
      exe "sign place" n "line=" . n "name=FTBGS_" . bn "buffer=" . bn
      let n += 1
    endwhile
    let b:custom_bg_set = "true"
  endif
endfunction


" ...OpenAuxCmd(cmd)
" TODO
"  - Work correctly when starting from h-split windows w/ no full- v-split
"  - Probably rename w/ namespace
"  - Probably do `wincmd _` when the window is actually entered
"  - Version for entering and for remaining in current window...
"


function! PrimOpenAuxCmd(cmd)
  setlocal splitright splitbelow
  if winnr("$") == 1 || (&columns - winwidth(0)) < 10
    execute "vertical botright" a:cmd
    vertical resize 85
    "vsplit
    "execute a:cmd
  else
    100wincmd w   " Go to bottom-rightmost window
    execute "botright" a:cmd
  endif
endfunction






set splitright splitbelow
command! -nargs=* -complete=command PrimAux :call PrimOpenAuxCmd(<q-args>)
" TODO use a master-dictionary, which will include background as well as
" extension-name etc. etc.
autocmd! FileType help,qf,prim call SetCurrBackground("#252525")
autocmd! FileType man          call SetCurrBackground("#202020")
autocmd! BufWinEnter *.txt setl textwidth=100



