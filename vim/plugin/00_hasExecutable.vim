if has('ruby') == 0 || exists('g:is_has_executable_loaded')
  finish
endif

let g:is_has_executable_loaded = 1

if version >= 704
  function! HasExecutable(executable)
ruby << RUBY
    st = (system('which', VIM::evaluate('a:executable'), out: '/dev/null') ? 1 : 0)
    print "Missing executable '#{VIM::evaluate('a:executable')}'" unless st == 1
    VIM::command "let l:result = #{st}"
RUBY
    return l:result
  endfunction
else
  function! HasExecutable(executable)
    return 0
  endfunction
endif

