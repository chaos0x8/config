if has('ruby') == 0 || exists('g:is_format_cpp_loaded') || version < 704 || !HasExecutable('clang-format')
  finish
endif

let g:is_format_cpp_loaded = 1

ruby << RUBY
module FormatCpp
  def self.args fnMode = :dummy
    [
      'clang-format',
      "-assume-filename=#{FormatCpp.fileName(fnMode)}",
      '-style=file'
    ]
  end

  def self.fileName mode
    case mode
    when :current
      C8.__file__
    else
      File.join(ENV['HOME'], 'dummy.cpp')
    end
  end
end
RUBY

nnoremap <leader>f :call PipeCurrent('FormatCpp::args')<CR>
vnoremap <leader>f :call PipeSelected('FormatCpp::args')<CR>

au BufWrite *.cpp call PipeAll('FormatCpp::args :current')
au BufWrite *.hpp call PipeAll('FormatCpp::args :current')
au BufWrite *.c call PipeAll('FormatCpp::args :current')
au BufWrite *.h call PipeAll('FormatCpp::args :current')
