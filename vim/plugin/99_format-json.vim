if has('ruby') == 0 || exists('g:is_format_json_loaded') || version < 704
  finish
endif

let g:is_format_json_loaded = 1

ruby << RUBY
autoload :JSON, 'json'

module FormatJson
  def self.format text
    result = JSON.pretty_generate(JSON.parse(text.join("\n")))
    result.split("\n")
  end
end
RUBY

function! FormatJson()
ruby << RUBY
  text, _beg_, _end_ = Common::getAllLines
  Common::overrideLines(FormatJson.format(text), _beg_, _end_)
RUBY
endfunction

au BufWrite *.json call FormatJson()
