if has('ruby') == 0 || exists('g:is_fold_loaded')
  finish
endif

let g:is_fold_loaded = 1

ruby << RUBY
module Fold
  class Folder
    class Item
      attr_reader :_beg, :_end, :open

      def initialize _beg, _end, open: false
        @_beg = _beg
        @_end = _end
        @open = open
      end

      def exec
        VIM.command("#{@_beg},#{@_end}fold")
        VIM.command("#{@_beg},#{@_end}foldopen") if @open
      end

      def <=> other
        @_beg <=> other._beg
      end
    end

    def initialize
      @value = []

      yield self
    end

    def add _beg, _end, open: false
      @value << Item.new(_beg, _end, open: open)
    end

    def exec
      @value.uniq.sort.reverse.each { |item|
        item.exec
      }
    end
  end
end
RUBY
