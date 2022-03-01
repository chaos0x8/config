if has('ruby') == 0 || exists('g:is_fold_loaded')
  finish
endif

let g:is_fold_loaded = 1

ruby << RUBY
module Fold
  class Folder
    class Item
      attr_reader :_beg, :_end
      attr_accessor :opened

      def initialize _beg, _end, opened: false
        @_beg = _beg
        @_end = _end
        @opened = opened
      end

      def exec
        VIM.command("#{@_beg},#{@_end}fold")
        open if opened
      end

      def open
        VIM.command("#{@_beg},#{@_end}foldopen")
      end

      def <=> other
        @_beg <=> other._beg
      end

      def include? other
        _beg < other._beg && _end > other._end
      end
    end

    def initialize
      @value = []

      yield self
    end

    def add _beg, _end, open: false
      @value << Item.new(_beg, _end, opened: open)
    end

    def exec
      @value = @value.uniq.sort

      @value.each do |item|
        if p = parent(item) and children(p).size == 1
          item.opened = true
        end
      end

      @value.reverse_each { |item|
        item.exec
      }
    end

    def parent item
      @value.reverse.find do |parent|
        parent.include?(item)
      end
    end

    def children item
      return to_enum(:children, item).to_a unless block_given?

      @value.each do |child|
        yield child if item.include?(child)
      end
    end
  end
end
RUBY
