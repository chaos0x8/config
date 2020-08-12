if has('ruby') == 0 || exists('g:is_common_loaded')
  finish
endif

let g:is_common_loaded = 1

ruby << RUBY
module Common
  def self.getSelectedLine
    cB = VIM::Buffer::current
    [ cB.line, cB.line_number, cB.line_number ]
  end

  def self.getSelectedLines
    _beg = VIM.evaluate('getpos("\'<")[1]')
    _end = VIM.evaluate('getpos("\'>")[1]')
    [ getLines(_beg, _end), _beg, _end ]
  end

  def self.getAllLines
    cB = VIM::Buffer::current

    _beg = 1
    _end = cB.count

    [ getLines(_beg, _end), _beg, _end ]
  end

  def self.overrideLines newValue, _beg, _end
    cLineNumber = _beg

    newValue.each do |line|
      if cLineNumber <= _end
        VIM::Buffer.current[cLineNumber] = line
      else
        VIM::Buffer.current.append cLineNumber-1, line
      end

      cLineNumber += 1
    end

    if cLineNumber <= _end
      (_end + 1 - cLineNumber).times do
        VIM::Buffer.current.delete cLineNumber
      end
    end
  end

private
  def self.getLines i, _end
    result = Array.new
    while i <= _end
      result.push VIM::Buffer.current[i]
      i += 1
    end
    result
  end
end
RUBY

function! EvalRuby(command)
ruby << RUBY
  eval(VIM::evaluate('a:command'))
RUBY
endfunction

function! EvalRubyRange(command) range
ruby << RUBY
  eval(VIM::evaluate('a:command'))
RUBY
endfunction

function! VimEvalTags()
  redir => l:cmdResult
  exec 'silent set tags?'
  redir END

  return substitute(l:cmdResult, '.*tags=\(.*\)$', '\1', '')
endfunction

