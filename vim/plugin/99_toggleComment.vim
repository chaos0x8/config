if has('ruby') == 0 || exists('g:is_toggle_comment_loaded')
  finish
endif

let g:is_toggle_comment_loaded = 1

ruby << RUBY
module ToggleComment
  def self.exec
    if newLine = toggleLine(VIM::Buffer.current.line, commentCharacter)
      VIM::Buffer.current.line = newLine
    end
  end

private
  def self.commentCharacter
    if file = C8.__file__
      case File.extname(file)
      when '.cpp', '.hpp', '.c', '.h', '.ttcn3', '.cs'
        com = '//'
      when '.rb', '.py'
        com = '#'
      when '.vim'
        com = '"'
      end
    end
  end

  def self.toggleLine(line, comChar)
    if comChar and line.strip.size > 0
      if line.match(/^\s*#{comChar}/)
        line.gsub(/^(\s*)#{comChar}/, "\\1")
      else
        "#{comChar}#{line}"
      end
    end
  end
end
RUBY

vnoremap <C-C> :call C8_ruby('ToggleComment::exec')<CR>
nnoremap <C-C> :call C8_ruby('ToggleComment::exec')<CR>
