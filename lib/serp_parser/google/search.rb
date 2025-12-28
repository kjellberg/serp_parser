module SerpParser
  module Google
    class Search
      def initialize(html_or_doc, schema: nil)
        if html_or_doc.is_a?(String)
          @doc = Nokogiri::HTML::DocumentFragment.parse(html_or_doc)
        else
          @doc = html_or_doc
        end
        @registry = Config.registry
      end

      def organic_results
        results = Parsers::Element.find_all(@doc, :organic_result, @registry)
        # Convert to model objects
        models = results.map do |data|
          SerpParser::Models::OrganicResult.new(**data)
        end
        SerpParser::Collection.new(models)
      end

      def search_information
        {}
      end

      def to_h
        {
          organic_results: organic_results.map(&:to_h)
        }
      end
    end
  end
end
