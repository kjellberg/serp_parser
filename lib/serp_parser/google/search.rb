module SerpParser
  module Google
    # The Search class parses the HTML for Google search results
    # and extracts specific information based on the provided schema.
    class Search < SerpParser::Parser
      SEARCH_ENGINE = "google"

      # Schema defining the structure and extractor types for the search results.
      SCHEMA = {
        organic_results: {
          type: :collection,
          parsers: [
            SerpParser::Google::OrganicResults::OrganicResult1
          ]
        },
        search_information: {
          type: :hash
        }
      }
    end
  end
end
