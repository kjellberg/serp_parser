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

      def related_searches
        results = Parsers::Element.find_all(@doc, :related_searches, @registry)
        # Extract related search models from results (combines both filter pills and questions)
        searches = []
        seen_queries = {}
        results.each do |data|
          if data[:related_searches].is_a?(Array)
            data[:related_searches].each do |search|
              query = search.query
              # Only add if we haven't seen this query before
              unless seen_queries.key?(query)
                seen_queries[query] = true
                searches << search
              end
            end
          end
        end
        SerpParser::Collection.new(searches)
      end

      def search_information
        {}
      end

      def to_h
        {
          organic_results: organic_results.map(&:to_h),
          related_searches: related_searches.map(&:to_h)
        }
      end
    end
  end
end
