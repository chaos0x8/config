if exists('g:is_toggle_mouse_loaded')
  finish
endif

let g:is_toggle_mouse_loaded = 1

function! ToggleMouse()
  if &mouse == 'a'
    set mouse=
  elseif &mouse == ''
    set mouse=a
  endif
endfunction

noremap <silent> <leader>a :call ToggleMouse()<CR>

