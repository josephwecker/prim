function! ExCmd(cmd)
  redir => s:res | silent execute a:cmd | redir END
  return s:res
endfunction
