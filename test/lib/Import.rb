#!/usr/bin/ruby

module Import
  @@importStatus = Hash.new

  def self.extractModuleFromVim fileName, moduleToImport
    @@importStatus ||= Hash.new
    return '' if @@importStatus[fileName + moduleToImport]

    moduleCode = Array.new
    rubySection = false
    beginImport = false
    File.open(fileName, 'r') { |f|
      f.each_line("\n") { |line|
        if line.match(/^RUBY$/)
            beginImport = false
            rubySection = false
        end

        if line.match(/^\s*module\s*#{moduleToImport}\s*$/)
            beginImport = true
        end

        moduleCode.push(line) if rubySection and beginImport

        if line.match(/^\s*ruby\s*<<\s*RUBY\s*$/)
            rubySection = true
        end
      }
    }

    @@importStatus[fileName + moduleToImport] = true

    moduleCode.join
  end
end
