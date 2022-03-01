if has('ruby') == 0 || exists('g:is_fold_ruby_loaded')
  finish
endif

let g:is_fold_ruby_loaded = 1

ruby << RUBY
module Fold
  module Ruby
    def self.exec
      if VIM.evaluate('exists("b:is_fold_ruby_loaded_done")') == 0
        VIM.command('let b:is_fold_ruby_loaded_done=1')
        Folder.new { |folder|
          execFoldModules folder
        }.exec
      end
    end

    def self.execFoldModules folder
      words = %w[module class def describe context before after it RSpec.shared_examples RSpec.shared_context]

      cB = Vim::Buffer.current

      _beg = nil
      _indent = nil

      it = 1
      while it <= cB.count
        if ! _beg and m = cB[it].match(/^\s*(#{words.join('|')})\b/)
          _beg = it
          _indent = Common.indentLevel(it)
        end

        if _beg and cB[it].match(/^\s*(end)\b/) and _indent == Common.indentLevel(it)
          fold_size = it - _beg
          folder.add(_beg, it, open: cB.count < 60 || fold_size < 5)
          it = _beg
          _beg, _indent = nil, nil
        end

        it += 1
      end
    end
  end
end
RUBY

au! Syntax ruby call C8_ruby('Fold::Ruby::exec')
