#!/usr/bin/ruby

require 'test/unit'
require 'shoulda'

require_relative 'lib/Import'
eval Import.extractModuleFromVim("#{File.dirname(__FILE__)}/../vim/plugin/00_indent.vim", 'Common')

class TestIndent < Test::Unit::TestCase
  context('TestIndent') {
    should('indent') {
      assert_equal('  some text', Common.indent('some text', level: 2))
    }
  }
end
