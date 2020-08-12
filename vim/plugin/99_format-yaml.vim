if has('ruby') == 0 || exists('g:is_format_yaml_loaded') || version < 704
  finish
endif

let g:is_format_yaml_loaded = 1

ruby << RUBY
module FormatYaml
  def self.format text

  end
end
RUBY

function! FormatYaml()
ruby << RUBY

RUBY
endfunction

au BufWrite *.yaml call FormatYaml()
