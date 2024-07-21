module SerpParser
  module Models
    class OrganicResult
      attr_reader :title

      def initialize(title: nil)
        @title = title
      end
    end
  end
end
