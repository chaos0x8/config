#!/usr/bin/ruby

require 'test/unit'
require 'shoulda'
require 'mocha/setup'

require 'tempfile'
require 'open3'
require 'shellwords'

require_relative 'lib/Import'
eval Import.extractModuleFromVim("#{File.dirname(__FILE__)}/../vim/plugin/00_c8.vim", 'C8')
eval Import.extractModuleFromVim("#{File.dirname(__FILE__)}/../vim/plugin/99_build.vim", 'C8')

class TestBuild < Test::Unit::TestCase
  context('TestBuild') {
    setup {
      @file = Tempfile.new(['foo', '.cpp'])
      @file.close
      @fn = @file.path

      @st = mock('st')

      @out = mock('out')

      @cmdSeq = sequence('cmdSequence')

      @buffer = mock('buffer')
      @buffer.stubs(name: @fn, number: 42)

      ::Vim = mock('Vim') unless defined? ::Vim
      ::Vim.expects(:common).times(0)
      C8::Build.stubs(:print)
      C8.stubs(:eachBuffer).multiple_yields([@buffer])
    }

    teardown {
      @file.unlink
    }

    context('success') {
      setup {
        @st.stubs(exitstatus: 0)
      }

      should('close quick fix') {
        ::Vim.expects(:command).with('cclose').in_sequence(@cmdSeq)

        C8::Build.handleBuildResult(out: @out, st: @st)
      }
    }

    context('failure') {
      setup {
        @st.stubs(exitstatus: 1)
      }

      ['error: some error message',
       'fatal error: some error message'].each { |errorMsg|
        should("parse #{errorMsg}") {
          output = [
            "#{@fn}:33:22: #{errorMsg}"
          ]

          @out.expects(:each_line).with(chomp: true).returns(output)

          errors = [{
            'bufnr' => @buffer.number,
            'lnum' => 33,
            'text' => errorMsg,
            'col' => 22}]
          C8::Build.expects(:goto).with(errors.first)
          ::Vim.expects(:command).with("badd #{@fn}").in_sequence(@cmdSeq)
          ::Vim.expects(:command).with("call setqflist(#{C8.escape(errors)})").in_sequence(@cmdSeq)
          ::Vim.expects(:command).with('copen').in_sequence(@cmdSeq)

          C8::Build.handleBuildResult(out: @out, st: @st)
        }
      }
    }
  }
end
