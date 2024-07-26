require "forwardable"

module SerpParser
  class Collection
    include Enumerable
    extend Forwardable

    def_delegators :@items, :size, :length, :[], :empty?, :last, :index

    def initialize(items)
      @items = items
    end

    def each(&block)
      @items.each(&block)
    end
  end
end
