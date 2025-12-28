module SerpParser
  module Models
    class RelatedSearch
      attr_reader :query

      def initialize(query:)
        @query = query
      end

      # Convert the object to a hash
      # @return [String] Returns the query string directly
      def to_h
        query
      end
    end
  end
end

