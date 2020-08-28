if has('ruby') == 0 || exists('g:is_tags_loaded')
    finish
endif

let g:is_tags_loaded = 1

ruby << RUBY
require 'shellwords'

module FindTags
  def self.findIn dir
    file = "#{dir}"
    file += '/' unless file.match /\/$/
    file += 'tags'

    return file if File.exists? file
    return findIn(File.dirname(dir)) if File.dirname(dir) != dir
    nil
  end

  def self.exec
    if dir = C8.__file__
      dir = File.dirname(dir) unless File.directory? dir

      tags = FindTags.findIn dir
      VIM.command "set tags=#{Shellwords.shellescape(tags)}" if tags
    end
  end
end
RUBY

com! FindTags :call C8_ruby('FindTags::exec')
execute ':FindTags'
