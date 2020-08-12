#!/usr/bin/ruby

require 'test/unit'
require 'shoulda'

require_relative 'lib/Import'
eval Import.extractModuleFromVim("#{File.dirname(__FILE__)}/../vim/plugin/99_toggleComment.vim", 'ToggleComment')

class TestToggleComment < Test::Unit::TestCase
  context('TestToggleComment') {
    should('add comment') {
      assert_equal('#line', ToggleComment.toggleLine('line', '#'))
      assert_equal('# line', ToggleComment.toggleLine(' line', '#'))
    }

    should('remove comment') {
      assert_equal('line', ToggleComment.toggleLine('#line', '#'))
      assert_equal(' line', ToggleComment.toggleLine('# line', '#'))
    }

    should('do nothing when line is empty') {
      assert_equal(nil, ToggleComment.toggleLine('', '#'))
    }

    should('do nothing when comment char is nil') {
      assert_equal(nil, ToggleComment.toggleLine('line', nil))
    }
  }
end
