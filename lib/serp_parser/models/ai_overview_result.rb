module SerpParser
  module Models
    class AiOverviewResult
      attr_reader :answer, :citations

      def initialize(**args)
        @answer = args[:answer]
        raw = args[:citations].is_a?(Array) ? args[:citations] : []
        @citations = SerpParser::Collection.new(deduplicate_citations(raw))
      end

      private

      # Merge inline citations (which carry titles) with source-panel citations.
      # When the same URL appears in both, keep the titled inline version.
      def deduplicate_citations(citations)
        seen = {}
        citations.each do |c|
          url = c.url.to_s
          next if url.empty?
          existing = seen[url]
          seen[url] = c if existing.nil? || (c.title && !existing.title)
        end
        seen.values
      end

      public

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
