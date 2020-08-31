if has('ruby') == 0 || exists('g:is_build_loaded')
  finish
endif

let g:is_build_loaded = 1

ruby << RUBY
autoload :Open3, 'open3'
autoload :Shellwords, 'shellwords'

module C8
  module Build
    def self.handleError file:, line:, col:, error:
      file = File.expand_path(file)
      line = line.to_i
      col = col.to_i

      if File.exist?(file) and File.writable?(file)
        VIM.command "badd #{Shellwords.escape(file)}"

        C8.eachBuffer { |buffer|
          if buffer.name and File.expand_path(buffer.name) == file
            return { 'bufnr' => buffer.number, 'lnum' => line, 'text' => error, 'col' => col }
          end
        }
      end

      nil
    rescue Exception => e
      print e
      print e.backtrace.join("\n")
      nil
    end

    def self.goto error
      cW = VIM::Window.current
      cB = cW.buffer

      if cB.name
        if cB.number != error['bufnr']
          VIM.command "silent b #{error['bufnr']}"
        end

        cW.cursor = [error['lnum'], error['col']-1]
      end
    rescue Exception => e
      print e
      print e.backtrace.join("\n")
      nil
    end

    def self.handleBuildResult out:, st:
      if st.exitstatus != 0
        errors = out.each_line(chomp: true).collect { |line|
          if m = line.match(/^(.+?):(\d+):(\d+):\s+(fatal error:.*|error:.*)$/)
            C8::Build.handleError(file: m[1], line: m[2], col: m[3], error: m[4])
          end
        }.compact

        if errors.size > 0
          C8::Build.goto(errors.first)
        end

        Vim.command("call setqflist(#{C8.escape(errors)})")
        Vim.command('copen')
      else
        Vim.command('cclose')
        print 'Compiled OK'
      end
    rescue Exception => e
      print e
      print e.backtrace.join("\n")
      nil
    end

    def self.rake
      if file = C8.__file__
        out, st = Dir.chdir(File.dirname(file)) {
          Open3.capture2e('rake')
        }

        C8::Build.handleBuildResult out: out, st: st
      end
    end

    def self.make
      if File.exist?('CMakeLists.txt') and not File.exist?('Makefile')
        out, st = Open3.capture2e('cmake', 'CMakeLists.txt')
        return nil if st.exitstatus != 0
      end

      if File.exist?('Makefile')
        out, st = Open3.capture2e('make')
        C8::Build.handleBuildResult out: out, st: st
      end
    rescue Exception => e
      print e
      print e.backtrace.join("\n")
      nil
    end
  end
end
RUBY

if HasExecutable('rake') != 0
  com! Rake :call C8_ruby('C8::Build.rake')
endif

if HasExecutable('make') != 0 && HasExecutable('cmake') != 0
  com! Make :call C8_ruby('C8::Build.make')
endif

