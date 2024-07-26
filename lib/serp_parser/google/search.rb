module SerpParser
  module Google
    class Search < SerpParser::Parser
      # Schema defining the structure and extractor types for the search results.
      SCHEMA = {
        organic_results: {
          type: :collection,
          parsers: [
            SerpParser::Google::OrganicResults::OrganicResult1
          ]
        },
        search_information: {
          type: :instance_method
        }
      }

      def search_information
        {}
      end
    end
  end
end
