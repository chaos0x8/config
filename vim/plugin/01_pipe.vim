if has('ruby') == 0 || exists('g:is_pipe_loaded') || version < 704
  finish
endif

let g:is_pipe_loaded = 1

ruby << RUBY
module Pipe
  def self.system(command, *args, ignore_error: false, indent: true, **opts)
    require 'open3'

    overrideLinesByCommand(
      command, *args, ignore_error: ignore_error, indent: indent, **opts)
  end

  def self.current
    text, _beg_, _end_ = Common::getSelectedLine
    { stdin_data: text, _beg_: _beg_, _end_: _end_ }
  end

  def self.selected
    text, _beg_, _end_ = Common::getSelectedLines
    { stdin_data: text.join("\n"), _beg_: _beg_, _end_: _end_ }
  end

  def self.all
    text, _beg_, _end_ = Common::getAllLines
    { stdin_data: text.join("\n"), _beg_: _beg_, _end_: _end_ }
  end

private
  def self.overrideLinesByCommand(command, *args, _beg_:, _end_:, ignore_error:, indent:, **opts)
    out, err, st = Open3.capture3(command, *args, **opts)

    result = out

    if st.exitstatus != 0
      result = err unless ignore_error && !result.empty?
    end

    result = result.split("\n").collect { |line|
      if indent
        Common::indent(line, level: Common::indentLevel(_beg_))
      else
        Common::indent(line, level: 0)
      end
    }

    Common::overrideLines(result, _beg_, _end_)

    st.exitstatus == 0
  end
end
RUBY

function! PipeCurrent(rubyEval)
ruby << RUBY
  Pipe::system(*eval(VIM::evaluate('a:rubyEval')), **Pipe::current)
RUBY
endfunction

function! PipeSelected(rubyEval) range
ruby << RUBY
  Pipe::system(*eval(VIM::evaluate('a:rubyEval')), **Pipe::selected)
RUBY
endfunction

function! PipeAll(rubyEval) range
ruby << RUBY
  Pipe::system(*eval(VIM::evaluate('a:rubyEval')), **Pipe::all)
RUBY
endfunction

function! PipeAllIgnoreError(rubyEval) range
ruby << RUBY
  Pipe::system(*eval(VIM::evaluate('a:rubyEval')), ignore_error: true, **Pipe::all)
RUBY
endfunction
