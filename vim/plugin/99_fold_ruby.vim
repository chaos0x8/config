if has('ruby') == 0 || exists('g:is_fold_ruby_loaded')
  finish
endif

let g:is_fold_ruby_loaded = 1

ruby << RUBY
module Fold
  module Ruby
    def exec
      if VIM.evaluate('exists("b:is_fold_ruby_loaded_done")') == 0
        VIM.command('let b:is_fold_ruby_loaded_done=1')
        Folder.new { |folder|
          _execFoldModules folder
          _execFoldTests folder
        }.exec
      end
    end

    def _execFoldModules folder
      words = [ 'module', 'class', 'def' ]

      cB = Vim::Buffer.current

      _beg = nil
      _indent = nil

      it = 1
      while it <= cB.count
        if ! _beg and m = cB[it].match(/^\s*(#{words.join('|')})\b/)
          if m[1] != 'def' or Common.indentLevel(it) == 0
            _beg = it
            _indent = Common.indentLevel(it)
          end
        end

        if _beg and cB[it].match(/^\s*(end)\b/) and _indent == Common.indentLevel(it)
          folder.add(_beg, it, open: cB.count < 256)
          it = _beg
          _beg, _indent = nil, nil
        end

        it += 1
      end
    end

    def _execFoldTests folder
      words = ['context', 'with', 'setup', 'teardown', 'should']

      cB = VIM::Buffer.current

      _beg = nil
      _brackets = nil
      _word = nil

      it = 1
      while it <= cB.count
        if ! _beg and m = cB[it].match(/^\s*(#{words.join('|')})\b/)
          _beg = it
          _word = m[1]
        end

        if _beg
          if c = cB[it].count('{') and c > 0
            _brackets ||= 0
            _brackets += c
          end

          if _brackets
            if c = cB[it].count('}') and c > 0
              _brackets -= c
            end

            if _brackets == 0
              unfold = ['context', 'with'].include?(_word)
              folder.add(_beg, it, open: unfold)
              it = _beg
              _beg, _brackets, _word = nil, nil, nil
            end
          end
        end
        it += 1
      end
    rescue Exception => e
      puts e
      puts e.backtrace.join("\n")
    end

    module_function :exec, :_execFoldModules, :_execFoldTests
  end
end
RUBY

au! Syntax ruby call EvalRuby('Fold::Ruby::exec')
