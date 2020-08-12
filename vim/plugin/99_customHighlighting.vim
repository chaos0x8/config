if has('ruby') == 0 || exists('g:is_custom_highlighting_loaded')
  finish
endif

let g:is_custom_highlighting_loaded = 1

function! CustomHighlightUpdate(tNumber)
  silent! execute 'syn clear custom_hi_' . a:tNumber

  if exists('g:custom_hi_' . a:tNumber . '_word')
ruby << RUBY
    name = "custom_hi_#{VIM.evaluate('a:tNumber')}"
    word = VIM.evaluate "g:#{name}_word"
    color = Integer(VIM.evaluate('a:tNumber')) + 1

    bgColor = 'black'
    if color >= 8
      color = color + 1
      bgColor = 'darkgray'
    end

    VIM.command "syn match #{name} /\\<#{word}\\>/"
    VIM.command "hi #{name} term=bold ctermfg=#{color} ctermbg='#{bgColor}'"
RUBY
  endif
endfunction

function! CustomHighlightUpdateAll()
ruby << RUBY
  9.times { |i| VIM.command "call CustomHighlightUpdate(#{i})" }
RUBY
endfunction

function! CustomHighlightClear()
ruby << RUBY
  9.times { |i| VIM.command "silent! unlet g:custom_hi_#{i}_word" }
RUBY
  call CustomHighlightUpdateAll()
endfunction

function! CustomHighlight(tName)
  execute 'let g:custom_hi_' . a:tName . '_word = "' . expand('<cword>') . '"'
  " ===============================================================
  call CustomHighlightUpdate(a:tName)
endfunction

ruby << RUBY
  9.times { |i| VIM.command "map <leader>#{i+1} :call CustomHighlight(#{i})<CR>" }
RUBY

map <leader>0 :call CustomHighlightClear()<CR>

au BufEnter * :call CustomHighlightUpdateAll()
