if has('ruby') == 0 || exists('g:is_indent_loaded') || version < 704
  finish
endif

let g:is_indent_loaded = 1

ruby << RUBY
module Common
  def self.indent(text, level: Common::indentLevel)
    spaces = ' ' * level
    "#{spaces}#{text}".rstrip
  end

  def self.indentLevel(line = VIM::Buffer::current.line_number.to_i)
    VIM::evaluate("indent(#{line})").to_i
  end
end
RUBY
