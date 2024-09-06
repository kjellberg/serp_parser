require "forwardable"

module SerpParser
  class Collection
    include Enumerable
    extend Forwardable

    def_delegators :@items, :size, :length, :[], :empty?, :last, :index

    def initialize(items)
      @items = []
      items.each_with_index do |item, index|
        assign_position(item, index + 1)
        @items << item
      end
    end

    def each(&block)
      @items.each(&block)
    end

    private

    def assign_position(item, position)
      item.position = position if item.respond_to?(:position)
    end
  end
end

