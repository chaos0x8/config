if has('ruby') == 0 || exists('g:is_fold_cpp_loaded')
  finish
endif

let g:is_fold_cpp_loaded = 1

ruby << RUBY
module Fold
  module Cpp
    def exec
      if VIM.evaluate('exists("b:is_fold_cpp_loaded_done")') == 0
        VIM.command('let b:is_fold_cpp_loaded_done=1')
        Folder.new { |folder|
          _execFoldTests folder
        }.exec
      end
    end

    def _execFoldTests folder
      words = ['class', 'struct', 'TEST', 'TEST_F', 'TEST_P', 'TYPED_TEST']

      cB = VIM::Buffer.current

      _beg = nil
      _brackets = nil

      it = 1
      while it <= cB.count
        if ! _beg and m = cB[it].match(/^\s*(#{words.join('|')})\b/)
          if ['class', 'struct'].include?(m[1]) and ! cB[it].match(/\bpublic\s+Test\b/)
            it += 1
            next
          end

          _beg = it
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
              folder.add(_beg, it, open: cB.count < 64)
              it = _beg
              _beg, _brackets = nil, nil
            end
          end
        end
        it += 1
      end
    rescue Exception => e
      puts e
      puts e.backtrace.join("\n")
    end

    module_function :exec, :_execFoldTests
  end
end
RUBY

au! Syntax cpp call EvalRuby('Fold::Cpp::exec')
