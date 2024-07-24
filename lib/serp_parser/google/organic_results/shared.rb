module SerpParser
  module Google
    module OrganicResults
      module Shared
        # Returns the title of the result
        # @return [String]
        def title
          clean_text @doc.css("h3").text
        end

        # Returns the URL of the result
        # @return [String]
        def url
          clean_google_url @doc.css("a").first["href"]
        end

        # Returns the processed data of the result
        # @return [SerpParser::Models::OrganicResult]
        def processed_data
          SerpParser::Models::OrganicResult.new(**@data)
        end
      end
    end
  end
end
