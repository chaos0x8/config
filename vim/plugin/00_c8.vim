if has('ruby') == 0 || exists('g:is_c8_loaded')
  finish
endif

let g:is_c8_loaded = 1

ruby << RUBY
require 'pathname'

module C8
  def self.eachBuffer &block
    Enumerator.new { |e|
      Vim::Buffer.count.times { |i|
        e << Vim::Buffer[i]
      }
    }.each(&block)
  end

  def self.eachWindow &block
    Enumerator.new { |e|
      Vim::Window.count.times { |i|
        e << Vim::Window[i]
      }
    }.each(&block)
  end

  def self.window_index
    Vim::Window.count.times do |i|
      return i if $curwin == Vim::Window[i]
    end

    nil
  end

  def self.next_window
    Vim.command "execute \"normal \\<c-w>\\<c-w>\""
  end

  def self.escape data
    if data.kind_of? Hash
      "{#{data.collect { |k, v| "#{C8.escape(k)}: #{C8.escape(v)}"}.join(', ')}}"
    elsif data.kind_of? Array
      "[#{data.collect { |v| "#{C8.escape(v)}" }.join(', ')}]"
    elsif data.kind_of? String
      "'#{data}'"
    else
      data.to_s
    end
  end

  def self.file_git_relative
    path = Pathname.new(__file__)
    while parent = path.dirname and parent != path
      if parent.join('.git').directory?
        result = Pathname.new(__file__).relative_path_from(parent)
        return result
      end

      path = parent
    end

    return nil
  end

  def self.__file__
    fn = Vim.evaluate('expand("%:p")')
    if fn and fn.size > 0
      fn = File.expand_path(fn)
      fn if File.exist?(fn)
    end
  end

  def self.__cword__
    Vim.evaluate('expand("<cword>")')
  end

  def self.__syntax__
    Vim.evaluate('VimEvalSyntax()')
  end
end
RUBY

function! C8_ruby(rubyEval)
ruby << RUBY
  eval(Vim.evaluate('a:rubyEval'))
RUBY
endfunction

function! C8_rubyRange(command) range
ruby << RUBY
  eval(VIM::evaluate('a:command'))
RUBY
endfunction
