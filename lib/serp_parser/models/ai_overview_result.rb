module SerpParser
  module Models
    class AiOverviewResult
      attr_reader :answer, :citations

      def initialize(**args)
        @answer = args[:answer]
        @citations = args[:citations].is_a?(Array) ? SerpParser::Collection.new(args[:citations]) : args[:citations]
      end

      def to_h
        ans = answer&.strip
        {
          "answer" => (ans && !ans.empty?) ? ans : nil,
          "citations" => citations ? citations.map(&:to_h) : []
        }
      end
    end
  end
end
