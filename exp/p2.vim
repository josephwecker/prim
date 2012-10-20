" =============================================================================
" File:          p2.vim
" Description:   Super finder
" Author:        Joseph Wecker <joseph.wecker@gmail.com>
" Version:       0.0.1
" =============================================================================



function! p2#initialize()
  "if exists('s:initialized') | return | endif
  "let s:initialized = 1
  "silent! keepalt bot 1new SuperFindCmdWin
  "let [s:cmd_bufnr, s:cmd_width] = [bufnr('%'), winwidth(0)]
  "abclear <buffer> | iabclear <buffer>
  " TODO: read in history
  " TODO: define reused signs and associated highlights/glyphs
	"setl noswapfile nonumber nobuflisted nowrap nolist nospell nocursorcolumn winfixheight
	"setl foldcolumn=0 foldlevel=99 textwidth=0 buftype=nofile bufhidden=unload
  "setl statusline=superfind laststatus=0
  "if v:version > 702 | setl norelativenumber noundofile colorcolumn=0 | endif

endfunction


function! p2#inc()
  if exists("g:tmp_inc_val")
    let g:tmp_inc_val+=[getcmdline()]
  else | let g:tmp_inc_val=[] | endif
  return ""
endfunction


function! s:MapCmdKeys()
  if ! exists("s:km")
    let s:km=join(map(range(32,124),'"cnoremap \<char-".v:val."> \<char-".v:val."><C-R>=p2#inc()<CR>"'),"|")
  endif
  execute s:km
endfunction

function! s:UnmapCmdKeys()
  if ! exists("s:ku")
    let s:ku=join(map(range(32,124),'"cunmap \<char-".v:val.">"'),"|")
  endif
  execute s:ku
endfunction

function! p2#prompt()
  call s:MapCmdKeys()
  let s:finalsearch = input(">>> ","")
  call s:UnmapCmdKeys()
endfunction
