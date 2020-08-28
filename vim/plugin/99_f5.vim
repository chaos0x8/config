if has('ruby') == 0 || exists('g:is_f5_loaded') || !HasExecutable('merge')
  finish
endif

let g:is_f5_loaded = 1

ruby << RUBY
module F5
  def self.exec
    if fn = C8.__file__
      saveAs(currentContent, CURRENT)

      VIM::command(':earlier 1f')

      saveAs(currentContent, ORYGINAL)

      reloadFile

      saveAs(currentContent, NEW)

      require 'open3'
      merged, err, st = Open3.capture3('merge', '-p',
        '-L', 'new (changed outside)', '-L', 'oryginal', '-L', 'current (changed in vim)',
        NEW, ORYGINAL, CURRENT)
      Common::overrideLines(merged.split("\n"), 1, VIM::Buffer::current.length)

      unless st == 0
        conflictPatern = '<<<<<<< new (changed outside)'
        VIM::command(":call matchadd('Search', '#{conflictPatern}')")
        VIM::command(":call search('#{conflictPatern}')")
      end
    end
  end

  def self.reloadFile
    VIM::command(':edit!')
    VIM::command(':redraw!')
  end

private
  CURRENT = '/tmp/vim-f5-plugin-current'
  ORYGINAL = '/tmp/vim-f5-plugin-oryginal'
  NEW = '/tmp/vim-f5-plugin-new'

  def self.currentContent
    cB = VIM::Buffer::current

    actualContent = Enumerator.new { |e|
      cB.length.times { |i|
        e << cB[i+1]
      }
    }.to_a.join("\n")
  end

  def self.saveAs(content, fileName)
    File.open(fileName, 'w') { |f|
      f.write(content)
    }
  end
end
RUBY

nnoremap <F5> :call C8_ruby('F5::exec')<CR>
nnoremap <C-F5> :call C8_ruby('F5::reloadFile')<CR>
