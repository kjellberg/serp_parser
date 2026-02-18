module SerpParser
  module Models
    class FaqResult
      attr_reader :question, :answer, :citations
      attr_accessor :position

      def initialize(**args)
        @question = args[:question]
        @answer = args[:answer]
        @citations = args[:citations].is_a?(Array) ? SerpParser::Collection.new(args[:citations]) : args[:citations]
      end

      def to_h
        ans = answer&.strip
        {
          "position" => @position,
          "question" => question,
          "answer" => (ans && !ans.empty?) ? ans : nil,
          "citations" => citations ? citations.map(&:to_h) : []
        }
      end
    end
  end
end
