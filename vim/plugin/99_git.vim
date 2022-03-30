if has('ruby') == 0 || exists('g:is_git_loaded') || !HasExecutable('git')
  finish
endif

let g:is_git_loaded = 1

ruby << RUBY
require 'shellwords'

class Git
  def revert
    exec "git checkout #{Shellwords.escape(file)}", :out => '/dev/null'
  end

  def diff
    VIM.command "silent !git diff #{Shellwords.escape(file)} | vim - -R"
  end

  def show
    VIM.command "silent !git show #{cword} | vim - +/^diff.*#{Shellwords.escape(File.basename(file))}$/ -R"
  end

  def add
    exec "git add #{Shellwords.escape(file)}", :out => '/dev/null'
  end

  def blame
    VIM.command "silent !git blame #{Shellwords.escape(file)} | vim #{cmd(file)} - +#{line_number} -R"
  end

  def curBlame
    VIM.command "silent !git blame #{cword} -- #{Shellwords.escape(file)} | vim #{cmd(file)} - +#{line_number} -R"
  end

  def prevBlame
    VIM.command "silent !git blame #{cword}~1 -- #{Shellwords.escape(file)} | vim #{cmd(file)} - +#{line_number} -R"
  end

  def log
    VIM.command "silent !git log #{Shellwords.escape(file)} | vim #{cmd(file)} - -R"
  end

  def compare
    if file = C8.file_git_relative
      syntax = C8.__syntax__
      VIM.command "diffthis"
      VIM.command "vnew"
      VIM.command "read !git show origin/master:#{file}"
      VIM.command "set syntax=#{syntax}" if syntax
      VIM.command "diffthis"
    end
  end

private
  def cmd fn
    "--cmd #{Shellwords.escape("let g:git_blame_file='#{fn}'")}"
  end

  def file
    git_blame_file = VIM.evaluate('g:git_blame_file')
    return git_blame_file unless git_blame_file.empty?

    file = C8.__file__
  end

  def cword
    C8.__cword__
  end

  def line_number
    VIM::Buffer.current.line_number
  end

  def exec command, opts = Hash.new
    pid = Process.spawn(command, opts)
    Process.wait(pid)

    raise RuntimeError.new('execution failed') if $?.exitstatus != 0

    nil
  end
end
RUBY

function! GitRuby(command)
  if !exists('g:git_blame_file')
    let g:git_blame_file=''
  endif

ruby << RUBY
  command = VIM::evaluate 'a:command'
  Git.new.send(command.to_sym)
RUBY

  if a:command == 'revert'
    execute ':edit!'
  endif

  execute ':redraw!'
endfunction

com! GRevert :call GitRuby('revert')
com! GDiff :call GitRuby('diff')
com! GAdd :call GitRuby('add')
com! GBlame :call GitRuby('blame')
com! GCurBlame :call GitRuby('curBlame')
com! GPrevBlame :call GitRuby('prevBlame')
com! GShow :call GitRuby('show')
com! GLog :call GitRuby('log')
com! GCompare :call GitRuby('compare')
