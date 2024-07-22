module SerpParser
  module Google
    module OrganicResults
      module Shared
        def title
          clean_text @doc.css("h3").text
        end

        def url
          @doc.css("a").first["href"]
        end

        def processed_data
          SerpParser::Models::OrganicResult.new(**@data)
        end
      end
    end
  end
end
