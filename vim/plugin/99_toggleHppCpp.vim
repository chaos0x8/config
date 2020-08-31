if has('ruby') == 0 || exists('g:is_toggle_hpp_cpp_loaded')
  finish
endif

let g:is_toggle_hpp_cpp_loaded = 1

ruby << RUBY
module ToggleHppCpp
  class Script
    def switchTab currentFile
      pattern = _reversedPatern(currentFile)
      _switchToPatern(pattern)
    end

    def openTab currentFile
      patern = _reversedPatern(currentFile)

      files = Dir["#{File.dirname(currentFile)}/*"].select { |fn|
        File.basename(fn).match(patern)
      }.to_a

      case files.size
      when 0
        raise 'Matching file not found!'
      when 1
        _openFile files.first
      else
        print "0. Cancel\n"
        files.each_with_index { |fn, index|
          print "#{index+1}. #{fn}\n"
        }

        choice = VIM.evaluate('input("Choice: ")').to_i(10)

        return if choice == 0

        raise 'Out of range' unless choice-1 < files.size
        _openFile files[choice-1]
      end
    end

  private
    def _switchToPatern patern
      tabnr = VIM.evaluate 'tabpagenr()'

      begin
        C8.eachWindow.each_with_index { |win, i|
          if win.buffer.name and File.basename(win.buffer.name).match(patern)
            VIM.command "execute \"normal #{i+1}\\<c-w>\\<c-w>\""
            return true
          end
        }

        VIM.command 'tabnext'
      end until tabnr == VIM.evaluate('tabpagenr()')

      C8.eachBuffer { |buf|
        if buf.name and File.basename(buf.name).match(patern)
          VIM.command "b #{buf.number}"
          return true
        end
      }

      false
    end

    def _openFile fn
      if File.exists? fn
        VIM.command "edit #{fn}"
        return true
      end
    end

    def _reversedPatern fn
      case File.extname(fn)
      when '.c', '.cpp'
        /^#{_noExt(fn)}\.(h|hpp)$/
      when '.h', '.hpp'
        /^#{_noExt(fn)}\.(c|cpp)$/
      else
        raise 'Cannot toggle between this type of file!'
      end
    end

    def _noExt fn
      File.basename(fn).chomp(File.extname(fn))
    end
  end

  def self.exec
    if file = C8.__file__
      begin
        app = Script.new

        unless app.switchTab(file)
          app.openTab(file)
        end
      rescue RuntimeError => e
        print "#{e}\n"
        print e.backtrace.join("\n")
      rescue Exception => e
        print "#{e}\n"
        print e.backtrace.join("\n")
      end
    end
  end
end
RUBY

nnoremap <F4> :call C8_ruby('ToggleHppCpp::exec')<CR>
