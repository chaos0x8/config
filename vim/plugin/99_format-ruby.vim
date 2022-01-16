if has('ruby') == 0 || exists('g:is_format_ruby_loaded') || version < 704 || !HasExecutable('rubocop')
  finish
endif

let g:is_format_ruby_loaded = 1

ruby << RUBY
module FormatRuby
  def self.args
    [
      'rubocop',
      '--auto-correct',
      '--stdin', '-',
      '--stderr'
    ]
  end
end
RUBY

au BufWrite *.rb call PipeAllIgnoreError('FormatRuby::args')
