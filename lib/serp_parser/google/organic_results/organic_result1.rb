module SerpParser
  module Google
    module OrganicResults
      class OrganicResult1 < SerpParser::Google::Search
        SELECTOR = "div.g.Ww4FFb"
        SCHEMA = {
          title: {
            type: :instance_method
          }
        }

        def title
          @doc.css("h3").text
        end

        def processed_data
          SerpParser::Models::OrganicResult.new(**@data)
        end
      end
    end
  end
end
