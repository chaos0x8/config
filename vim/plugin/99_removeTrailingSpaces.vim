if has('ruby') == 0 || exists('g:is_remove_trailing_spaces_loaded')
  finish
endif

let g:is_remove_trailing_spaces_loaded = 1

function! PreventTrailRemoval()
ruby << RUBY
  fn = VIM::evaluate('expand("%:p")')
  case File.extname(fn)
  when '.md'
    VIM::command('let b:is_remove_trailing_spaces_loaded_prevent=1')
  else
    VIM::command('let b:is_remove_trailing_spaces_loaded_prevent=0')
  end
RUBY
endfunction

function! RemoveTrailingSpaces()
  if exists('b:is_remove_trailing_spaces_loaded_prevent') == 0
    call PreventTrailRemoval()
  endif

  if b:is_remove_trailing_spaces_loaded_prevent == 0
    try
      execute '%s/\s\s*$//'
    catch

    endtry
  endif
endfunction

au BufWrite * call RemoveTrailingSpaces()
