if has('ruby') == 0 || exists('g:is_format_yaml_loaded') || version < 704 || !HasExecutable('c8-yaml-format')
  finish
endif

let g:is_format_yaml_loaded = 1

ruby << RUBY
module FormatYaml
  def self.args
    [
      'c8-yaml-format',
      '--indentation', '2',
      '--line_width', '120'
    ]
  end
end
RUBY

au BufWrite *.yaml call PipeAll('FormatYaml::args')
